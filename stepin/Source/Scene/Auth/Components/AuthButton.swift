import UIKit
import SDSKit
import SnapKit
import Then

class AuthButton: LargeButton {
    init() {
        super.init(frame: .zero)
        self.isUnselectedButton(title: "")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func isUnselectedButton(title: String) {
        self.backgroundColor = .stepinWhite20
        var config = UIButton.Configuration.plain()
        config.attributedTitle = title.setAttributeString(textColor: .stepinWhite40,
                                                          font: .suitExtraBoldFont(ofSize: 20))
        self.configuration = config
    }
    
    internal override func isSelectedButton(title: String) {
        self.backgroundColor = .SystemBlue
        var config = UIButton.Configuration.plain()
        config.attributedTitle = title.setAttributeString(textColor: .stepinWhite100,
                                                          font: .suitExtraBoldFont(ofSize: 20))
        self.configuration = config
    }
}
