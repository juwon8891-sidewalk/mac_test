import UIKit
import SnapKit
import Then

class EditDanceScoreInfoView: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    init() {
        super.init(frame: .zero)
        setLayout()
    }
    
    internal func setData(state: String,
                          score: Float) {
        self.stateLabel.text = state
        if !score.isNaN {
            self.scorePercentLabel.text = "\(Int(score)) %"
        }
    }
    
    private func setLayout() {
        self.backgroundColor = .stepinBlack100
        self.addSubviews([stateLabel, scorePercentLabel])
        stateLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 30))
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
            $0.centerY.equalToSuperview()
        }
        scorePercentLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 30))
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
            $0.centerY.equalToSuperview()
        }
    }
    
    private var stateLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
    }
    
    private var scorePercentLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
    }
}

