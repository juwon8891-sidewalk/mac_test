import UIKit
import SnapKit
import Then

enum ProfileButtonType {
    case editProfile
    case shareProfile
    case follow
    case boost
    case blockUser
}

class ProfileButton: UIButton {
    init(type: ProfileButtonType) {
        super.init(frame: .zero)
        self.backgroundColor = .clear
        self.setTitleColor(.stepinWhite100, for: .normal)
        self.titleLabel?.font = .suitExtraBoldFont(ofSize: 12)
        self.layer.borderColor = UIColor.stepinWhite100.cgColor
        self.layer.borderWidth = 1
        
        switch type {
        case .editProfile:
            self.setTitle("mypage_editProfile_button_title".localized(), for: .normal)
        case .shareProfile:
            self.setTitle("mypage_shareProfileProfile_button_title".localized(), for: .normal)
        case .follow:
            self.setTitle("mypage_follow_button_title".localized(), for: .normal)
            self.setTitle("show_follow_following_button_title".localized(), for: .selected)
            self.backgroundColor = .stepinWhite100
            self.setTitleColor(.stepinBlack100, for: .selected)
        case .boost:
            self.setTitle("mypage_boost_button_title".localized(), for: .normal)
            self.backgroundColor = .stepinWhite20
            self.setTitleColor(.stepinWhite20, for: .normal)
            self.layer.borderWidth = 0
        case .blockUser:
            self.setTitle("mypage_unblock_button_title".localized(), for: .normal)
            self.setTitleColor(.stepinWhite100, for: .normal)
            
            self.setTitle("mypage_block_button_title".localized(), for: .selected)
            self.setTitleColor(.stepinWhite20, for: .selected)
            
            self.backgroundColor = .stepinWhite20
            self.layer.borderWidth = 0
        }
    }
    
    internal func changeBackground(color: UIColor) {
        self.backgroundColor = color
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
