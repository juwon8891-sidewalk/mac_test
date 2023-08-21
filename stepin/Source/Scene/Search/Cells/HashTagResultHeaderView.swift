import UIKit
import SnapKit
import Then

class HashTagResultHeaderView: UICollectionReusableView {
    
    static let identifier: String = "HashTagResultHeaderView"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    internal func setData(hashTag: String) {
        self.hashTagTitle.text = hashTag
    }
    
    private func setLayout() {
        self.addSubviews([hashTagButton, hashTagTitle])
        hashTagButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 40))
        }
        hashTagButton.layer.cornerRadius = ScreenUtils.setWidth(value: 20)
        hashTagTitle.snp.makeConstraints {
            $0.leading.equalTo(hashTagButton.snp.trailing).offset(ScreenUtils.setWidth(value: 12))
            $0.centerY.equalTo(hashTagButton)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
        }
    }
    
    private var hashTagButton = UIButton().then {
        $0.setTitle("#", for: .normal)
        $0.titleLabel?.font = .suitExtraBoldFont(ofSize: 20)
        $0.layer.borderColor = UIColor.stepinWhite100.cgColor
        $0.layer.borderWidth = 2
    }
    private var hashTagTitle = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
    }
}
