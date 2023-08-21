import UIKit

class PlayDefaultSearchHeaderView: UITableViewHeaderFooterView {
    static let identifier: String = "PlayDefaultSearchHeaderView"
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.setLayout()
    }
    
    private func setLayout() {
        self.backgroundColor = .clear
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.top.bottom.equalToSuperview().inset(ScreenUtils.setWidth(value: 20))
            $0.height.equalTo(ScreenUtils.setWidth(value: 25))
        }
    }
    
    private var titleLabel = UILabel().then {
        $0.font = .suitExtraBoldFont(ofSize: 20)
        $0.textColor = .stepinWhite100
        $0.text = "play_game_hot_dance_tab_title".localized()
    }
}
