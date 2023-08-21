import UIKit
import SDSKit
import SnapKit
import Then

class GameReadyInfoView: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    init() {
        super.init(frame: .zero)
        self.setLayout()
    }
    
    
    private func setLayout() {
        self.addSubview(infoLabel)
        infoLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(12.adjusted)
            $0.top.bottom.equalToSuperview().inset(10.adjusted)
        }
        self.backgroundColor = .PrimaryBlackHeavy.withAlphaComponent(0.5)
        self.layer.cornerRadius = 10.adjusted
        self.clipsToBounds = true
    }
    
    private let infoLabel = UILabel().then {
        $0.font = SDSFont.body.font
        $0.textColor = .PrimaryWhiteNormal
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.text = "play_game_alert_readyToPlay_title".localized()
    }
}
