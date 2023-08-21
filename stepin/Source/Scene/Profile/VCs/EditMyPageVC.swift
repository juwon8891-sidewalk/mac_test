import UIKit
import SDSKit
import SnapKit
import Then
import RxSwift
import PhotosUI
import Lottie

class EditMyPageVC: UIViewController {
    var disposeBag = DisposeBag()
    var viewModel: EditMyPageViewModel?
    var selectedImage = UIImage()
    var configuration = PHPickerConfiguration()
    var changeImage: [UIImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .stepinBlack100
        self.tabBarController?.tabBar.isHidden = true
        setLayout()
        bindViewModel()
        setProfileImage()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initNotificationCenter()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        deInitNotificationCenter()
    }
    
    private func bindViewModel() {
        let output = viewModel?.transform(from: .init(viewDidAppear: self.rx.methodInvoked(#selector(viewWillAppear(_:)))
            .map({ _ in })
            .asObservable(),
                                                      viewDidDisappear: self.rx.methodInvoked(#selector(viewDidDisappear(_:)))
            .map({ _ in })
            .asObservable(),
                                                      idTextField: self.stepinIdTextField,
                                                      nickNameTextField: self.nickNameTextField,
                                                      profileImageTapped: self.profileImageView.rx.tapGesture().asObservable(),
                                                      doneButtonTapped: self.navigationView.rightButton.rx.tap.asObservable(),
                                                      selectProfilePicture: self.bottomAlertView.profileImageSelect.rx.tapGesture().asObservable(),
                                                      selectBackgroundVideo: self.bottomAlertView.backgroundVideoSelect.rx.tapGesture().asObservable(),
                                                      loadingView: self.loadingBackgroundView,
                                                      changePhotoArray: self.changeImage,
                                                      bottomAlertView: self.bottomAlertView,
                                                      videoView: self.backgroundVideoView,
                                                      didBackGroundGradientViewTapped: self.gradientView.rx.tapGesture().asObservable()),
                                          disposeBag: disposeBag)
        output?.doneButtonState
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] state in
                if state {
                    self?.navigationView.setRightButtonTextColor(color: .stepinWhite100)
                } else {
                    self?.navigationView.setRightButtonTextColor(color: .stepinWhite40)
                }
            })
            .disposed(by: disposeBag)
        
        output?.profileImageState
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] state in
                if state {
                    self?.setBottomAlertView()
                } else {
                    self?.removeBottomAlertView()
                }
            })
            .disposed(by: disposeBag)
        
        output?.backGroundVideo
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .asDriver(onErrorJustReturn: (self, ""))
            .drive(onNext: { (_, videoPath) in
                print(videoPath)
                DispatchQueue.main.async {
                    guard let url = URL(string: videoPath) else {return}
                    print(url)
                    self.backgroundVideoView.initVideo(videoPath: url)
                    self.backgroundVideoView.playVideo()
                    self.backgroundImageView.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        self.navigationView.backButtonCompletion = {
            self.navigationController?.popViewController(animated: true)
        }
    }

    private func initNotificationCenter() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc internal func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let yTransition = -keyboardFrame.cgRectValue.height + ScreenUtils.setWidth(value: 190)
            self.view.transform = CGAffineTransform(translationX: 0, y: yTransition)
        }
        
    }
    
    @objc internal func keyboardWillHide(_ notification: Notification) {
        if notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] is NSValue {
            self.view.transform = .identity
        }

    }
    
    private func deInitNotificationCenter() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
    
    private func setProfileImage() {
        if (UserDefaults.standard.string(forKey: UserDefaultKey.profileUrl) ?? "") == "" {
            self.profileImageView.image = SDSIcon.icDefaultProfile
        } else {
            guard let url = URL(string: UserDefaults.standard.string(forKey: UserDefaultKey.profileUrl)!) else {return}
            self.profileImageView.kf.setImage(with: url)
        }
    }
    
    private func setLayout() {
        self.view.addSubviews([backgroundVideoView, backgroundImageView, gradientView, navigationView, profileImageView, stepinIdTextField, nickNameTextField, editProfileImageButton])
        
        backgroundVideoView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setHeight(value: 511))
        }
        backgroundImageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setHeight(value: 511))
        }
        gradientView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setHeight(value: 511))
        }
        
        gradientView.addGradient(size: CGSize(width: UIScreen.main.bounds.width,
                                              height: ScreenUtils.setHeight(value: 511)),
                                 colors: [UIColor.stepinBlack100.cgColor,
                                          UIColor.stepinBlack90.cgColor,
                                          UIColor.stepinBlack70.cgColor,
                                          UIColor.stepinBlack60.cgColor,
                                          UIColor.stepinBlack30.cgColor,
                                          UIColor.clear.cgColor],
                                 startPoint: .bottomCenter,
                                 endPoint: .topCenter)
        
        navigationView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(ScreenUtils.setWidth(value: 60))
        }
        navigationView.setTitle(title: "edit_mypage_navigation_title".localized())
        navigationView.setRightButtonText(text: "edit_mypage_navigation_done_button_title".localized())
        
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom).offset(ScreenUtils.setHeight(value: 146))
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 72))
        }
        profileImageView.layer.borderColor = UIColor.stepinWhite100.cgColor
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.cornerRadius = ScreenUtils.setWidth(value: 72) / 2
        profileImageView.clipsToBounds = true
        
        editProfileImageButton.snp.makeConstraints {
            $0.bottom.equalTo(self.profileImageView.snp.bottom)
            $0.trailing.equalTo(self.profileImageView.snp.trailing)
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 16))
        }
        stepinIdTextField.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(ScreenUtils.setHeight(value: 70))
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 60))
        }
        nickNameTextField.snp.makeConstraints {
            $0.top.equalTo(stepinIdTextField.snp.bottom).offset(ScreenUtils.setHeight(value: 40))
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 60))
        }
        self.view.addSubview(loadingBackgroundView)
        loadingBackgroundView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        loadingBackgroundView.addSubview(loadingView)
        loadingView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        loadingBackgroundView.isHidden = true
    }
    
    private func setBottomAlertView() {
        self.view.addSubview(bottomAlertBackgroundView)
        bottomAlertBackgroundView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        bottomAlertBackgroundView.addSubview(bottomAlertView)
        bottomAlertView.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(ScreenUtils.setWidth(value: 20))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
        }
        bottomAlertView.cancelCompletion = { [weak self] in
            guard let self = self else {return}
            self.removeBottomAlertView()
        }
        bottomAlertView.profileCompletion = { [weak self] in
            guard let self = self else {return}
            self.presentImagePickerView()
            self.bottomAlertBackgroundView.removeFromSuperview()
        }
    }
    
    private func removeBottomAlertView() {
        self.bottomAlertBackgroundView.removeFromSuperview()
    }

    private var backgroundImageView = UIImageView(image: ImageLiterals.profileBackground)
    private var backgroundVideoView = MyPageVideoView(frame: .init(origin: .zero,
                                                                   size: .init(width: UIScreen.main.bounds.width,
                                                                               height: ScreenUtils.setHeight(value: 511))))
    private var gradientView = UIView()
    private var navigationView = TitleNavigationView().then {
        $0.setRightButtonTextColor(color: .stepinWhite40)
    }
    internal var profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    private var editProfileImageButton = UIButton().then {
        $0.setBackgroundImage(ImageLiterals.icAddImage, for: .normal)
    }
    private var stepinIdTextField = EditMyPageTextField(type: .stepinId).then {
        $0.backgroundColor = .clear
    }
    private var nickNameTextField = EditMyPageTextField(type: .nickName).then {
        $0.backgroundColor = .clear
    }
    private var bottomAlertBackgroundView = UIView().then {
        $0.backgroundColor = .stepinBlack50
    }
    private var bottomAlertView = SelectImageAlertView(size: CGSize(width: ScreenUtils.setWidth(value: 343),
                                                                    height: ScreenUtils.setWidth(value: 226)))
    
    private var loadingBackgroundView = UIView().then {
        $0.backgroundColor = .stepinBlack50
    }
    private var loadingView = EditMyPageLoadingView()
}

