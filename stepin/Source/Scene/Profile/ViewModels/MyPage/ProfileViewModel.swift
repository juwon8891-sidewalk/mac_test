import Foundation
import RxDataSources
import RxSwift
import RxCocoa

class ProfileViewModel: NSObject {
    private let profileUseCase = ProfileUseCase()
    private var coordinator: ProfileCoordinator?
    
    var userId: String = ""
    var backgroundVideoPath: String?
    var isBlocked: Bool?
    var isFollowed: Bool?
    var isBoosted: Bool?
    var profileState: ProfileViewState = .my
    var headerDragFlag: Bool = false
    
    private var videoPageNum: Int = 1
    private var dataSource: RxCollectionViewSectionedReloadDataSource<ProfileCollectionViewDataSection>?
    private var profileData = PublishRelay<[ProfileCollectionViewDataSection]>()
    
    private var isBlockStateRelay = PublishRelay<Bool>()
    
    init(coordinator: ProfileCoordinator) {
        super.init()
        self.coordinator = coordinator
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        input.collectionView.delegate = self
        
        dataSource = RxCollectionViewSectionedReloadDataSource<ProfileCollectionViewDataSection>(
                configureCell: { dataSource, collectionView, indexPath, item in
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoPreviewCVC.identifier, for: indexPath) as? VideoPreviewCVC else { return UICollectionViewCell() }
                    cell.setImage(path: dataSource[indexPath.section].items[indexPath.row].thumbnailURL ?? "")
                    return cell
                }, configureSupplementaryView: { (dataSource, collectionView, kind, indexPath) in
                    switch kind {
                    case UICollectionView.elementKindSectionHeader:
                        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                           withReuseIdentifier: ProfileHeaderView.reuseIdentifier,
                                                                                           for: indexPath) as? ProfileHeaderView else {return UICollectionReusableView() }
                        self.backgroundVideoPath = dataSource[indexPath.section].header.profileVideoURL
                        self.isBlocked = dataSource[indexPath.section].header.isBlocked
                        self.isFollowed = dataSource[indexPath.section].header.isFollowed
                        
                        header.bindData(data: dataSource[indexPath.section].header,
                                        profileState: self.profileState)
                        output.navigationTitle.accept(dataSource[indexPath.section].header.identifierName)
                        
                        header.followersButtonTapCompletion = { [weak self] in
                            guard let self else {return}
                            DispatchQueue.main.async {
                                self.coordinator?.pushToFollowerVC(userid: self.userId)
                            }
                        }
                        
                        header.followingButtonTapCompletion = { [weak self] in
                            guard let self else {return}
                            DispatchQueue.main.async {
                                self.coordinator?.pushToFollowingVC(userid: self.userId)
                            }
                        }
                        
                        //follow/following or editProfile
                        header.leftButtonTapCompletion = { [weak self] state in
                            guard let self else {return}
                            output.isLoadingStart.accept(())
                            self.setLeftButtonAction(buttonSelected: state)
                                .withUnretained(self)
                                .bind(onNext: { (vm, state) in
                                    if let state {
                                        //다른 사람의 프로필일 경우 팔로우/팔로잉 처리
                                        if self.profileState == .other {
                                            vm.setFollowButtonLayout(input: input,
                                                                     state: state)
                                            output.isLoadingEnd.accept(())
                                        }
                                        if self.profileState == .block {
                                            //리로드 필요
                                            self.getProfileData(userId: vm.userId,
                                                                disposeBag: disposeBag)
                                            .observe(on: MainScheduler.asyncInstance)
                                            .withUnretained(self)
                                            .bind(onNext: { (vm, cellCount) in
                                                vm.setCollectionViewPadding(input: input,
                                                                            cellCount: cellCount)
                                                output.isLoadingEnd.accept(())
                                            })
                                            .disposed(by: disposeBag)
                                            vm.isBlockStateRelay.accept(state)
                                        }
                                    } else {
                                        output.isLoadingEnd.accept(())
                                    }
                                })
                                .disposed(by: disposeBag)
                        }
                        
                        //boost or shareProfile
                        header.rightButtonTapCompletion = { [weak self] state in
                            guard let self else {return}
                            
                            self.rightButtonAction(buttonSelected: state)
                                .withUnretained(self)
                                .subscribe(onNext: { (vm, str) in
                                    print("rightButtonTap state = \(state)")
                                    if let str {
                                        //share 일때
                                        if self.profileState == .backButtonMy || self.profileState == .my {
                                            output.showShareBottomSheet.accept(str)
                                        } else {
                                            output.rightButtonstate.accept(true)
                                        }
                                    }
                                })
                                .disposed(by: disposeBag)
                        }
                        
                        return header
                    default:
                        return UICollectionReusableView()
                    }
                })
        
        input.viewDidAppear
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                output.isLoadingStart.accept(())
                output.profileViewType.accept(vm.profileState)
                
                //프로파일 데이터 가져오기
                self.getProfileData(userId: vm.userId,
                                    disposeBag: disposeBag)
                .observe(on: MainScheduler.asyncInstance)
                .withUnretained(self)
                .bind(onNext: { (vm, cellCount) in
                    vm.setCollectionViewPadding(input: input,
                                                cellCount: cellCount)
                    output.isLoadingEnd.accept(())
                })
                .disposed(by: disposeBag)
                
            })
            .disposed(by: disposeBag)
        
        input.navigationRightButtonTap
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                switch vm.profileState {
                case .my, .backButtonMy:
                    DispatchQueue.main.async {
                        vm.coordinator?.pushToSettingView()
                    }
                case .block, .other:
                    vm.profileUseCase.checkBoostPossible()
                        .withUnretained(self)
                        .subscribe(onNext: { (vm, data) in
                            if let isFollowed = vm.isFollowed, let isBlocked = vm.isBlocked{
                                DispatchQueue.main.async {
                                    vm.coordinator?.presentToBottomSheet(userId: vm.userId,
                                                                         isFollowed: isFollowed,
                                                                         isBlocked: isBlocked,
                                                                         isBoosted: data)
                                }
                            }
                        })
                        .disposed(by: disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        input.backButtonTap
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                self.coordinator?.popViewController()
            })
            .disposed(by: disposeBag)
        
        input.collectionView.rx.contentOffset.asObservable()
            .skip(1)
            .withUnretained(self)
            .bind(onNext: { (vm, offset) in
                output.collectionViewOffset.accept(offset.y)
            })
            .disposed(by: disposeBag)
        
        profileData
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: input.collectionView.rx.items(dataSource: dataSource!))
            .disposed(by: disposeBag)
        
        self.isBlockStateRelay
            .withUnretained(self)
            .bind(onNext: { (vm, state) in
                output.isLoadingStart.accept(())
                vm.profileState = state ? .block : .other
                output.profileViewType.accept(vm.profileState)
            })
            .disposed(by: disposeBag)
        
        input.collectionView.rx.contentOffset.asObservable()
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.asyncInstance)
            .withUnretained(self)
            .bind(onNext: { (vm, point) in
                if point.y > (input.collectionView.contentSize.height - input.collectionView.frame.size.height) {
                    if !vm.profileUseCase.isNotReload {
                        output.isLoadingStart.accept(())
                        vm.profileUseCase.increasePageNum()
                        vm.getProfileData(userId: vm.userId,
                                          disposeBag: disposeBag)
                        .withUnretained(self)
                        .bind(onNext: { (vm, data) in
                            output.isLoadingEnd.accept(())
                        })
                        .disposed(by: disposeBag)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        

        return output
    }
    
    private func isBoostPossible() -> Observable<Bool> {
        profileUseCase.checkBoostPossible()
            .withUnretained(self)
            .map { (uc, state) in
                return state
            }
    }
    
    private func setFollowButtonLayout(input: Input,
                                       state: Bool) {
        DispatchQueue.main.async {
            if let headerView = input.collectionView.supplementaryView(forElementKind:  UICollectionView.elementKindSectionHeader,
                                                                       at: [0, 0]) as? ProfileHeaderView {
                headerView.leftButton.isSelected = state
                headerView.leftButton.setTitle("mypage_follow_button_title".localized(), for: .normal)
                headerView.leftButton.setTitleColor(.PrimaryWhiteNormal, for: .normal)
                headerView.leftButton.setBackgroundColor(.clear, for: .normal)
                headerView.leftButton.setTitle("mypage_following_button_title".localized(), for: .selected)
                headerView.leftButton.setBackgroundColor(.PrimaryWhiteNormal, for: .selected)
                headerView.leftButton.setTitleColor(.PrimaryBlackNormal, for: .selected)
            }
        }
    }
    
    private func setLeftButtonAction(buttonSelected: Bool) -> Observable<Bool?> {
        switch self.profileState {
        case .my, .backButtonMy:
            DispatchQueue.main.async {
                self.coordinator?.pushToEditProfile(backgroundVideoPath: self.backgroundVideoPath ?? "")
            }
            return Observable.just(nil)
        case .other:
            return self.profileUseCase.patchFollowingUser(userId: self.userId,
                                                   followingState: buttonSelected)
            .withUnretained(self)
            .map { (vm, state) in
                return state
            }
            
        case .block:
            return self.profileUseCase.poseBlockUser(userId: self.userId,
                                                     wantBlock: false)
            .withUnretained(self)
            .map { (vm, state) in
                return state
            }
        }
    }
    
    private func rightButtonAction(buttonSelected: Bool) -> Observable<String?> {
        switch self.profileState {
        case .backButtonMy, .my:
            return self.profileUseCase.getProfileShareLink(userId: self.userId)
                .withUnretained(self)
                .map { (vm, link) in
                    return link
                }
            
        case .other:
            //부스트를 보낼 수 있는 상태일때만
            if !buttonSelected {
                return self.profileUseCase.patchUserBoost(userId: self.userId)
                    .withUnretained(self)
                    .map { (vm, state) in return state}
            } else {
                return Observable.just(nil)
            }
            
        case .block:
            return Observable.just(nil)
        }
    }
    
    private func getProfileData(userId: String,
                                disposeBag: DisposeBag) -> Observable<Int> {
        return self.profileUseCase.getProfileData(userId: userId)
            .withUnretained(self)
            .map { (vm, data) in
                if data[0].header.isBlocked {
                    vm.profileState = .block
                    vm.isBlockStateRelay.accept(true)
                    vm.profileData.accept([.init(header: data[0].header,
                                                 items: [])])
                    return 0
                } else {
                    if UserDefaults.userId != data[0].header.userID {
                        vm.profileState = .other
                        vm.isBlockStateRelay.accept(false)
                    }
                    vm.profileData.accept(data)
                    return data[0].items.count
                }
                
            }
    }
    
    private func setCollectionViewPadding(input: Input, cellCount: Int) {
        switch cellCount {
        case 1 ... 3:
            input.collectionView.contentInset = .init(top: 0,
                                                      left: 4,
                                                      bottom: 150.adjustedH * 3,
                                                      right: 4)
        case 4 ... 6:
            input.collectionView.contentInset = .init(top: 0,
                                                      left: 4,
                                                      bottom: 150.adjustedH * 2,
                                                      right: 4)
        case 7 ... 9:
            input.collectionView.contentInset = .init(top: 0,
                                                      left: 4,
                                                      bottom: 150.adjustedH,
                                                      right: 4)
        default:
            input.collectionView.contentInset = .init(top: 0, left: 4, bottom: 0, right: 4)
            
        }
    }
    

    struct Input {
        let viewDidAppear: Observable<Void>
        let navigationRightButtonTap: Observable<Void>
        let backButtonTap: Observable<Void>
        let collectionView: UICollectionView
    }
    
    struct Output {
        var navigationTitle = PublishRelay<String>()
        var headerViewData = PublishRelay<MyPageData>()
        var profileViewType = PublishRelay<ProfileViewState>()
        var isLoadingStart = PublishRelay<Void>()
        var isLoadingEnd = PublishRelay<Void>()
        var collectionViewOffset = PublishRelay<CGFloat>()
        var leftButtonState = PublishRelay<Bool>()
        var rightButtonstate = PublishRelay<Bool>()
        var showShareBottomSheet = PublishRelay<String>()
        var isBoostButtonTap = PublishRelay<Void>()
        
    }
  
}

extension ProfileViewModel: UICollectionViewDelegate {}
