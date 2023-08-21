import UIKit
import SDSKit
import RxSwift
import RxCocoa
import SnapKit
import Then

class VerifyEmailVC: BaseAuthVC {
    var viewModel: VerifyEmailViewModel?
    var findPwdViewModel: FindPasswordViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        setCompletionClosure()
        if self.viewType == .findPassword {
            self.findPasswordViewModel()
            self.setTitleLabel(title: "auth_findpwd_title".localized())
            self.textView.setPlaceHolder(text: "auth_findpwd_placeholder".localized())
        } else {
            self.veryfiBindViewModel()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.textView.textField.becomeFirstResponder()
        }
    }
    
    //MARK: - view Binding
    private func veryfiBindViewModel() {
        let output = self.viewModel?.emailVerifyTransform(from: .init(nextButtonDidTap: self.nextButton.rx.tap.asObservable(),
                                                                      userEmail: self.textView.textField.rx.text.orEmpty.asObservable()),
                                                          disposeBag: disposeBag)
        output?.isEmailFormatted
            .observe(on: MainScheduler.instance)
            .asDriver(onErrorJustReturn: true)
            .drive(onNext: { [weak self] isFormatted in
                if isFormatted {
                    self?.nextButton.buttonState = .enabled
                    self?.nextButton.setTitle("auth_email_Verify_button_title_send".localized(), for: .normal)
                    self?.textView.setBottomLineColor(color: .SystemBlue)
                } else {
                    self?.nextButton.buttonState = .disabled
                    self?.nextButton.setTitle("auth_email_Verify_button_title_send".localized(), for: .normal)
                    self?.textView.setBottomLineColor(color: .stepinRed100)
                }
            })
            .disposed(by: disposeBag)
        
        
        output?.isEmailUnique
            .observe(on: MainScheduler.instance)
            .asDriver(onErrorJustReturn: true)
            .drive(onNext: { [weak self] isUnique in
                if isUnique {
                    self?.nextButton.buttonState = .enabled
                    self?.nextButton.setTitle("auth_email_Verify_button_title_send".localized(), for: .normal)
                    self?.textView.setBottomText(title: "auth_email_Verify_Available_email".localized(), color: .SystemBlue)
                } else {
                    self?.nextButton.buttonState = .disabled
                    self?.nextButton.setTitle("auth_email_Verify_button_title_send".localized(), for: .normal)
                    self?.textView.setBottomLineColor(color: .stepinRed100)
                    self?.textView.setBottomText(title: "auth_email_Verify_noti_alreadyuse".localized(), color: .stepinRed100)
                }
            })
            .disposed(by: disposeBag)
        
        //메일 발송 성공시 confirm 으로 교체
        output?.didEmailVerifySendComplete
            .observe(on: MainScheduler.instance)
            .asDriver(onErrorJustReturn: true)
            .drive(onNext: { [weak self] state in
                //인증 성공시
                if state {
                    self?.nextButton.buttonState = .enabled
                    self?.nextButton.setTitle("auth_email_Verify_button_title_next".localized(), for: .normal)
                    self?.textView.setBottomText(title: "auth_email_Verify_send_complete_description".localized(),
                                                 color: .SystemBlue)
                }
            })
            .disposed(by: disposeBag)
        
        //메일 인증상태 확인 후 처리
        output?.didEmailVerifyComplete
            .observe(on: MainScheduler.instance)
            .asDriver(onErrorJustReturn: true)
            .drive(onNext: { [weak self] state in
                if !state {
                    //실패 시 인증하라고 토스트 띄우기
                    DispatchQueue.main.async {
                        self?.view.makeToast(title: "toast_check_email".localized(),
                                             type: .redX)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        output?.didEmailRemoved
            .observe(on: MainScheduler.instance)
            .asDriver(onErrorJustReturn: true)
            .drive(onNext: { [weak self] state in
                if state {
                    self?.nextButton.buttonState = .disabled
                    self?.nextButton.setTitle("auth_email_Verify_button_title_send".localized(), for: .normal)
                    self?.textView.setBottomLineColor(color: .stepinRed100)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func findPasswordViewModel() {
        let output = self.findPwdViewModel?.transform(from: .init(confirmButtonTap: self.nextButton.rx.tap.asObservable(),
                                                                  emailString: self.textView.textField.rx.text.orEmpty.asObservable()),
                                                      disposeBag: self.disposeBag)
        
        output?.isEmailFormatted
            .observe(on: MainScheduler.instance)
            .asDriver(onErrorJustReturn: true)
            .drive(onNext: { [weak self] isFormatted in
                if isFormatted {
                    self?.nextButton.buttonState = .enabled
                    self?.nextButton.setTitle("auth_email_Verify_button_title_send".localized(), for: .normal)
                    self?.textView.setBottomLineColor(color: .SystemBlue)
                } else {
                    self?.nextButton.buttonState = .enabled
                    self?.nextButton.setTitle("auth_email_Verify_button_title_send".localized(), for: .normal)
                    self?.textView.setBottomLineColor(color: .stepinRed100)
                }
            })
            .disposed(by: disposeBag)
        
        //메일 발송 성공시 confirm 으로 교체
        output?.didEmailVerifySendComplete
            .observe(on: MainScheduler.instance)
            .asDriver(onErrorJustReturn: true)
            .drive(onNext: { [weak self] state in
                //인증 성공시
                if state {
                    self?.nextButton.buttonState = .enabled
                    self?.nextButton.setTitle("auth_email_Verify_button_title_next".localized(), for: .normal)
                }
            })
            .disposed(by: disposeBag)
        
        //메일 인증상태 확인 후 처리
        output?.didEmailVerifyComplete
            .observe(on: MainScheduler.instance)
            .asDriver(onErrorJustReturn: true)
            .drive(onNext: { [weak self] state in
                if !state {
                    //실패 시 인증하라고 토스트 띄우기
                    DispatchQueue.main.async {
                        self?.view.makeToast(title: "toast_check_email".localized(),
                                             type: .redX)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        output?.didEmailRemoved
            .observe(on: MainScheduler.instance)
            .asDriver(onErrorJustReturn: true)
            .drive(onNext: { [weak self] state in
                if state {
                    self?.nextButton.buttonState = .disabled
                    self?.nextButton.setTitle("auth_email_Verify_button_title_send".localized(), for: .normal)
                    self?.textView.setBottomLineColor(color: .stepinRed100)
                }
            })
            .disposed(by: disposeBag)
        output?.isNotExistEmail
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { _ in
                DispatchQueue.main.async {
                    self.view.makeToast(title: "auth_email_not_exist_title".localized(), type: .redX)
                    self.textView.setBottomLineColor(color: .stepinRed100)
                    self.textView.setBottomText(title: "auth_email_not_exist_title".localized(), color: .stepinRed100)
                }
            })
            .disposed(by: disposeBag)
    }
    
    
    //MARK: - config
    private func setLayout() {
        self.navigationView.setTitle(title: "auth_email_Verify_navigation_title".localized())
        self.view.addSubview(textView)
        textView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 40))
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(55)
        }
        textView.setPlaceHolder(text: "auth_email_Verify_placeholder".localized())
        super.setTitleLabel(title: "auth_email_Verify_title".localized())
        
        self.nextButton.buttonState = .disabled
        self.nextButton.setTitle("auth_email_Verify_button_title_send".localized(), for: .normal)
    }
    
    private func setCompletionClosure() {
        self.textView.didCompleteCondition = { state in
            self.viewModel?.isFormComplete = state
            self.findPwdViewModel?.isFormComplete = state
            if !state {
                self.viewModel?.isSendComplete = false
                self.viewModel?.isComplete = false
                self.findPwdViewModel?.isSendComplete = false
            }
        }
    }
    
    
    private var textView = AuthTextFieldView(type: .email)


}
