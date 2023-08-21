import UIKit
import SDSKit
import SnapKit
import Then

final class ScoreInfoView: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: .zero)
        self.setLayout()
    }
    
    func bindText(scoreState: String,
                  scorePercent: String) {
        self.scoreStateLabel.text = scoreState
        self.scorePercentLabel.text = scorePercent
    }
    
    private func setLayout() {
        self.addSubviews([scoreStateLabel, scorePercentLabel])
        
        scoreStateLabel.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
        }
        scorePercentLabel.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview()
        }
    }
    
    private let scoreStateLabel = UILabel().then {
        $0.font = SDSFont.body.font
        $0.textColor = .PrimaryWhiteNormal
    }
    
    private let scorePercentLabel = UILabel().then {
        $0.font = SDSFont.body.font
        $0.textColor = .PrimaryWhiteNormal
    }
}
