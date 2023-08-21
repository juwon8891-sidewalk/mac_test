import UIKit
import SDSKit
import Then
import SnapKit

class HashTagView: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    init() {
        super.init(frame: .zero)
        self.firstHashTagInputView.delegate = self
        self.secondHashTagInputView.delegate = self
        self.thirdHashTagInputView.delegate = self
        setLayout()
    }
    
    internal func getHashTags() -> [String] {
        return [(firstHashTagInputView.text ?? ""),
                (secondHashTagInputView.text ?? ""),
                (thirdHashTagInputView.text ?? "")]
    }
    
    internal func isHashTagViewisEditing() -> Bool {
        if self.firstHashTagInputView.isEditing || self.secondHashTagInputView.isEditing || self.thirdHashTagInputView.isEditing {
            return true
        } else {
            return false
        }
    }
    
    internal func changeTextFieldColor(textField: UITextField, color: UIColor, borderWidth: Int) {
        textField.layer.borderColor = color.cgColor
        textField.layer.borderWidth = 2
        textField.textColor = color
    }
    
    private func setLayout() {
        self.tintColor = .stepinWhite100
        self.backgroundColor = .stepinBlack100
        self.addSubviews([titleLabel, subTitleLabel, stackView])
        stackView.addArrangeSubViews([firstHashTagInputView, secondHashTagInputView, thirdHashTagInputView])
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.top.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(ScreenUtils.setWidth(value: 12))
            $0.bottom.equalTo(titleLabel.snp.bottom)
            $0.height.equalTo(ScreenUtils.setWidth(value: 15))
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 20))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.height.equalTo(ScreenUtils.setWidth(value: 33))
        }
        setTextFieldRadius(textField: firstHashTagInputView)
        setTextFieldRadius(textField: secondHashTagInputView)
        setTextFieldRadius(textField: thirdHashTagInputView)
    }
    
    private func setTextFieldRadius(textField: UITextField) {
        textField.setLeftPaddingPoints(ScreenUtils.setWidth(value: 19))
        textField.setRightPaddingPoints(ScreenUtils.setWidth(value: 19))
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.stepinWhite40.cgColor
        textField.layer.cornerRadius = ScreenUtils.setWidth(value: 15)
    }
    
    private var titleLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
        $0.text = "new_dance_view_hashtag_title".localized()
    }
    private var subTitleLabel = UILabel().then {
        $0.font = .suitLightFont(ofSize: 12)
        $0.textColor = .stepinWhite40
        $0.text = "new_dance_view_hashtag_subtitle".localized()
        $0.isHidden = true
    }
    internal var firstHashTagInputView = UITextField().then {
        $0.textColor = .stepinWhite100
        $0.font = .suitMediumFont(ofSize: 16)
    }
    internal var secondHashTagInputView = UITextField().then {
        $0.textColor = .stepinWhite100
        $0.font = .suitMediumFont(ofSize: 16)
    }
    internal var thirdHashTagInputView = UITextField().then {
        $0.textColor = .stepinWhite100
        $0.font = .suitMediumFont(ofSize: 16)
    }
    private var stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = ScreenUtils.setWidth(value: 28)
        $0.distribution = .fillEqually
    }
}

extension HashTagView: UITextFieldDelegate {
    func isBlank(textField: UITextField) -> Bool {
        var result = false
        var isOtherCharHere = false
        textField.text?.forEach { char in
            if char == " " {
                result = true
            } else {
                isOtherCharHere = true
                result = false
            }
        }
        if isOtherCharHere {
            return false
        } else {
            return result
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        textField.textColor = .stepinWhite100
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.stepinWhite100.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.count ?? 0) > 0 && !isBlank(textField: textField){
            textField.text = "#" + (textField.text ?? "")
            textField.layer.borderWidth = 2
            textField.textColor = .SystemBlue
            textField.layer.borderColor = UIColor.SystemBlue.cgColor
        } else {
            textField.text = ""
            textField.layer.borderWidth = 1
            textField.textColor = .stepinWhite100
            textField.layer.borderColor = UIColor.stepinWhite40.cgColor
        }
    }
}
