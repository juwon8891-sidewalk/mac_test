import UIKit

class TopCategoryCVC: UICollectionViewCell {
    static let identifier: String = "TopCategoryCVC"
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = ""
        self.didDeSelecteCell()
    }
    
    internal func didSelectCell() {
        self.titleLabel.textColor = .stepinWhite100
    }
    
    internal func didDeSelecteCell() {
        self.titleLabel.textColor = .stepinWhite40
    }
    
    internal func setCellConfig(title: String) {
        self.titleLabel.text = title
        
        self.contentView.backgroundColor = .clear
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 25))
        }
    }
    
    private var titleLabel = UILabel().then {
        $0.font = .suitExtraBoldFont(ofSize: 20)
        $0.textColor = .stepinWhite40
    }
}
