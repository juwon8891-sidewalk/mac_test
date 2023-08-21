import Foundation
import RxSwift
import RxRelay
import RxDataSources

enum callVideoType {
    case inbox
    case dance
    case searchHot
    case searchHashTag
    case myPage
}

final class NormalVideoViewModel: NSObject {
    let tokenUtil = TokenUtils()
    var disposeBag = DisposeBag()
    var normalViewCoordinator : NormalViewCoordinator?
    var videoRepository: VideoRepository?
    var authRepository = AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    var userRepository = UserRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())


    var dataSource: RxCollectionViewSectionedReloadDataSource<NormalVideoCollectionViewDataSection>?
    var pageNum: Int = 1
    var normalResult: [NormalVideoCollectionViewDataSection] = []
    private var normalResultRelay = PublishRelay<[NormalVideoCollectionViewDataSection]>()
    private var loadingRelay = PublishRelay<Bool>()
    
    var isNewReloadCell: Bool = true
    
    var type: callVideoType?
    var indexPath: IndexPath?
    var danceId: String = ""
    var musicId: String = ""
    var keyWord: String = ""
    var userId: String = ""
    
    
    private var input: Input?
    
    init(coordinator: NormalViewCoordinator, videoRepository: VideoRepository) {
        self.videoRepository = videoRepository
        self.normalViewCoordinator = coordinator
    }
    
    internal func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        var output = Output()
        self.disposeBag = disposeBag
        self.input = input
        dataSource = RxCollectionViewSectionedReloadDataSource<NormalVideoCollectionViewDataSection>(
            configureCell: {  [weak self] dataSource, collectionView, indexPath, item in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NormalCVC.identifier, for: indexPath) as? NormalCVC else {return UICollectionViewCell()}
                cell.setCellVideoData(videoPath: dataSource[indexPath.section].items[indexPath.row].videoURL ?? "",
                                      profilePath: dataSource[indexPath.section].items[indexPath.row].profileURL ?? "",
                                      userName: dataSource[indexPath.section].items[indexPath.row].identifierName,
                                      userId:
                                        dataSource[indexPath.section].items[indexPath.row].userID,
                                      hashTags: dataSource[indexPath.section].items[indexPath.row].hashtag,
                                      content: dataSource[indexPath.section].items[indexPath.row].content,
                                      likeCount: dataSource[indexPath.section].items[indexPath.row].likeCount,
                                      isLiked: dataSource[indexPath.section].items[indexPath.row].alreadyLiked,
                                      commentCount: dataSource[indexPath.section].items[indexPath.row].commentCount,
                                      musicTitle: dataSource[indexPath.section].items[indexPath.row].title,
                                      isCommentEnabled: dataSource[indexPath.section].items[indexPath.row].allowComment,
                                      isOpenScore: dataSource[indexPath.section].items[indexPath.row].openScore,
                                      score: dataSource[indexPath.section].items[indexPath.row].score,
                                      coordinaotr: (self?.normalViewCoordinator)!)
                //like
                cell.interactionStackView.likeButtonCompletion = { state in
                    var commentState = 0
                    if state {
                        self!.normalResult[indexPath.section].items[indexPath.row].likeCount -= 1
                        self!.normalResult[indexPath.section].items[indexPath.row].alreadyLiked = !self!.normalResult[indexPath.section].items[indexPath.row].alreadyLiked
                        cell.interactionStackView.bindData(commentCnt: self!.normalResult[indexPath.section].items[indexPath.row].commentCount,
                                                           isCommentEnabled: self!.normalResult[indexPath.section].items[indexPath.row].allowComment,
                                                           likeCnt: self!.normalResult[indexPath.section].items[indexPath.row].likeCount,
                                                           isLiked: self!.normalResult[indexPath.section].items[indexPath.row].alreadyLiked)
                        commentState = -1
                    } else {
                        self!.normalResult[indexPath.section].items[indexPath.row].likeCount += 1
                        self!.normalResult[indexPath.section].items[indexPath.row].alreadyLiked = !self!.normalResult[indexPath.section].items[indexPath.row].alreadyLiked
                        cell.interactionStackView.bindData(commentCnt: self!.normalResult[indexPath.section].items[indexPath.row].commentCount,
                                                           isCommentEnabled: self!.normalResult[indexPath.section].items[indexPath.row].allowComment,
                                                           likeCnt: self!.normalResult[indexPath.section].items[indexPath.row].likeCount,
                                                           isLiked: self!.normalResult[indexPath.section].items[indexPath.row].alreadyLiked)
                        commentState = 1
                    }
                    self?.likeComment(videoId: dataSource[indexPath.section].items[indexPath.row].videoID,
                                      state: commentState,
                                      disposeBag: disposeBag)
                }
                //comment
                cell.interactionStackView.commentCompletion = { [weak self] in
                    guard let strongSelf = self else {return}
                    if UserDefaults.standard.bool(forKey: UserDefaultKey.LoginStatus) {
                        strongSelf.normalViewCoordinator?.presentToComment(videoId: dataSource[indexPath.section].items[indexPath.row].videoID)
                    } else {
                        strongSelf.normalViewCoordinator?.pushToLogin()
                    }
                }
                //More
                cell.interactionStackView.moreButtonCompletion = { [weak self] in
                    guard let strongSelf = self else {return}
                    strongSelf.loadingRelay.accept(true)
                    if UserDefaults.standard.bool(forKey: UserDefaultKey.LoginStatus) {
                        //내 프로필일때
                        if UserDefaults.standard.string(forKey: UserDefaultKey.userId) == dataSource[indexPath.section].items[indexPath.row].userID {
                            strongSelf.didCheckUserBlock(userId: dataSource[indexPath.section].items[indexPath.row].userID,
                                                    videoId: dataSource[indexPath.section].items[indexPath.row].videoID,
                                                    type: .myVideo)
                        } else { //아닐때
                            strongSelf.didCheckUserBlock(userId: dataSource[indexPath.section].items[indexPath.row].userID,
                                                    videoId: dataSource[indexPath.section].items[indexPath.row].videoID,
                                                    type: .otherVideo)
                        }
                    } else {
                        strongSelf.normalViewCoordinator?.pushToLogin()
                    }
                }
                
                return cell
            })
        
        //play video
        input.collectionView.rx.didEndDecelerating.asObservable()
            .subscribe(onNext: { [weak self] in
                let indexPath = self!.getCurrentCellIndex(input: input)
                if let cell = input.collectionView.cellForItem(at: indexPath) as? NormalCVC {
                    cell.playVideo()
                }
            })
            .disposed(by: disposeBag)
        
        input.collectionView.rx.didEndDragging.asObservable()
        //셀 확실하게 정지 후 시작
            .subscribe(onNext: { [weak self] _ in
                input.collectionView.visibleCells.forEach { cell in
                    let visiableCell = cell as! NormalCVC
                    visiableCell.stopVideo()
                }
            })
            .disposed(by: disposeBag)
        
        //비디오 데이터 disposed
        input.viewWillDisappear
            .subscribe(onNext: { [weak self] in
                input.collectionView.visibleCells.forEach { cell in
                    let visiableCell = cell as! NormalCVC
                    visiableCell.removeVideo()
                }
            })
            .disposed(by: disposeBag)
        //pagination
        input.collectionView.rx.contentOffset.asObservable()
            .throttle(.seconds(3), scheduler: MainScheduler.asyncInstance)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] offset in
                if offset.y > input.collectionView.contentSize.height - input.collectionView.frame.height {
                    switch self!.type {
                    case .dance:
                        self?.getTypeVideo(disposeBag: disposeBag)
                    case .myPage:
                        self?.getMyPageVideo(disposeBag: disposeBag)
                    case .searchHashTag:
                        self?.getSearchHashTagVideo(disposeBag: disposeBag)
                    case .searchHot:
                        self?.getSearchHotVideo(disposeBag: disposeBag)
                    default:
                        break
                    }
                    //pagenation
                }
            })
        
        input.viewDidAppeared
            .subscribe(onNext: { [weak self] in
                self!.normalResultRelay.accept(self!.normalResult)
                input.collectionView.setContentOffset(.init(x: 0, y: Int(UIScreen.main.bounds.height) * self!.indexPath!.row), animated: false)
                output.navigationTitle.accept(self?.normalResult[0].items[0].artist ?? "")
            })
            .disposed(by: disposeBag)
        
        normalResultRelay
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: input.collectionView.rx.items(dataSource: self.dataSource!))
            .disposed(by: disposeBag)
        
        input.backButtonDidTapped
            .subscribe(onNext: { [weak self] in
                self?.normalViewCoordinator?.pop()
            })
            .disposed(by: disposeBag)
        
        loadingRelay
            .withUnretained(self)
            .bind(onNext: { (vm, state) in
                if state {
                    output.isLoadingStart.accept(())
                } else {
                    output.isLoadingEnd.accept(())
                }
            })
            .disposed(by: disposeBag)
        
        input.collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didDeleteVideo),
            name: .didDeleteVideo,
            object: nil
        )
        
        return output
    }
    
    @objc private func didDeleteVideo() {
        DispatchQueue.main.async {
            if let cell = self.input!.collectionView.cellForItem(at: self.getCurrentCellIndex(input: self.input!)) as? NormalCVC {
                cell.removeVideo()
            }
        }
        self.normalViewCoordinator?.popToMypage()
    }
    
    struct Input {
        let viewDidAppeared: Observable<Void>
        let viewWillDisappear: Observable<Void>
        let backButtonDidTapped: Observable<Void>
        let collectionView: UICollectionView
    }
    struct Output {
        var navigationTitle = PublishRelay<String>()
        var danceNameTitle = PublishRelay<String>()
        var isLoadingStart = PublishRelay<Void>()
        var isLoadingEnd = PublishRelay<Void>()
    }
    
    
    private func getCurrentCellIndex(input: Input) -> IndexPath {
        var visiableRect = CGRect()
        visiableRect.origin = input.collectionView.contentOffset
        visiableRect.size = input.collectionView.bounds.size
        let visibleRect = CGPoint(x: visiableRect.midX, y: visiableRect.midY)
        guard let currentCellIndexPath = input.collectionView.indexPathForItem(at: visibleRect) else { return IndexPath(row: 0, section: 0)}

        return currentCellIndexPath
    }
    

    private func getTypeVideo(disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in (self?.videoRepository!.getTypeVideo(type: GetTypeVideoType.dance,
                                                                           targetId: self!.danceId,
                                                                           page: self!.pageNum))! }
            .subscribe(onNext: { [weak self] result in
                if !result.items.isEmpty {
                    self?.pageNum += 1
                }
                if !self!.normalResult.isEmpty {
                    self!.normalResult[0].items.append(contentsOf: result.items)
                }
                self!.normalResultRelay.accept(self!.normalResult)
            })
            .disposed(by: disposeBag)
    }
    
    private func getSearchHotVideo(disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in (self?.videoRepository?.getTypeVideo(type: GetTypeVideoType.hashtag,
                                                                             targetId: self!.keyWord,
                                                                             page: self!.pageNum))! }
            .subscribe(onNext: { [weak self] result in
                if !result.items.isEmpty {
                    self?.pageNum += 1
                }
                if !self!.normalResult.isEmpty {
                    self!.normalResult[0].items.append(contentsOf: result.items)
                }
                self!.normalResultRelay.accept(self!.normalResult)
            })
            .disposed(by: disposeBag)
    }
    
    private func getSearchHashTagVideo(disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in (self?.videoRepository?.getSearchHotVideo(keyword: self!.keyWord,
                                                                                  page: self!.pageNum))! }
            .subscribe(onNext: { [weak self] result in
                if !result.items.isEmpty {
                    self?.pageNum += 1
                }
                if !self!.normalResult.isEmpty {
                    self!.normalResult[0].items.append(contentsOf: result.items)
                }
                self!.normalResultRelay.accept(self!.normalResult)
            })
            .disposed(by: disposeBag)
    }
    
    private func getMyPageVideo(disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in (self?.videoRepository?.getUserVideo(type: "id",
                                                                             userId: self!.userId,
                                                                             page: self!.pageNum))!}
            .subscribe(onNext: { [weak self] result in
                if !result.data.video.isEmpty {
                    self?.pageNum += 1
                }
                if !self!.normalResult.isEmpty {
                    self!.normalResult[0].items.append(contentsOf: result.data.video)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func likeComment(videoId: String, state: Int, disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .flatMap{ [weak self] _ in (self?.videoRepository?.patchLikeVideo(videoId: videoId, state: state))! }
            .subscribe(onNext: { [weak self] result in
                print(result)
            })
            .disposed(by: disposeBag)
    }
    
    private func didCheckUserBlock(userId: String,
                                   videoId: String,
                                   type: BottomSheetType) {
        let userProfileObservable = self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap { (viewModel, _) in
                viewModel.userRepository.getUserProfile(type: "id", data: userId)
            }
            .withUnretained(self)

        let boostIsPossibleObservable = userProfileObservable
            .flatMap { (viewModel, _) in
                viewModel.userRepository.getBoostIsPossible()
            }
            .withUnretained(self)
        
        Observable.zip(userProfileObservable, boostIsPossibleObservable)
            .subscribe(onNext: { (arg0, arg1) in
                let (vm, userProfile) = arg0
                let (_, isBoostPossible) = arg1
                DispatchQueue.main.async {
                    vm.normalViewCoordinator?.presentBottomSheet(userId: userId,
                                                                 videoId: videoId,
                                                                 isFollowed: userProfile.data.isFollowed,
                                                                 isBlocked: userProfile.data.isBlocked,
                                                                 isBoosted: isBoostPossible.data.possible,
                                                                 type: type)
                    vm.loadingRelay.accept(false)
                }
            })
            .disposed(by: disposeBag)
        
    }

}

extension NormalVideoViewModel: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? NormalCVC {
            cell.stopVideo()
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if let cell = cell as? NormalCVC {
                cell.playVideo()
            }
        } else {
            if let cell = cell as? NormalCVC {
                cell.videoHandler?.videoShowStatus = .show
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? NormalCVC {
            print(cell.isSelected)
            if cell.isPlaying {
                cell.stopVideo()
            } else {
                cell.playVideo()
            }
        }
    }
}

