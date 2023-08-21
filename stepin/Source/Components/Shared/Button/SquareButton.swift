import UIKit
import SDSKit
import SnapKit
import Then

class SquareButton: UIButton {
    private var title: String = ""
    internal var isDisable: Bool = false
    
    init(title: String, image: UIImage) {
        super.init(frame: .zero)
        self.title = title
        self.backgroundColor = .stepinWhite20
        self.tintColor = .clear
        var config = UIButton.Configuration.plain()
        config.attributedTitle = title.setAttributeString(textColor: .stepinWhite100,
                                                          font: .suitMediumFont(ofSize: 14))
        config.image = image
        config.imagePlacement = .top
        self.configuration = config
        
        self.imageView?.snp.makeConstraints {
            $0.top.equalToSuperview().inset(ScreenUtils.setWidth(value: 14))
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 24))
        }
        self.titleLabel?.snp.makeConstraints {
            $0.top.equalTo(imageView!.snp.bottom).offset(ScreenUtils.setWidth(value: 6))
            $0.centerX.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 17))
        }
    }
    
    func changeBoostButtonDisabled() {
        DispatchQueue.main.async {
            self.isSelected = false
            var config = self.configuration
            config?.attributedTitle = "mypage_bottomsheet_boost".localized().setAttributeString(textColor: .PrimaryWhiteDisabled,
                                                                                                font: SDSFont.menuTitle.font)
            config?.image = ImageLiterals.icBoost_unselect
            self.configuration = config
        }
    }
    
    func changeBoostButtonEnabled() {
        DispatchQueue.main.async {
            self.isSelected = true
            var config = self.configuration
            config?.attributedTitle = "mypage_bottomsheet_boost".localized().setAttributeString(textColor: .PrimaryWhiteNormal,
                                                                                                font: SDSFont.menuTitle.font)
            config?.image = ImageLiterals.icBoost_select
            self.configuration = config
        }
    }
    
    internal func isButtonTextColorChange(color: UIColor) {
        var config = self.configuration
        config?.attributedTitle = title.setAttributeString(textColor: color,
                                                           font: .suitMediumFont(ofSize: 14))
        self.configuration = config
    }
    
    internal func isButtonDisabled() {
        self.isSelected = false
        self.backgroundColor = .stepinWhite20
        var config = self.configuration
        config?.attributedTitle = title.setAttributeString(textColor: .stepinWhite20,
                                                           font: .suitMediumFont(ofSize: 14))
        config?.image = ImageLiterals.icFollow_unselect
        self.configuration = config
        self.isDisable = true
    }
    
    internal func didButtonEnabled() {
        self.isSelected = false
        var config = self.configuration
        config?.attributedTitle = title.setAttributeString(textColor: .stepinWhite100,
                                                           font: .suitMediumFont(ofSize: 14))
        config?.image = ImageLiterals.icFollow_select
        self.configuration = config
        self.isDisable = false
    }
    
    internal func isFollowingButtonSelected() {
        self.isSelected = true
        self.backgroundColor = .stepinWhite20
        var config = self.configuration
        self.title = "mypage_bottomsheet_following".localized()
        config?.attributedTitle = title.setAttributeString(textColor: .stepinWhite100,
                                                          font: .suitMediumFont(ofSize: 14))
        config?.image = ImageLiterals.icFollowing
        self.configuration = config
    }
    
    internal func isFollowingButtonUnselected() {
        self.isSelected = false
        var config = self.configuration
        self.title = "mypage_bottomsheet_follow".localized()
        config?.attributedTitle = title.setAttributeString(textColor: .stepinWhite100,
                                                          font: .suitMediumFont(ofSize: 14))
        config?.image = ImageLiterals.icFollow_select
        self.configuration = config
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
