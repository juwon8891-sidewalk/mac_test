import UIKit
import Then
import SnapKit

enum SignOutAlertType {
    case signOut
    case deleteAccount
}

class SignOutAlertView: UIView {
    var okButtonCompletion: (() -> Void)?
    var cancelButtonCompletion: (() -> Void)?
    var blurViewTouchCompletion: (() -> Void)?
    var type: SignOutAlertType?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(type: SignOutAlertType) {
        super.init(frame: .zero)
        self.backgroundColor = .clear
        self.type = type

        if type == .signOut {
            self.signOutSetLayout()
            self.titleLabel.text = "setting_signout_Title".localized()
            self.descriptionLabel.text = "setting_signout_description".localized()
            self.titleLabel.textColor = .stepinRed100
        } else {
            self.deleteAccountSetLayout()
            self.titleLabel.text = "setting_withdrawal_Title".localized()
            self.descriptionLabel.text = "setting_withdrawal_description".localized()
            self.titleLabel.textColor = .stepinWhite100
        }
    }
    
    private func signOutSetLayout() {
        self.addSubviews([blurView, contentBackGroundView])
        
        blurView.snp.remakeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
  
        contentBackGroundView.snp.remakeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.equalTo(ScreenUtils.setWidth(value: 272))
            $0.height.equalTo(ScreenUtils.setWidth(value: 173))
        }
        
        contentBackGroundView.addSubviews([titleLabel, descriptionLabel, cancelButton, okButton, stepinIdTextField])
        titleLabel.snp.remakeConstraints {
            $0.top.equalToSuperview().offset(ScreenUtils.setWidth(value: 24))
            $0.centerX.equalToSuperview()
        }
        
        descriptionLabel.snp.remakeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 16))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
        }
        
        cancelButton.snp.remakeConstraints {
            $0.leading.equalTo(contentBackGroundView.snp.leading).offset(ScreenUtils.setWidth(value: 16))
            $0.bottom.equalTo(contentBackGroundView.snp.bottom).inset(ScreenUtils.setHeight(value: 16))
            $0.height.equalTo(ScreenUtils.setWidth(value: 48))
            $0.width.equalTo(ScreenUtils.setWidth(value: 112))
        }
        okButton.snp.remakeConstraints {
            $0.bottom.equalTo(contentBackGroundView.snp.bottom).inset(ScreenUtils.setHeight(value: 16))
            $0.trailing.equalTo(contentBackGroundView.snp.trailing).inset(ScreenUtils.setWidth(value: 16))
            $0.height.equalTo(ScreenUtils.setWidth(value: 48))
            $0.width.height.equalTo(cancelButton)
        }
        
    }
    
    
    private func deleteAccountSetLayout() {
        self.addSubviews([blurView, contentBackGroundView])
        blurView.snp.remakeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        contentBackGroundView.snp.remakeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.equalTo(ScreenUtils.setWidth(value: 272))
            $0.height.equalTo(ScreenUtils.setWidth(value: 299))
        }
        
        contentBackGroundView.addSubviews([titleLabel, descriptionLabel, cancelButton, okButton, stepinIdTextField, underLineView])
        titleLabel.snp.remakeConstraints {
            $0.top.equalToSuperview().offset(ScreenUtils.setWidth(value: 24))
            $0.centerX.equalToSuperview()
        }
        descriptionLabel.snp.remakeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 16))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
        }
        
        stepinIdTextField.snp.remakeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(ScreenUtils.setHeight(value: 20))
            $0.leading.equalTo(self.underLineView.snp.leading)
            $0.trailing.equalTo(self.underLineView.snp.trailing)
        }
        underLineView.snp.remakeConstraints {
            $0.top.equalTo(stepinIdTextField.snp.bottom).offset(ScreenUtils.setHeight(value: 4))
            $0.height.equalTo(ScreenUtils.setHeight(value: 1))
            $0.centerX.equalToSuperview()
            $0.width.equalTo(ScreenUtils.setWidth(value: 200))
        }
        
        cancelButton.snp.remakeConstraints {
            $0.leading.equalTo(contentBackGroundView.snp.leading).offset(ScreenUtils.setWidth(value: 16))
            $0.bottom.equalTo(contentBackGroundView.snp.bottom).inset(ScreenUtils.setHeight(value: 16))
            $0.top.equalTo(stepinIdTextField.snp.bottom).offset(ScreenUtils.setHeight(value: 16))
            $0.height.equalTo(ScreenUtils.setWidth(value: 48))
            $0.width.equalTo(ScreenUtils.setWidth(value: 112))
        }
        okButton.snp.remakeConstraints {
            $0.bottom.equalTo(contentBackGroundView.snp.bottom).inset(ScreenUtils.setHeight(value: 16))
            $0.trailing.equalTo(contentBackGroundView.snp.trailing).inset(ScreenUtils.setWidth(value: 16))
            $0.top.equalTo(stepinIdTextField.snp.bottom).offset(ScreenUtils.setHeight(value: 16))
            $0.width.height.equalTo(cancelButton)
        }
        
        let tapEvent = UITapGestureRecognizer(target: self, action: #selector(blurViewTouchEvent))
          tapEvent.cancelsTouchesInView = false
            blurView.addGestureRecognizer(tapEvent)
    }
    
    @objc private func textFieldDidEditing() {
        self.underLineView.backgroundColor = .stepinWhite40
        DispatchQueue.main.async {
            self.contentBackGroundView.snp.remakeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalToSuperview().offset(ScreenUtils.setWidth(value: 150))
                $0.width.equalTo(ScreenUtils.setWidth(value: 272))
                $0.height.equalTo(ScreenUtils.setWidth(value: 299))
            }
        }
    }
    
    private func didWriteStepinIdCorrectly() -> Bool{
        //눌렀을때 틀렸으면 빨강색 부르르 하고 텍스트 내비둠
        //최대한 불편하게
        guard let type = type else {return false}
        if self.stepinIdTextField.text == UserDefaults.standard.string(forKey: UserDefaultKey.identifierName) && type == .deleteAccount{
            //탈퇴 가능
            return true
        }
        else if self.stepinIdTextField.text != UserDefaults.standard.string(forKey: UserDefaultKey.identifierName) && type == .deleteAccount {
            //탈퇴 불가능
            self.shake()
            self.underLineView.backgroundColor = .stepinRed100
            return false
        }
        else {
            return false
        }
    }
    
    @objc private func blurViewTouchEvent() {
        guard let completion = blurViewTouchCompletion else {return}
        completion()
    }
    
    @objc private func didQuitButtonTapped() {
        if let type = self.type {
            if self.didWriteStepinIdCorrectly() && type == .deleteAccount{
                guard let completion = okButtonCompletion else {return}
                completion()
            }
            else if self.type == .signOut {
                guard let completion = okButtonCompletion else {return}
                completion()
            }
        }
    }
    
    @objc private func didLinkButtonTapped() {
        guard let completion = cancelButtonCompletion else {return}
        completion()
    }
    
    private var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    internal var contentBackGroundView = UIView().then {
        $0.backgroundColor = .stepinBlack100
        $0.layer.cornerRadius = ScreenUtils.setWidth(value: 30)
        $0.layer.borderWidth = ScreenUtils.setWidth(value: 1)
        $0.layer.borderColor = UIColor.stepinWhite40.cgColor
        $0.clipsToBounds = true
    }
    private let titleLabel = UILabel().then {
        $0.textColor = .stepinWhite100
        $0.font = .suitExtraBoldFont(ofSize: 20)
        $0.text = ""
    }
    private let descriptionLabel = UILabel().then {
        $0.textColor = .stepinWhite100
        $0.font = .suitMediumFont(ofSize: 16)
        $0.text = ""
        $0.textAlignment = .center
        $0.numberOfLines = 0
        
    }
    private lazy var stepinIdTextField = UITextField().then {
        $0.addTarget(self,
                     action: #selector(textFieldDidEditing),
                     for: .allEditingEvents)
        $0.tintColor = .stepinWhite100
        $0.textColor = .stepinWhite100
        $0.placeholder = "stepin ID"
        $0.textAlignment = .left
        $0.borderStyle = .none
    }
    private let underLineView = UIView().then {
        $0.backgroundColor = .stepinWhite40
    }
    
    
    private lazy var okButton = UIButton().then {
        $0.backgroundColor = .stepinWhite40
        $0.setTitle("setting_alert_ok_button_title".localized(),
                    for: .normal)
        $0.setTitleColor(.stepinWhite100, for: .normal)
        $0.addTarget(self,
                     action: #selector(didQuitButtonTapped),
                     for: .touchUpInside)
        $0.layer.cornerRadius = ScreenUtils.setWidth(value: 24)
        $0.clipsToBounds = true
        $0.titleLabel?.font = .suitMediumFont(ofSize: 16)
        $0.titleLabel?.textAlignment = .center

    }
    private lazy var cancelButton = UIButton().then {
        $0.backgroundColor = .stepinWhite0
        $0.setTitle("setting_alert_cancel_button_title".localized(),
                    for: .normal)
        $0.setTitleColor(.stepinWhite100, for: .normal)
        $0.addTarget(self,
                     action: #selector(didLinkButtonTapped),
                     for: .touchUpInside)
        $0.layer.cornerRadius = ScreenUtils.setWidth(value: 24)
        $0.clipsToBounds = true
        $0.layer.borderWidth = ScreenUtils.setWidth(value: 2)
        $0.layer.borderColor = UIColor.stepinWhite40.cgColor
        $0.titleLabel?.font = .suitMediumFont(ofSize: 16)
        $0.titleLabel?.textAlignment = .center
    }
}
