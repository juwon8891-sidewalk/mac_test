import UIKit
import SDSKit
import SnapKit
import Then
import RxSwift

enum SettingCellType {
    case toggleCell
    case arrowCell
    case versionCell
    case logoutCell
    case withdrawlCell
}

class SettingTVC: UITableViewCell {
    static let identifier: String = "SettingTVC"
    
    var version: String? {
        guard let dictionary = Bundle.main.infoDictionary,
            let version = dictionary["CFBundleShortVersionString"] as? String,
            let build = dictionary["CFBundleVersion"] as? String else {return nil}

        let versionAndBuild: String = "\(version)"
        return versionAndBuild
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func setData(title: String, description: String, type: SettingCellType, tag: Int) {
        self.titleLabel.text = title
        self.descriptionLabel.text = description
        self.setComponentTag(type: type, tag: tag)
        self.setLayout(type: type, tag: tag)
        if type == .versionCell {
            self.versionLabel.text = version ?? ""
        }
    }

    private func setLayout(type: SettingCellType, tag: Int) {
        self.selectionStyle = .none
        setRemoveReusableView(tag: tag)
        self.addSubviews([titleLabel, descriptionLabel])
        self.backgroundColor = .stepinBlack100
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.top.equalToSuperview().offset(ScreenUtils.setWidth(value: 20))
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 4))
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.bottom.equalToSuperview().inset(ScreenUtils.setWidth(value: 20))
        }
        switch type {
        case .toggleCell:
            self.addSubview(toggleButton)
            toggleButton.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalTo(descriptionLabel.snp.trailing).offset(ScreenUtils.setWidth(value: 24))
                $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
                $0.width.equalTo(ScreenUtils.setWidth(value: 60))
            }
        case .arrowCell:
            self.addSubview(rightArrowButton)
            titleLabel.snp.remakeConstraints {
                $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
                $0.top.equalToSuperview().offset(ScreenUtils.setWidth(value: 30))
                $0.height.equalTo(ScreenUtils.setWidth(value: 20))
            }
            descriptionLabel.snp.remakeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 4))
                $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
                $0.bottom.equalToSuperview().inset(ScreenUtils.setWidth(value: 30))
            }
            rightArrowButton.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.top.bottom.trailing.equalToSuperview()
                $0.width.equalTo(ScreenUtils.setWidth(value: 48))
            }
        case .versionCell:
            self.addSubview(versionLabel)
            versionLabel.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
                $0.height.equalTo(ScreenUtils.setWidth(value: 20))
            }
        case .logoutCell:
            setRemoveReusableView(tag: tag)
            
        case .withdrawlCell:
            setRemoveReusableView(tag: tag)
        }
    }
    
    private func setComponentTag(type: SettingCellType, tag: Int) {
        self.titleLabel.tag = tag
        self.descriptionLabel.tag = tag
        if type == .toggleCell {
            self.toggleButton.tag = tag
        }
        else if type == .arrowCell {
            self.rightArrowButton.tag = tag
        }
        else if type == .versionCell {
            self.versionLabel.tag = tag
        }
    }
    
    private func setRemoveReusableView(tag: Int) {
        if toggleButton.tag != tag {
            toggleButton.isHidden = true
        } else {
            toggleButton.isHidden = false
        }
        if versionLabel.tag != tag {
            versionLabel.isHidden = true
        } else {
            versionLabel.isHidden = false
        }
        if rightArrowButton.tag != tag {
            rightArrowButton.isHidden = true
        } else {
            rightArrowButton.isHidden = false
        }
        if titleLabel.tag == 6 {
            self.titleLabel.textColor = .stepinRed100
        } else {
            self.titleLabel.textColor = .stepinWhite100
        }
    }
    
    private var titleLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
        $0.textAlignment = .left
    }
    
    private var descriptionLabel = UILabel().then {
        $0.font = .suitRegularFont(ofSize: 12)
        $0.textColor = .stepinWhite40
        $0.textAlignment = .left
        $0.numberOfLines = 0
    }
    
    private lazy var toggleButton = UISwitch().then {
        $0.onTintColor = .SystemBlue
        $0.backgroundColor = .clear
    }
    
    private lazy var rightArrowButton = UIButton().then {
        $0.setImage(ImageLiterals.icRightArrow, for: .normal)
    }
    private lazy var versionLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
    }
}
