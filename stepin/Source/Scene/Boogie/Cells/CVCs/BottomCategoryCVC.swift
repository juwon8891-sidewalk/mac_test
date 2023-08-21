import UIKit
import SDSKit

class BottomCategoryCVC: UICollectionViewCell {
    static let identifier: String = "BottomCategoryCVC"
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.didDeSelecteCell()
        self.titleLabel.text = ""
        self.titleLabel.snp.removeConstraints()
    }
    
    internal func didSelectCell() {
        self.contentView.backgroundColor = .stepinWhite100
        self.titleLabel.textColor = .stepinBlack100
        self.titleLabel.font = SDSFont.caption1.font.withSize(14)
    }
    
    internal func didDeSelecteCell() {
        self.contentView.backgroundColor = .clear
        self.titleLabel.textColor = .stepinWhite40
    }
    
    internal func setCellConfig(title: String) {
        self.titleLabel.text = title
        
        self.contentView.backgroundColor = .clear
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(ScreenUtils.setWidth(value: 6))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 12))
        }
        contentView.layer.cornerRadius = ScreenUtils.setWidth(value: 15)
        contentView.layer.borderColor = UIColor.stepinWhite100.cgColor
        contentView.layer.borderWidth = 1
    }
    
    private var titleLabel = UILabel().then {
        $0.font = .suitRegularFont(ofSize: 14)
        $0.textColor = .PrimaryWhiteNormal
        $0.textAlignment = .center
        $0.adjustsFontSizeToFitWidth = true
        $0.numberOfLines = 1
    }
}
