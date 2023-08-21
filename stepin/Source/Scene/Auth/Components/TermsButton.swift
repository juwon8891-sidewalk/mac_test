import Foundation
import UIKit
import SDSKit

enum TermsCheckType {
    case selectAll
    case selectOneByOne
}

class TermsButton: UIButton {
    private var type: TermsCheckType?
    
    init(type: TermsCheckType, title: AttributedString) {
        super.init(frame: .zero)
        self.type = type
        var config = UIButton.Configuration.plain()
        config.attributedTitle = title
        config.imagePadding = ScreenUtils.setWidth(value: 12)
        config.titleAlignment = .leading
        config.baseForegroundColor = .stepinBlack100
        config.baseBackgroundColor = .stepinBlack100
        self.backgroundColor = UIColor.stepinBlack100
        
        if type == .selectAll {
            config.image = ImageLiterals.icGrayFillCheck
            self.configuration = config
            self.layer.borderColor = UIColor.stepinWhite40.cgColor
            self.layer.borderWidth = 2
        } else {
            config.image = ImageLiterals.icGrayCheck
            self.configuration = config
        }
        
        self.imageView?.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 17))
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 24))
        }
        if self.imageView != nil {
            self.titleLabel?.snp.makeConstraints {
                $0.leading.equalTo(self.imageView!.snp.trailing).offset(ScreenUtils.setWidth(value: 12))
                $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 12))
                $0.centerY.equalToSuperview()
            }
        }
    }
    
    internal func didButtonClicked(type: TermsCheckType, isSelected: Bool) {
        if type == .selectAll {
            var config = self.configuration
            self.layer.borderColor = isSelected ? UIColor.SystemBlue.cgColor: UIColor.stepinWhite40.cgColor
            config?.image = isSelected ? SDSIcon.icCheckBoxSelect: SDSIcon.icCheckBoxDeselect
            self.configuration = config
        } else {
            var config = self.configuration
            config?.image = isSelected ? SDSIcon.icCheckActive: SDSIcon.icCheckDefault
            self.configuration = config
        }
    }
    
    internal func getButtonType() -> TermsCheckType {
        return self.type!
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
