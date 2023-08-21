import SnapKit
import Then
import Lottie
import RxSwift
import SDSKit
import AuthenticationServices
import FirebaseAuth

class LoginVC: UIViewController {
    var loginViewModel: LoginViewModel?
    let disposeBag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        videoView.playVideo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .stepinBlack100
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        setLayout()
        bindViewModel()
        setVideoViewData()
        
        videoView.playVideo()
        videoView.setLoadingViewHidden()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.videoView.pauseVideo()
    }
    
    //MARK: - bind ViewModel
    private func bindViewModel() {
        let output = self.loginViewModel?.transform(from: .init(googleLoginButtonDidTap: self.googleLoginButton.rx.tap.asObservable(),
                                                                faceBookLoginButtonDidTap: self.facebookLoginButton.rx.tap.asObservable(),
                                                                appleLoginButtonDidTap: self.appleLoginButton.rx.tap.asObservable(),
                                                                emailLoginButtonDidTap: self.emailLoginButton.rx.tap.asObservable(),
                                                                loginWithEmailButtonDidTap: self.loginWithEmailButton.rx.tap.asObservable(),
                                                                backButtonDidTap: self.backButton.rx.tap.asObservable()),
                                                    disposeBag: self.disposeBag)
        output?.indicatorStatus
            .withUnretained(self)
            .asDriver(onErrorJustReturn: (LoginVC(), false))
            .drive(onNext: { (vc,status) in
                DispatchQueue.main.async {
                    if status {
                        self.lottieIndicator.isHidden = false
                        vc.lottieIndicator.play()
                    } else {
                        self.lottieIndicator.isHidden = true
                        vc.lottieIndicator.stop()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        output?.toastMessage
            .withUnretained(self)
            .asDriver(onErrorJustReturn: (LoginVC(),""))
            .drive(onNext: { (vc, value) in
                vc.view?.makeToast(title: value, type: .redX)
            })
            .disposed(by: disposeBag)
    }
    
    private func setVideoViewData() {
        guard let filePath = Bundle.main.path(forResource: "login_splash_movie", ofType: "mp4") else {return}
        let videoURL = URL(filePath: filePath)
        
        self.videoView.initVideo(videoPath: videoURL)
        self.videoHandler = VideoPlayHandler(videoView: videoView)
        self.videoHandler?.delegate = self
    }
    
    //MARK: - Set Layout
    private func setLayout() {
        self.view.addSubviews([lottieIndicator,
                               videoView,
                               loginImageView,
                               googleLoginButton,
                               facebookLoginButton,
                               appleLoginButton,
                               emailLoginButton,
                               loginWithEmailButton])
        videoView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        lottieIndicator.snp.makeConstraints {
            $0.height.width.equalTo(200) // 프로그래스바
            $0.center.equalTo(self.view)
        }
        lottieIndicator.isHidden = true
        loginImageView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(206.adjusted)
            $0.leading.trailing.equalToSuperview().inset(87.adjusted)
            $0.height.equalTo(ScreenUtils.setWidth(value: 44))
        }
        googleLoginButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(40.adjusted)
        }
        googleLoginButton.layer.cornerRadius = 8.adjusted
        facebookLoginButton.snp.makeConstraints {
            $0.top.equalTo(googleLoginButton.snp.bottom).offset(12.adjusted)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(40.adjusted)
        }
        facebookLoginButton.layer.cornerRadius = 8.adjusted
        appleLoginButton.snp.makeConstraints {
            $0.top.equalTo(facebookLoginButton.snp.bottom).offset(12.adjusted)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(40.adjusted)
        }
        appleLoginButton.layer.cornerRadius = 8.adjusted
        emailLoginButton.snp.makeConstraints {
            $0.top.equalTo(appleLoginButton.snp.bottom).offset(12.adjusted)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(40.adjusted)
        }
        emailLoginButton.layer.cornerRadius = 8.adjusted
        loginWithEmailButton.snp.makeConstraints {
            $0.top.equalTo(emailLoginButton.snp.bottom).offset(40.adjusted)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(17.adjusted)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(64.adjusted)
        }
    }
    
    //MARK: - Components
    var videoView = BaseVideoView(frame: .init(origin: .zero,
                                               size: .init(width: UIScreen.main.bounds.width,
                                                           height: UIScreen.main.bounds.height)))
    var videoHandler: VideoPlayHandler?
    
    var lottieIndicator = LottieAnimationView(name: "loading").then {
        $0.loopMode = .loop
    }
    private var loginImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = SDSIcon.icStepinTextLogo
    }
    private var backButton = UIButton().then {
        $0.setImage(ImageLiterals.icWhiteArrow, for: .normal)
    }
    private var googleLoginButton = LoginButton(type: .google)
    private var facebookLoginButton = LoginButton(type: .faceBook)
    private var appleLoginButton = LoginButton(type: .apple)
    private var emailLoginButton = LoginButton(type: .email)
    private var loginWithEmailButton = UIButton().then {
        $0.setTitle("auth_login_button_title".localized(), for: .normal)
        $0.setTitleColor(.stepinWhite40, for: .normal)
        $0.titleLabel?.font = .suitRegularFont(ofSize: 14)
    }
}

extension LoginVC: VideoHandlerDelegate {
    func getCurrentVideo(data: Video) {}
    
    func getCurrentPlayTime(time: Float, totalPlayTime: Float) {
        if time >= totalPlayTime {
            self.videoView.pauseVideo()
            self.videoHandler?.setTimeToVideo(time: 0) { [weak self] _ in
                    guard let strongSelf = self else {return}
                    strongSelf.videoView.playVideo()
            }
        }
    }
}
