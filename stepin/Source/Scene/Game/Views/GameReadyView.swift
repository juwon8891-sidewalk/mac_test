import UIKit
import SDSKit
import Then

class GameReadyView: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: .zero)
        self.setLayout()
    }
    
    private func setLayout() {
        self.addSubviews([neonColorSelectView, readyButton, changeButton, stackView])
        
        neonColorSelectView.snp.makeConstraints {
            $0.trailing.equalTo(readyButton.snp.leading).inset(-20.adjusted)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(70.adjusted)
            $0.width.equalTo(48.adjusted)
            $0.height.equalTo(268.adjusted)
        }
        readyButton.snp.makeConstraints {
            $0.centerY.equalTo(self.changeButton)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(215.adjusted)
            $0.height.equalTo(64.adjusted)
        }
        changeButton.snp.makeConstraints {
            $0.leading.equalTo(readyButton.snp.trailing).offset(20.adjusted)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(70.adjusted)
            $0.width.height.equalTo(48.adjusted)
        }
        changeButton.layer.cornerRadius = 24.adjusted
        changeButton.clipsToBounds = true
        
        stackView.addArrangeSubViews([bodyZoomLabel, bodyZoomSwitch])
        stackView.snp.makeConstraints {
            $0.top.equalTo(readyButton.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
    }
    
    
    let neonColorSelectView = NeonColorSelectButton()
    let readyButton = UIButton().then {
        $0.setBackgroundImage(SDSIcon.icReadyDefault, for: .normal)
        $0.setBackgroundImage(SDSIcon.icReadyActive, for: .selected)
    }
    let changeButton = UIButton().then {
        $0.setBackgroundColor(.PrimaryBlackAlternative, for: .normal)
        $0.setImage(SDSIcon.icChange, for: .normal)
    }
    let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.spacing = 12
    }
    private let bodyZoomLabel = UILabel().then {
        $0.font = SDSFont.body.font
        $0.textColor = .PrimaryWhiteNormal
        $0.text = "play_game_loading_challenge_game_body_zoom_title".localized()
    }
    internal let bodyZoomSwitch = SDSToggleButton().then {
        $0.backgroundColor = .clear
    }
    
}
