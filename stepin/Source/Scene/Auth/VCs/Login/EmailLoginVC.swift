import UIKit
import RxSwift
import SnapKit
import Then


class EmailLoginVC: BaseAuthVC {
    var emailLoginViewModel: EmailLoginViewModel?
    var pwdState: Bool = false
    var emailState: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        bindViewModel()
        emailCompleteClosure()
        pwdCompleteClousre()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.emailTextView.textField.becomeFirstResponder()
        }
    }
    

    
    //MARK: - bind View Model
    private func bindViewModel() {
        let output = self.emailLoginViewModel?.emailLoginTransform(from: .init(didForgotPwdButtonTap: self.forgotPwdButton.rx.tap.asObservable(),
                                                                               didLoginButtonTap: self.nextButton.rx.tap.asObservable(),
                                                                               emailString: self.emailTextView.textField.rx.text.orEmpty.asObservable(),
                                                                               passwordString: self.pwdTextView.textField.rx.text.orEmpty.asObservable()),
                                                                               disposeBag: disposeBag)
        output?.loginFailed
            .observe(on: MainScheduler.instance)
            .asDriver(onErrorJustReturn: true)
            .drive(onNext: { [weak self] state in
                if state {
                    self?.pwdTextView.textField.text = ""
                    self?.pwdTextView.setBottomText(title: "auth_email_login_incorrect_noti".localized(), color: .stepinRed100)
                    self?.pwdTextView.setBottomLineColor(color: .stepinRed100)
                } else {
                    self?.view.makeToast(title: "Login Success", type: .blueCheck)
                    self?.emailLoginViewModel?.coordinator?.homeMove()
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    override func keyboardWillShow(_ notification: Notification) {
        super.keyboardWillShow(notification)
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let yTransition = -keyboardFrame.cgRectValue.height + ScreenUtils.setWidth(value: 23)
            self.forgotPwdButton.transform = CGAffineTransform(translationX: 0, y: yTransition)
        }
    }
    
    override func keyboardWillHide(_ notification: Notification) {
        super.keyboardWillHide(notification)
        if notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] is NSValue {
            self.forgotPwdButton.transform = .identity
        }
    }
    
    
    private func emailCompleteClosure() {
        self.emailTextView.didCompleteCondition = { emailState in
            self.emailState = emailState
            self.isCompleteLogin()
        }
    }
    
    private func pwdCompleteClousre() {
        self.pwdTextView.didCompleteCondition = { pwdState in
            self.pwdState = pwdState
            self.isCompleteLogin()
        }
    }
    
    private func isCompleteLogin() {
        if emailState && pwdState {
            self.emailLoginViewModel?.isComplete = true
            self.nextButton.buttonState = .enabled
            self.nextButton.setTitle("auth_email_login_login_button_title".localized(), for: .normal)
        } else {
            self.emailLoginViewModel?.isComplete = false
            self.nextButton.buttonState = .disabled
            self.nextButton.setTitle("auth_email_login_login_button_title".localized(), for: .normal)
        }
    }
    
    //MARK: - config layout
    private func setLayout() {
        self.view.addSubviews([emailTextView, pwdTextView, forgotPwdButton])
        emailTextView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 40))
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 30))
        }
        emailTextView.setPlaceHolder(text: "auth_email_login_id_placeholder".localized())
        pwdTextView.snp.makeConstraints {
            $0.top.equalTo(emailTextView.snp.bottom).offset(ScreenUtils.setWidth(value: 20))
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 40))
        }
        pwdTextView.setPlaceHolder(text: "auth_email_login_pwd_placeholder".localized())
        forgotPwdButton.snp.makeConstraints {
            $0.bottom.equalTo(nextButton.snp.top).inset(-ScreenUtils.setWidth(value: 20))
            $0.centerX.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 15))
        }
        self.nextButton.buttonState = .disabled
        self.nextButton.setTitle("auth_email_login_login_button_title".localized(), for: .normal)
        super.setTitleLabel(title: "auth_email_login_title".localized())
    }
    
    
    internal var emailTextView = AuthTextFieldView(type: .login_email)
    private var pwdTextView = AuthTextFieldView(type: .login_password)
    private var forgotPwdButton = UIButton().then {
        let attributedString = NSMutableAttributedString(string: "auth_email_login_forgot_button_title".localized())
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(.foregroundColor, value: UIColor.stepinWhite40, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(.font, value: UIFont.suitRegularFont(ofSize: 12), range: NSRange(location: 0, length: attributedString.length))
        $0.setAttributedTitle(attributedString, for: .normal)
    }
}
