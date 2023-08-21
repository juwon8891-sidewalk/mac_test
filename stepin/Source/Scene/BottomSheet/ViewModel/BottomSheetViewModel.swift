import Foundation
import RxCocoa
import RxSwift
import Photos

final class BottomSheetViewModel {
    enum ShareType {
        case link
        case share
    }
    private var transitionView: UIView = UIView()
    private var viewTranslation = CGPoint(x: 0, y: 0)
    private var viewMaxTranslation = CGPoint(x: 0, y: 0)
    private var viewVelocity = CGPoint(x: 0, y: 0)
    private var isEnableGesture: Bool = true
    
    var userId: String = ""
    var videoId: String = ""
    
    //save video
    var stepinId: String = ""
    var videoUrl: String = ""
    var score: String = ""
    
    var videoDynamicLink = ""
    var userDynamicLink = ""
    
    var isCopyCompleteRelay = PublishRelay<Void>()
    var isReadyToShareRelay = PublishRelay<String>()
    var isStartSavingVideo = PublishRelay<Void>()
    var isEndSavingVideo = PublishRelay<Void>()
    var isBoostSuccess = PublishRelay<Bool>()
    
    var bottomSheetCoordinator: BottomSheetCoordinator?
    
    let authRepository = AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    let userRepository = UserRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    let videoRepository = VideoRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    
    
    struct Input {
        let bottomHandleScrol: Observable<UIPanGestureRecognizer>
        let followButton: SquareButton?
        let saveButton: SquareButton?
        let shareButton: SquareButton
        let boostButton: SquareButton?
        let deleteButton: UIButton?
        let saveDanceButton: UIButton?
        let blockUserDanceButton: UIButton?
        let reportButtonButton: UIButton?
        let modifyButton: SquareButton?
        let deleteAlertButton: UIButton?
    }
    
    struct Output {
        var currentBottomSheetPoint = BehaviorRelay<CGPoint>(value: .init())
        var isFollowButtonTapped = PublishRelay<Bool>()
        var isBlockButtonTapped = PublishRelay<Bool>()
        var isCompletedCopy = PublishRelay<Void>()
        var isReportButtonTapped = PublishRelay<[String]>()
        var isReadyToShareLink = PublishRelay<String>()
        var isVideoPermissionDenined = PublishRelay<Void>()
        var isBoostComplete = PublishRelay<Bool>()
        var showBoostAlert = PublishRelay<Bool>()
    }
    
    init(transitionView: UIView) {
        self.transitionView = transitionView
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
//        self.getUserInfo(input: input, disposeBag: disposeBag)
        
        input.modifyButton?.rx.tap.asObservable()
            .debug()
            .withUnretained(self)
            .bind(onNext: { _ in
                print("?!!?!?")
                self.bottomSheetCoordinator?.pushToModifyVideoView(videoId: self.videoId)
            })
            .disposed(by: disposeBag)
        
        input.deleteAlertButton?.rx.tap.asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.deleteVideo(disposeBag: disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.bottomHandleScrol
            .asDriver { _ in .never() }
            .drive(onNext: { [weak self] gesture in
                self?.didModalViewScrolled(sender: gesture)
            })
            .disposed(by: disposeBag)
        
        
        input.followButton?.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] in
                if !input.followButton!.isDisable {
                    self?.patchFollowUser(input: input, disposeBag: disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        input.blockUserDanceButton?.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] in
                input.blockUserDanceButton?.isSelected = !input.blockUserDanceButton!.isSelected
                self?.blockUser(input: input, disposeBag: disposeBag)
            })
            .disposed(by: disposeBag)
        
        self.isCopyCompleteRelay
            .withUnretained(self)
            .subscribe(onNext: { _ in
                output.isCompletedCopy.accept(())
            })
            .disposed(by: disposeBag)
        
        input.reportButtonButton?.rx.tap.asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                /** videoId, userId*/
                output.isReportButtonTapped.accept([self.videoId, self.userId])
            })
            .disposed(by: disposeBag)
        
        input.shareButton.rx.tap.asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                if input.saveDanceButton != nil { // 비디오의 경우
                    self.getVideoDynamicLink(input: input, type: .share, disposeBag: disposeBag)
                } else { //유저의 경우
                    self.getUserDynamicLink(input: input, type: .share, disposeBag: disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        self.isReadyToShareRelay
            .withUnretained(self)
            .subscribe(onNext: { (_, link) in
                output.isReadyToShareLink.accept(link)
            })
            .disposed(by: disposeBag)
        
        input.saveDanceButton?.rx.tap.asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                if self.checkSaveVideoPermission() {
                    NotificationCenter.default.post(name: .didSaveVideoStart,
                                                    object: true,
                                                    userInfo: nil)
                    self.getVideoInfo(input: input, disposeBag: disposeBag)
                } else {
                    PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] _ in
                        guard let self = self else {return}
                        if self.checkSaveVideoPermission() {
                            NotificationCenter.default.post(name: .didSaveVideoStart,
                                                            object: true,
                                                            userInfo: nil)
                            self.getVideoInfo(input: input, disposeBag: disposeBag)
                        } else {
                            NotificationCenter.default.post(name: .videoPermissionDenined,
                                                            object: nil,
                                                            userInfo: nil)
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        input.saveButton?.rx.tap.asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                if self.checkSaveVideoPermission() {
                    NotificationCenter.default.post(name: .didSaveVideoStart,
                                                    object: true,
                                                    userInfo: nil)
                    self.getVideoInfo(input: input, disposeBag: disposeBag)
                } else {
                    PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] _ in
                        guard let self = self else {return}
                        if self.checkSaveVideoPermission() {
                            NotificationCenter.default.post(name: .didSaveVideoStart,
                                                            object: true,
                                                            userInfo: nil)
                            self.getVideoInfo(input: input, disposeBag: disposeBag)
                        } else {
                            NotificationCenter.default.post(name: .videoPermissionDenined,
                                                            object: nil,
                                                            userInfo: nil)
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        input.boostButton?.rx.tap.asObservable()
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                if let boostButton = input.boostButton {
                    //selected가 true일때만 눌릴 수 있도록
                    if boostButton.isSelected {
                        output.showBoostAlert.accept(true)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        self.isBoostSuccess
            .withUnretained(self)
            .bind(onNext: { (vm, state) in
                if state {
                    output.isBoostComplete.accept(state)
                }
            })
            .disposed(by: disposeBag)
        
        self.isStartSavingVideo
            .withUnretained(self)
            .subscribe(onNext: { _ in
                
            })
            .disposed(by: disposeBag)
        
        self.isEndSavingVideo
            .withUnretained(self)
            .subscribe(onNext: { _ in
                NotificationCenter.default.post(name: .didSaveVideoStart,
                                                object: false,
                                                userInfo: nil)
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
    private func checkSaveVideoPermission() -> Bool {
        var status: PHAuthorizationStatus = .notDetermined
        print(status)
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        } else {
            status = PHPhotoLibrary.authorizationStatus()
        }
        return status == .authorized
    }
    
    func didModalViewScrolled(sender: UIPanGestureRecognizer) {
        viewTranslation = sender.translation(in: self.transitionView)
        viewVelocity = sender.translation(in: self.transitionView)
        print(self.viewVelocity)
        switch sender.state {
        case .changed:
            if viewTranslation.y > 0 {
                self.transitionView.transform = CGAffineTransform(translationX: 0, y: viewTranslation.y)
            }
        case .ended:
            if viewTranslation.y < self.transitionView.frame.height / 2 {
                UIView.animate(withDuration: 0.3, delay: 0) {
                    self.transitionView.transform = CGAffineTransform(translationX: 0, y: 0)
                }
            } else {
                UIView.animate(withDuration: 0.3, delay: 0) {
                    self.transitionView.transform = CGAffineTransform(translationX: 0, y: self.transitionView.frame.height)

                    self.bottomSheetCoordinator?.dismiss()
                }
            }
        default:
            break
        }
    }
    
    func getUserInfo(input: Input, disposeBag: DisposeBag) {
        print(self.userId, "userId")
        self.authRepository.postRefreshToken()
            .observe(on: MainScheduler.asyncInstance)
            .flatMap { [weak self] _ in (self!.userRepository.getUserProfile(type: "id",
                                                                             data: self!.userId))}
            .subscribe(onNext: { result in
                DispatchQueue.main.async {
                    if result.data.isFollowed {
                        input.followButton?.isSelected = true
                        input.followButton?.isFollowingButtonSelected()
                    } else {
                        input.followButton?.isSelected = false
                        input.followButton?.isFollowingButtonUnselected()
                    }
                    
                    if result.data.isBlocked {
                        input.blockUserDanceButton?.isSelected = true
                        input.followButton?.isButtonDisabled()
                        input.boostButton?.changeBoostButtonDisabled()
                    } else {
                        input.blockUserDanceButton?.isSelected = false
//                        input.boostButton?.changeBoostButtonEnabled()
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    
    
    
    func patchFollowUser(input: Input, disposeBag: DisposeBag) {
        NotificationCenter.default.post(name: .showLoading,
                                        object: nil,
                                        userInfo: nil)
        print(self.userId)
        self.authRepository.postRefreshToken()
            .observe(on: MainScheduler.asyncInstance)
            .flatMap { [weak self] _ in (self?.userRepository.patchFollowUser(userId: self!.userId,
                                                                              state: input.followButton!.isSelected ? -1: 1))! }
            .subscribe(onNext: { [weak self] result in
                print(result)
                DispatchQueue.main.async {
                    if result.data.state == 1 {
                        input.followButton?.isFollowingButtonSelected()
                    } else {
                        input.followButton?.isFollowingButtonUnselected()
                    }
                }
                NotificationCenter.default.post(name: .hideLoading,
                                                object: nil,
                                                userInfo: nil)
            })
            .disposed(by: disposeBag)
    }
    
    func blockUser(input: Input, disposeBag: DisposeBag) {
        NotificationCenter.default.post(name: .showLoading,
                                        object: nil,
                                        userInfo: nil)
        self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in (self?.userRepository.postUserBlock(state: input.blockUserDanceButton!.isSelected ? 1: -1,
                                                                            userId: self!.userId))! }
            .subscribe(onNext: { [weak self] result in
                if result.data.state == 1 {
                    DispatchQueue.main.async {
                        input.boostButton?.changeBoostButtonDisabled()
                        input.followButton?.isFollowingButtonUnselected()
                        input.followButton?.isButtonDisabled()
                    }
                } else {
                    DispatchQueue.main.async {
                        input.boostButton?.changeBoostButtonEnabled()
                        input.followButton?.didButtonEnabled()
                    }
                }
                print(result)
                NotificationCenter.default.post(name: .hideLoading,
                                                object: nil,
                                                userInfo: nil)
            })
            .disposed(by: disposeBag)
    }
    
    func getVideoDynamicLink(input: Input, type: ShareType, disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap { _ in self.videoRepository.getVideoDynamicLink(videoId: self.videoId) }
            .withUnretained(self)
            .subscribe(onNext: { (_, data) in
                self.videoDynamicLink = data.data.dynamiclink
                if type == .link {
                    self.copyLink(link: self.videoDynamicLink)
                    self.isCopyCompleteRelay.accept(())
                } else {
                    self.isReadyToShareRelay.accept(self.videoDynamicLink)
                }
                
            })
            .disposed(by: disposeBag)
    }
    
    func getUserDynamicLink(input: Input, type: ShareType, disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap { _ in self.userRepository.getUserDynamicLink(userId: self.userId)}
            .withUnretained(self)
            .subscribe(onNext: { (_, data) in
                self.userDynamicLink = data.data.dynamiclink
                if type == .link {
                    self.copyLink(link: self.userDynamicLink)
                    self.isCopyCompleteRelay.accept(())
                } else {
                    self.isReadyToShareRelay.accept(self.userDynamicLink)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func getVideoInfo(input: Input, disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap { _ in self.videoRepository.getVideoInfo(videoId: self.videoId)}
            .withUnretained(self)
            .subscribe(onNext: { (_, data) in
                self.score = data.items[0].score
                self.videoUrl = data.items[0].videoURL ?? ""
                self.stepinId = data.items[0].identifierName
                
                FFmpegHelper.saveUserVideo(videoUrl: self.videoUrl,
                                           score: self.score,
                                           stepinId: self.stepinId)
                NotificationCenter.default.post(name: .didSaveVideoStart,
                                                object: false,
                                                userInfo: nil)
            })
            .disposed(by: disposeBag)
    }
    
    func copyLink(link: String) {
        UIPasteboard.general.string = link
    }
    
    func deleteVideo(disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap { _ in self.videoRepository.deleteVideo(videoId: self.videoId) }
            .withUnretained(self)
            .subscribe(onNext: { _ in
                print("delete Success")
                NotificationCenter.default.post(name: .didDeleteVideo,
                                                object: nil,
                                                userInfo: nil)
            })
            .disposed(by: disposeBag)
    }
    
    func getBoostIsPossible(userId: String,
                            disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap { _ in self.userRepository.getBoostIsPossible() }
            .withUnretained(self)
            .subscribe(onNext: { (vm, result) in
                if result.data.possible {
                    self.patchUserBoost(userId: userId,
                                        disposeBag: disposeBag)
                    .subscribe(onSuccess: { state in
                        vm.isBoostSuccess.accept(state)
                    })
                    .disposed(by: disposeBag)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func patchUserBoost(userId: String,
                        disposeBag: DisposeBag) -> Single<Bool> {
        NotificationCenter.default.post(name: .showLoading,
                                        object: nil,
                                        userInfo: nil)
        return self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap { _ in self.userRepository.patchBoostUser(userId: userId) }
            .withUnretained(self)
            .map { (vm, result) in
                NotificationCenter.default.post(name: .hideLoading,
                                                object: nil,
                                                userInfo: nil)
                return result.statusCode == 200
            }
            .catchAndReturn(false)
            .asSingle()
    }
    
    
}
