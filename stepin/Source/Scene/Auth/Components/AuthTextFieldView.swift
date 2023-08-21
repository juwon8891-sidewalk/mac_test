import Foundation
import UIKit
import SDSKit
import SnapKit
import Then
import RxSwift

enum TextFiledType {
    case email
    case login_email
    case id
    case password
    case login_password
}

class AuthTextFieldView: GeneralAuthTextView {
    var didCompleteCondition: ((Bool) -> Void)?
    var passwordOptionCondition: (([Bool]) -> Void)?
    private var type: TextFiledType?
    var disposeBag = DisposeBag()
    private var viewModel = AuthTextFieldViewModel()
    private var passwordOptions: [Bool] = [false, false, false]
    
    init(type: TextFiledType) {
        super.init(frame: .zero)
        self.type = type
        
        switch type {
        case .password, .login_password:
            self.textFieldButton.setBackgroundImage(SDSIcon.icViewOff, for: .normal)
            self.textFieldButton.setBackgroundImage(SDSIcon.icViewOn, for: .selected)
            self.textField.isSecureTextEntry = true
        default:
            self.textField.keyboardType = .emailAddress
            self.textFieldButton.setBackgroundImage(SDSIcon.icClearActive, for: .normal)
        }

        setLayout()
        bindAuthViewModel()
        bindViewModel()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    //MARK: viewModelBinding
    private func bindViewModel() {
        let output = self.viewModel.textFieldTransform(from: .init(textFieldDidEditing: self.textField.rx.text.orEmpty.asObservable(),
                                                                   textFieldDidClear: self.textField.rx.observe(String.self, "text").asObservable()),
                                                       disposeBag: disposeBag)
        output.currentTextFieldState
            .asDriver()
            .drive(onNext: { [weak self] state in
                if state == .empty {
                    self?.textFieldButton.isHidden = true
                    self?.setBottomLineColor(color: .stepinWhite100)
                    self?.setBottomText(title: "", color: .clear)
                    self?.completeCompletion(state: false)
                } else {
                    self?.textFieldButton.isHidden = false
                }
            })
            .disposed(by: disposeBag)
        
        
    }
    private func bindAuthViewModel() {
        let output = self.viewModel.authTextFieldTransform(from: .init(type: self.type!,
                                                                       obserbe: self.textField.rx.text.orEmpty.asObservable()),
                                                           disposeBag: disposeBag)
        output.authTextFieldState
            .asDriver()
            .drive(onNext: { [weak self] state in
                switch state {
                case .unformatted_email_form:
                    self?.setBottomLineColor(color: .stepinRed100)
                    self?.setBottomText(title: "", color: .stepinRed100)
                    self?.completeCompletion(state: false)

                case .formatted_email:
                    if self?.type != .login_email {
                        self?.setBottomLineColor(color: .SystemBlue)
                        self?.setBottomText(title: "auth_email_Verify_Available_email".localized(), color: .SystemBlue)
                    } else {
                        self?.setBottomLineColor(color: .white)
                    }
                    self?.completeCompletion(state: true)
                    
                case .unformatted_email_dupplicated:
                    self?.setBottomLineColor(color: .stepinRed100)
                    self?.setBottomText(title: "auth_email_Verify_noti_alreadyuse".localized(), color: .stepinRed100)
                    self?.completeCompletion(state: false)
                    
                case .unformatted_password_contain_alphabet:
                    self?.passwordOptions[0] = false
                    self?.setBottomLineColor(color: .PrimaryWhiteNormal)
                    self?.passwordConditionCompletion()
                    
                case .formatted_password_contain_alphabet:
                    self?.passwordOptions[0] = true
                    self?.setBottomLineColor(color: .SystemBlue)
                    self?.passwordConditionCompletion()
                    
                case .unformatted_password_contain_number:
                    self?.passwordOptions[1] = false
                    self?.setBottomLineColor(color: .PrimaryWhiteNormal)
                    self?.passwordConditionCompletion()
                    
                case .formatted_password_contain_number:
                    self?.passwordOptions[1] = true
                    self?.setBottomLineColor(color: .SystemBlue)
                    self?.passwordConditionCompletion()
                    self?.completeCompletion(state: true)
                    
                case .unformatted_password_length:
                    self?.passwordOptions[2] = false
                    self?.setBottomLineColor(color: .PrimaryWhiteNormal)
                    self?.passwordConditionCompletion()
                    
                case .formatted_password_length:
                    self?.passwordOptions[2] = true
                    self?.setBottomLineColor(color: .SystemBlue)
                    self?.passwordConditionCompletion()
                    self?.completeCompletion(state: true)
                    
                case .unformatted_id:
                    self?.setBottomLineColor(color: .stepinRed100)
                    self?.setBottomText(title: "auth_id_default_noti".localized(), color: .stepinRed100)
                case .unformatted_dupplicated_id:
                    self?.setBottomLineColor(color: .stepinRed100)
                    self?.setBottomText(title: "auth_id_contain_already_use_noti".localized(), color: .stepinRed100)
                case .formatted_id:
                    UserDefaults.standard.set(self?.textField.text, forKey: UserDefaultKey.identifierName)
                    self?.setBottomText(title: "auth_id_contain_Complete_noti".localized(), color: .SystemBlue)
                    self?.setBottomLineColor(color: .SystemBlue)
                    self?.completeCompletion(state: true)
                
                case .formatted_login_pwd:
                    self?.setBottomLineColor(color: .SystemBlue)
                    self?.completeCompletion(state: true)
                    
                case .unformatted_login_pwd:
                    self?.setBottomLineColor(color: .stepinRed100)
                    self?.setBottomText(title: "", color: .clear)
                    self?.completeCompletion(state: false)
                    
                default: break
                }
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - UI controll
    @objc private func didTextFieldButtonClicked(_ sender: UIButton) {
        HapticService.shared.playFeedback()
        if self.type! == .login_password || self.type! == .password {
            self.textField.isSecureTextEntry = !self.textField.isSecureTextEntry
        } else {
            self.textField.text = ""
        }
    }
    private func completeCompletion(state: Bool) {
        guard let completion = self.didCompleteCondition else {return}
        completion(state)
    }
    

    private func passwordConditionCompletion() {
        let tokenUtils = TokenUtils()
        tokenUtils.create(account: UserDefaultKey.password, value: self.textField.text ?? "")
        guard let completion = self.passwordOptionCondition else {return}
        completion(self.passwordOptions)
    }
    
    internal func changePwdShowBuutonImage() {
        self.textFieldButton.isSelected = !self.textFieldButton.isSelected
    }
    
    internal func setPlaceHolder(text: String) {
        self.textField.placeholder = text
    }
    
    internal func setBottomText(title: String, color: UIColor) {
        self.bottomText.text = title
        self.bottomText.textColor = color
    }
    
    internal func setBottomLineColor(color: UIColor) {
        self.bottomLine.backgroundColor = color
    }
    
    
    //MARK: - set textFieldConfig
    private func setLayout() {
        self.addSubview(textFieldButton)
        self.initView.addSubview(textField)
        textField.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 25))
        }
        textField.tintColor = .stepinWhite100
        textFieldButton.snp.makeConstraints {
            $0.centerY.equalTo(textField)
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 24))
        }
    }
    
    
    //MARK: - components
    internal var textField = BaseTextField()
    private lazy var textFieldButton = UIButton().then {
        $0.addTarget(self, action: #selector(didTextFieldButtonClicked(_:)), for: .touchUpInside)
    }
}
