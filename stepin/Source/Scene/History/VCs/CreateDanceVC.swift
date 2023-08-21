import UIKit
import SDSKit
import RxSwift
import RxRelay
import RxCocoa
import Lottie

class CreateDanceVC: UIViewController {
    var disposeBag = DisposeBag()
    var viewModel: CreateDanceViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLayout()
        self.bindViewModel()
        self.initNotificationCenter()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    private func bindViewModel() {
        let output = viewModel?.transform(from: .init(viewWillAppear: self.rx.methodInvoked(#selector(viewDidAppear(_:)))
            .map({ _ in })
            .asObservable(),
                                                      backButtonTapped: self.navigationView.backButton.rx.tap.asObservable(),
                                                      previewImageTapped: self.previewImageView.rx.tapGesture().asObservable(),
                                                      textView: self.inputDescriptionTextView,
                                                      textViewPlaceHolder: self.textViewPlaceHolderLabel,
                                                      hashTagView: self.hashTaginputView,
                                                      alertViewOkButton: self.alertView.okButton,
                                                      displayScoreSwitchSelcted: self.displayScoreSwitch,
                                                      allowCommentSwitchSelected: self.allowCommentSwitch,
                                                      uploadButtonTapped: self.uploadButton.rx.tap.asObservable()),
                                          disposeBag: disposeBag)
        output?.previewImage
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: UIImage())
            .drive(onNext: { [weak self] image in
                self?.previewImageView.image = image
            })
            .disposed(by: disposeBag)
        
        output?.didAlertViewHidden
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] state in
                UIView.animate(withDuration: 0.5, delay: 0) {
                    self?.alertView.isHidden = false
                    self?.alertView.alpha = 1
                }
            })
            .disposed(by: disposeBag)
        
        output?.isLoadingStartFlag
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .bind(onNext: { (vc) in
                self.setAnimateLayout()
            })
            .disposed(by: disposeBag)
        
        output?.isLoadingEndFlag
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .bind(onNext: { (vc, _) in
                vc.removeAnimateLayout()
            })
            .disposed(by: disposeBag)
        
        self.alertView.cancelButtonTappedCompletion = {
            UIView.animate(withDuration: 0.5, delay: 0) {
                self.alertView.alpha = 0
            } completion: { _ in
                self.alertView.isHidden = true
            }
        }
        
        output?.showToastMessage
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .bind(onNext: { (vc, title) in
                vc.showToast(icon: SDSIcon.icToastFail, description: "history_upload_fail_title".localized())
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeAnimateLayout()
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
        self.view.transform = .identity
        if self.hashTaginputView.isHashTagViewisEditing() {
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let yTransition = -keyboardFrame.cgRectValue.height
                self.view.transform = CGAffineTransform(translationX: 0, y: yTransition / 2)
            }
        }
    }
    
    @objc internal func keyboardWillHide(_ notification: Notification) {
        if notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] is NSValue {
            self.view.transform = .identity
        }
    }
    
    private func setLayout() {
        self.view.backgroundColor = .stepinBlack100
        self.view.addSubviews([navigationView, previewImageView, inputDescriptionTextView, bottomGradientView, hashTaginputView, displayScoreLabel, displayScoreSwitch, uploadButton, allowCommentLabel, allowCommentSwitch])
        
        self.navigationView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(ScreenUtils.setWidth(value: 60))
        }
        self.navigationView.setTitle(title: "new_dance_view_navigation_title".localized())
        self.previewImageView.snp.makeConstraints {
            $0.top.equalTo(self.navigationView.snp.bottom).offset(ScreenUtils.setWidth(value: 20))
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.width.equalTo(ScreenUtils.setWidth(value: 102))
            $0.height.equalTo(ScreenUtils.setWidth(value: 174))
        }
        previewImageView.layer.cornerRadius = ScreenUtils.setWidth(value: 10)
        previewImageView.layer.borderWidth = 1
        previewImageView.layer.borderColor = UIColor.stepinWhite100.cgColor
        previewImageView.clipsToBounds = true
        
        self.inputDescriptionTextView.snp.makeConstraints {
            $0.top.equalTo(previewImageView.snp.top)
            $0.bottom.equalTo(previewImageView.snp.bottom)
            $0.leading.equalTo(previewImageView.snp.trailing).offset(ScreenUtils.setWidth(value: 12))
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 20))
        }
        self.inputDescriptionTextView.addSubview(textViewPlaceHolderLabel)
        textViewPlaceHolderLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 5))
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(ScreenUtils.setWidth(value: 225))
        }
        textViewPlaceHolderLabel.sizeToFit()
        
        self.bottomGradientView.snp.makeConstraints {
            $0.top.equalTo(previewImageView.snp.bottom).offset(ScreenUtils.setWidth(value: 20))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.height.equalTo(1)
        }
        self.hashTaginputView.snp.makeConstraints {
            $0.top.equalTo(bottomGradientView.snp.bottom).offset(ScreenUtils.setWidth(value: 42))
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 73))
        }
        
        self.displayScoreLabel.snp.makeConstraints {
            $0.top.equalTo(self.allowCommentLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 30))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
        }
        self.displayScoreSwitch.snp.makeConstraints {
            $0.centerY.equalTo(displayScoreLabel)
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.width.equalTo(ScreenUtils.setWidth(value: 60))
            $0.height.equalTo(ScreenUtils.setWidth(value: 30))
        }
        self.allowCommentLabel.snp.makeConstraints {
            $0.top.equalTo(self.hashTaginputView.snp.bottom).offset(ScreenUtils.setWidth(value: 40))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.height.equalTo(ScreenUtils.setWidth(value: 30))
        }
        self.allowCommentSwitch.snp.makeConstraints {
            $0.centerY.equalTo(allowCommentLabel)
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.width.equalTo(ScreenUtils.setWidth(value: 60))
            $0.height.equalTo(ScreenUtils.setWidth(value: 30))
        }
        self.uploadButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(ScreenUtils.setWidth(value: 20))
            $0.centerX.equalToSuperview()
            $0.width.equalTo(ScreenUtils.setWidth(value: 200))
            $0.height.equalTo(ScreenUtils.setWidth(value: 48))
        }
        uploadButton.clipsToBounds = true
        
        self.view.addSubview(alertView)
        alertView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        alertView.alertContentView.layer.cornerRadius = ScreenUtils.setWidth(value: 30)
        alertView.alertContentView.clipsToBounds = true
        
        alertView.alpha = 0
        alertView.isHidden = true
    }
    
    private func setAnimateLayout() {
        self.view.addSubviews([backGroundBlurView, loadingView])
        backGroundBlurView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        loadingView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 100))
        }
        loadingView.loopMode = .loop
        loadingView.play()
    }
    
    private func removeAnimateLayout() {
        self.loadingView.stop()
        self.backGroundBlurView.removeFromSuperview()
        self.loadingView.removeFromSuperview()
    }
    
    private var navigationView = TitleNavigationView()
    private var previewImageView = UIImageView()
    private var inputDescriptionTextView = UITextView().then {
        $0.backgroundColor = .stepinBlack100
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textContainerInset = .zero
    }
    private var textViewPlaceHolderLabel = UILabel().then {
        $0.textColor = .stepinWhite40
        $0.font = .suitMediumFont(ofSize: 16)
        $0.text = "new_dance_view_place_holder".localized()
        $0.lineBreakMode = .byCharWrapping
        $0.numberOfLines = 0
    }
    
    private var bottomGradientView = HorizontalGradientView(width: ScreenUtils.setWidth(value: 343))
    private var hashTaginputView = HashTagView()
    
    private var displayScoreLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
        $0.text = "new_dance_view_display_title".localized()
    }
    private var displayScoreSwitch = UISwitch().then {
        $0.setOn(true, animated: false)
        $0.onTintColor = .SystemBlue
        $0.backgroundColor = .clear
    }
    private var allowCommentLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
        $0.text = "new_dance_view_allowComment_title".localized()
    }
    private var allowCommentSwitch = UISwitch().then {
        $0.setOn(true, animated: false)
        $0.onTintColor = .SystemBlue
        $0.backgroundColor = .clear
    }
    private var uploadButton = SDSCategoryButton(type: .largeExtraBold).then {
        $0.backgroundColor = .PrimaryBlackNormal
        $0.layer.cornerRadius = 24.adjusted
        $0.layer.borderColor = UIColor.PrimaryWhiteNormal.cgColor
        $0.layer.borderWidth = 2
        $0.setTitle("new_dance_view_upload_button_title".localized(), for: .normal)
    }
    
    private var alertView = CreateDanceAlertView()
    
    private var backGroundBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private var loadingView = LottieAnimationView(name: "skeleton-walking")

}
