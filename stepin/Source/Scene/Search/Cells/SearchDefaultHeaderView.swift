import UIKit
import SnapKit
import Then

class SearchDefaultHeaderView: UICollectionReusableView {
    static let identifier: String = "SearchDefaultHeaderView"
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setLayout() {
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.centerY.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 25))
        }
    }
    
    private var titleLabel = UILabel().then {
        $0.font = .suitExtraBoldFont(ofSize: 20)
        $0.textColor = .stepinWhite100
        $0.text = "searchView_hot_dance_view_title".localized()
    }
}
