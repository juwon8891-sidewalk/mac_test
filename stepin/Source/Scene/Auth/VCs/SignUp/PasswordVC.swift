import UIKit
import RxSwift
import SnapKit
import Then
import RxCocoa

class PasswordVC: BaseAuthVC {
    var viewModel: PasswordViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        bindViewModel()
        setCompleteClosure()
        passwordOptionClosure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.textView.textField.becomeFirstResponder()
        }
    }
    
    //MARK: - bind View model
    private func bindViewModel() {
        self.viewModel?.viewType = self.viewType
        let output = self.viewModel?.passwordTransform(from: .init(nextButtonDidTap: nextButton.rx.tap.asObservable(),
                                                                   passwordTextFieldInPut: textView.textField.rx.text.orEmpty.asObservable()),
                                                       disposeBag: disposeBag)
        output?.didResetPasswordState
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                if !state {
                    self?.view.makeToast(title: "ResetPassword failed", type: .redX)
                }
            })
            .disposed(by: disposeBag)
        
        output?.passwoardTextFieldOut
            .observe(on: MainScheduler.instance)
            .bind(onNext: { text in
                print("입력한 패스워드: ",text)
                self.textView.setBottomLineColor(color: .PrimaryWhiteNormal)
                UserDefaults.standard.set(text, forKey: UserDefaultKey.password)
            })
            .disposed(by: disposeBag)
        
    }
    
    //MARK: - config
    private func setLayout() {
        self.view.addSubviews([textView, alphabetOptionButton, numberOptionButton, countOptionButton])
        textView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 40))
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(30)
        }
        
        alphabetOptionButton.snp.makeConstraints {
            $0.top.equalTo(textView.snp.bottom).offset(8.adjusted)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(17.adjusted)
        }
        
        numberOptionButton.snp.makeConstraints {
            $0.top.equalTo(alphabetOptionButton.snp.bottom).offset(8.adjusted)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(17.adjusted)
        }
        
        countOptionButton.snp.makeConstraints {
            $0.top.equalTo(numberOptionButton.snp.bottom).offset(8.adjusted)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(17.adjusted)
        }
        super.setTitleLabel(title: "auth_password_title".localized())
        super.setNextButtonTitle(title: "auth_password_button_title".localized())
        self.navigationView.setTitle(title: "auth_email_Verify_navigation_title".localized())
    }
    
    private func setCompleteClosure() {
        textView.didCompleteCondition = { state in
            self.viewModel?.isComplete = state
            if state {
                self.nextButton.setTitle("auth_password_button_title".localized(), for: .normal)
                self.nextButton.buttonState = .enabled
            } else {
                self.nextButton.setTitle("auth_password_button_title".localized(), for: .normal)
                self.nextButton.buttonState = .disabled
            }
        }
    }
    private func passwordOptionClosure() {
        textView.passwordOptionCondition = { options in
            options[0] ? self.alphabetOptionButton.changeSelectedColor(): self.alphabetOptionButton.changeDefaultColor()
            options[1] ? self.numberOptionButton.changeSelectedColor(): self.numberOptionButton.changeDefaultColor()
            options[2] ? self.countOptionButton.changeSelectedColor(): self.countOptionButton.changeDefaultColor()
        }
    }
 
    private var textView = AuthTextFieldView(type: .password)
    private var alphabetOptionButton = OptionTextButton(type: .alphabet)
    private var numberOptionButton = OptionTextButton(type: .number)
    private var countOptionButton = OptionTextButton(type: .count)
    
}
