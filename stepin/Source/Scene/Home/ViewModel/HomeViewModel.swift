import Foundation
import RxSwift
import RxRelay
import RxDataSources

final class HomeViewModel {
    let tokenUtil = TokenUtils()
    var homeCoordinator : HomeCoordinator?
    var homeRepository: HomeRepository?
    var authRepository = AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    var videoRepository = VideoRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    var userRepository = UserRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    
    private var result: [SuperShortFormCollectionViewDataSection] = []
    private var extendedResult: [SuperShortFormCollectionViewDataSection] = []
    private var resultRelay = PublishRelay<[SuperShortFormCollectionViewDataSection]>()
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SuperShortFormCollectionViewDataSection>?
    
    private var danceId: String = ""
    private var videoId: String = ""
    private var commentId: String = ""
    private var userId: String = ""
    
    private var pageNum: Int = 1
    
    var isLoadFirst: Bool = false
    var isCellSelected: Bool = false
    var disposeBag = DisposeBag()
    
    var cellDeselectedRelay = PublishRelay<Void>()
    var videoPlayImagePath = PublishRelay<String>()
    var loadingRelay = PublishRelay<Bool>()
    
    init(coordinator: HomeCoordinator, homeRepository: HomeRepository) {
        self.homeRepository = homeRepository
        self.homeCoordinator = coordinator
        addObserver()
    }
    
    internal func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        var output = Output()
        dataSource = RxCollectionViewSectionedReloadDataSource<SuperShortFormCollectionViewDataSection>(
            configureCell: { dataSource, collectionView, indexPath, item in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SuperShortFormCVC.reuseIdentifier, for: indexPath) as? SuperShortFormCVC else {return UICollectionViewCell()}
                cell.bindData(data: dataSource[indexPath.section].items[indexPath.row], isCellSelected: self.isCellSelected)
                
                if !self.isLoadFirst {
                    cell.videoHandler?.videoShowStatus = .show
                }
                
                cell.backButtonCompletion = { [weak self] in
                    guard let self = self else {return}
                    input.collectionView.visibleCells.forEach {
                        let cell = $0 as? SuperShortFormCVC
                        cell?.setViewComponentHidden(state: true)
                        self.isCellSelected = false
                        cell?.isCellSelected = false
                    }
                    output.isCelleSelected.accept(false)
                }
                
                cell.rightButtonCompletion = { [weak self] in
                    guard let self = self else {return}
                    self.homeCoordinator?.pushToSearchView()
                }
                
                cell.magnifyView.smallStepinButton.animationEndCompletion = { [weak self] danceId in
                    guard let self = self else {return}
                    if danceId != "" {
                        self.homeCoordinator?.pushToDanceView(danceId: danceId)
                    }
                }
                
                self.isLoadFirst = true
            
                return cell
            })

        input.viewWillDisappear
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { _ in
                input.energyBar.refreshEnergyBar()
                input.collectionView.visibleCells.forEach { [weak self] cell in
                    let visiableCell = cell as? SuperShortFormCVC
                    visiableCell?.videoView.playerLayer.frame = visiableCell!.videoView.frame
                    visiableCell?.videoHandler?.videoShowStatus = .notShow
                    visiableCell?.videoHandler?.pauseVideo()
                }
            })
            .disposed(by: disposeBag)
        
        input.viewDidAppeared
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] in
                input.energyBar.refreshEnergyBar()
                self!.getShortFormVideo(input: input, disposeBag: disposeBag)
                guard let index = self?.getCurrentCellIndex(input: input) else {return}
                guard let cell = input.collectionView.cellForItem(at: index) as? SuperShortFormCVC else {return}
                cell.videoHandler?.videoShowStatus = .show
                cell.videoHandler?.playVideo()
                print("appear")
            })
            .disposed(by: disposeBag)
        
        
        input.stepinButton.rx.tapGesture().asObservable()
            .when(.recognized)
            .withUnretained(self)
            .asDriver{ _ in .never()}
            .drive(onNext: { (viewModel, gesture) in
                if UserDefaults.standard.bool(forKey: UserDefaultKey.LoginStatus) {
                    let indexPath = viewModel.getCurrentCellIndex(input: input)
                    input.stepinButton.playAnimation()
                    input.stepinButton.animationEndCompletion = { [weak self] in
                        viewModel.homeCoordinator?.pushToDanceView(danceId: viewModel.danceId)
                    }
                } else {
                    viewModel.homeCoordinator?.pushToLogin()
                }
            })
            .disposed(by: disposeBag)
        
        input.signupButton.rx.tapGesture().asObservable()
            .when(.recognized)
            .withUnretained(self)
            .asDriver{ _ in .never()}
            .drive(onNext: { (viewModel, gesture) in
                viewModel.homeCoordinator?.pushToLogin()
            })
            .disposed(by: disposeBag)
        
        
        input.collectionView.rx.didEndDecelerating.asObservable()
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { _ in
                let currentIndexPath = self.getCurrentCellIndex(input: input)
                if let cell = input.collectionView.cellForItem(at: currentIndexPath) {
                    let visiableCell = cell as? SuperShortFormCVC
                    visiableCell?.videoHandler?.videoShowStatus = .show
                    visiableCell?.videoHandler?.playVideo()
                }
            })
            .disposed(by: disposeBag)
        
        //셀 확실하게 정지 후 시작
        input.collectionView.rx.didEndDragging.asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                input.collectionView.visibleCells.forEach { [weak self] cell in
                    let visiableCell = cell as? SuperShortFormCVC
                    visiableCell?.videoView.playerLayer.frame = visiableCell!.videoView.frame
                    visiableCell?.videoHandler?.videoShowStatus = .notShow
                    visiableCell?.videoHandler?.pauseVideo()
                }
            })
            .disposed(by: disposeBag)
        
        //cell 선택해서 detailView로 들어갈때
        input.collectionView.rx.itemSelected.asObservable()
            .withUnretained(self)
            .subscribe(onNext: { (viewModel, indexPath) in
                let currentIndexPath = self.getCurrentCellIndex(input: input)
                if let cell = input.collectionView.cellForItem(at: currentIndexPath) {
                    if let visibleCell = cell as? SuperShortFormCVC {
                        visibleCell.isCellSelected = true
                        output.isCelleSelected.accept(true)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        input.viewWillDisappear
            .withUnretained(self)
            .subscribe(onNext: { _ in
                input.collectionView.visibleCells.forEach { [weak self] cell in
                    let visiableCell = cell as? SuperShortFormCVC
                    visiableCell?.videoView.playerLayer.frame = visiableCell!.videoView.frame
                    visiableCell?.videoHandler?.videoShowStatus = .notShow
                    visiableCell?.videoHandler?.pauseVideo()
                }
            })
            .disposed(by: disposeBag)
        
        input.searchButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { (viewModel, _) in
                viewModel.homeCoordinator?.pushToSearchView()
            })
            .disposed(by: disposeBag)
        
        input.notiButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { (viewModel, _) in
                if UserDefaults.standard.bool(forKey: UserDefaultKey.LoginStatus) {
                    input.notiButton.setBackgroundImage(ImageLiterals.icNotiOff, for: .normal)
                }
                viewModel.homeCoordinator?.pushToInbox()
            })
            .disposed(by: disposeBag)
        
        self.resultRelay
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: input.collectionView.rx.items(dataSource: dataSource!))
            .disposed(by: disposeBag)
        
        self.cellDeselectedRelay
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .bind(onNext: { (viewModel) in
                
            })
            .disposed(by: disposeBag)
        
        input.energyBar.rx.tapGesture().asObservable()
            .when(.recognized)
            .withUnretained(self)
            .asDriver{ _ in .never()}
            .drive(onNext: { _ in
                input.collectionView.visibleCells.forEach { [weak self] cell in
                    let visiableCell = cell as? SuperShortFormCVC
                    visiableCell?.videoView.playerLayer.frame = visiableCell!.videoView.frame
                    visiableCell?.videoHandler?.videoShowStatus = .notShow
                    visiableCell?.videoHandler?.pauseVideo()
                }
                self.homeCoordinator?.pushToStoreView()
            })
            .disposed(by: disposeBag)
        
        videoPlayImagePath
            .withUnretained(self)
            .subscribe(onNext: { (_, path) in
                output.currentDanceImage.accept(path)
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
        
        return output
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
                    vm.homeCoordinator?.presentBottomSheet(userId: userId,
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
    
    struct Input {
        let plusEnergyButtonTapped: Observable<Void>
        let notiButtonTapped: Observable<Void>
        let searchButtonTapped: Observable<Void>
        let stepinButton: StepinButton
        let viewDidAppeared: Observable<Void>
        let viewDidLayoutSubviews: Observable<Void>
        let viewWillDisappear: Observable<Void>
        let energyBar: EnergyBar
        let signupButton: SignupButton
        let notiButton: UIButton
        let collectionView: UICollectionView
    }
    
    struct Output {
        var isCelleSelected = PublishRelay<Bool>()
        var currentDanceImage = PublishRelay<String>()
        var isLoadingStart = PublishRelay<Void>()
        var isLoadingEnd = PublishRelay<Void>()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(setCurrentDanceId(_:)),
            name: .homeCurrentDanceId,
            object: nil
        )
        //댓글
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didCommentButtonTapped(_:)),
            name: .homeCommentTapped,
            object: nil
        )
        //like
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didLikeButtonTapped(_:)),
            name: .homeLikeTapped,
            object: nil
        )
        //More
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didMoreButtonTapped(_:)),
            name: .homeMoreTapped,
            object: nil
        )
        
        //play
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didFullScreenPlayButtonTapped(_:)),
            name: .didStepinPlayButtonTapped,
            object: nil
        )
    }
    @objc private func didFullScreenPlayButtonTapped(_ sender: NSNotification) {
        guard let danceId: String = sender.object as? String else {return}
        self.homeCoordinator?.pushToDanceView(danceId: danceId)
        
    }
    
    @objc private func setCurrentDanceId(_ sender: NSNotification) {
        guard let data: Video = sender.object as? Video else {return}
        self.danceId = data.danceID
        self.videoPlayImagePath.accept(data.coverURL)
    }
    
    @objc private func didMoreButtonTapped(_ sender: NSNotification) {
        guard let object = sender.object as? [String] else {return}
        self.loadingRelay.accept(true)
        if UserDefaults.standard.bool(forKey: UserDefaultKey.LoginStatus) {
            if UserDefaults.standard.string(forKey: UserDefaultKey.userId) == object[1] { //내 영상일 때
                self.didCheckUserBlock(userId: object[1],
                                       videoId: object[0],
                                       type: .myVideo)
            } else { //내영상이 아닐때
                self.didCheckUserBlock(userId: object[1],
                                       videoId: object[0],
                                       type: .otherVideo)
            }
        } else {
            self.loadingRelay.accept(false)
            self.homeCoordinator?.pushToLogin()
        }
    }
    
    @objc private func didLikeButtonTapped(_ sender: NSNotification) {
        guard let object = sender.object as? [String] else {return}
        
        let videoId: String = object[0]
        guard let state: Int = Int(object[1]) else {return}
        
        if UserDefaults.standard.bool(forKey: UserDefaultKey.LoginStatus) {
            self.patchLikeVideo(videoId: videoId,
                                state: state,
                                disposeBag: self.disposeBag)
        } else {
            self.homeCoordinator?.pushToLogin()
        }
    }
    
    @objc private func didCommentButtonTapped(_ sender: NSNotification){
        guard let videoId = sender.object as? String else {return}
        if UserDefaults.standard.bool(forKey: UserDefaultKey.LoginStatus) {
            self.homeCoordinator?.presentToComment(videoId: videoId)
        } else {
            self.homeCoordinator?.pushToLogin()
        }
    }
    
    @objc private func didTappBackButtonTapped(_ sender: NSNotification) {
        cellDeselectedRelay.accept(())
    }
    
    private func getCollectionViewLayout() -> UICollectionViewFlowLayout{
        if self.isCellSelected {
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = UIScreen.main.bounds.size
            layout.scrollDirection = .horizontal
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.minimumLineSpacing = 0
            return layout
        } else {
            let layout = HomeCollectionViewLayout()
            return layout
        }
    }
    
    //현재 셀 인덱스 가져오기
    private func getCurrentCellIndex(input: Input) -> IndexPath {
        var visiableRect = CGRect()
        visiableRect.origin = input.collectionView.contentOffset
        visiableRect.size = input.collectionView.bounds.size
        let visibleRect = CGPoint(x: visiableRect.midX, y: visiableRect.midY)
        guard let currentCellIndexPath = input.collectionView.indexPathForItem(at: visibleRect) else { return IndexPath(row: 0, section: 0)}
        
        return currentCellIndexPath
    }
    
    private func patchLikeVideo(videoId: String, state: Int, disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap{ (viewModel, _) in viewModel.videoRepository.patchLikeVideo(videoId: videoId, state: state) }
            .withUnretained(self)
            .subscribe(onNext: { (viewModel, result) in
                print(result)
            })
            .disposed(by: disposeBag)
    }
    
    private func getShortFormVideo(input: Input, disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap { (viewModel, _) in (viewModel.homeRepository?.getShortForm(page: viewModel.pageNum))! }
            .withUnretained(self)
            .subscribe(onNext: { (viewModel, result) in
                viewModel.result = [result]
                viewModel.extendedResult = viewModel.result
                viewModel.resultRelay.accept(viewModel.extendedResult)
            })
            .disposed(by: disposeBag)
    }
    
    func setDanceIdInSwiftUI (danceId: String, coverURL: String) {
        self.danceId = danceId
        self.videoPlayImagePath.accept(coverURL)
    }
}

