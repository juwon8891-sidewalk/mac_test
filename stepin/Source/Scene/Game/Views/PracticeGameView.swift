import UIKit
import SDSKit
import Then
import SnapKit

final class PracticeGameView: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: .zero)
        self.setLayout()
    }
    
    private func setLayout() {
        self.addSubviews([imageView,
                          neonView,
                          gameReadyView,
                          gameReadyInfoView,
                          loadingView,
                          countDownImageView,
                          startEndImageView,
                          practicePlayView,
                          navigationBar,])
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60.adjusted)
        }
        imageView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        gameReadyView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        neonView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        gameReadyInfoView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(74.adjusted)
            $0.leading.trailing.equalToSuperview().inset(56.adjusted)
        }
        loadingView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        countDownImageView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.height.equalTo(223.adjusted)
        }
        countDownImageView.isHidden = true
        startEndImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(80.adjustedH)
        }
        startEndImageView.isHidden = true
        
        practicePlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        practicePlayView.isHidden = true
    }
    
    func hiddenReadyView() {
        self.gameReadyInfoView.isHidden = true
        self.gameReadyView.bodyZoomSwitch.isHidden = true
        self.gameReadyView.changeButton.isHidden = true
        self.gameReadyView.neonColorSelectView.isHidden = true
        self.gameReadyView.stackView.isHidden = true
        self.gameReadyView.readyButton.isHidden = true
    }
    
    internal let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    let loadingView = GameLoadingView()
    let gameReadyView = GameReadyView()
    let gameReadyInfoView = GameReadyInfoView()
    let navigationBar = SDSNavigationBar().then {
        $0.backButton.isHidden = true
        $0.setRigthButtonImage(image: SDSIcon.icClose)
    }
    let neonView = NeonView()
    let countDownImageView = UIImageView(image: SDSIcon.icGamePlay5).then {
        $0.contentMode = .scaleAspectFill
    }
    let startEndImageView = UIImageView(image: SDSIcon.icGameStart).then {
        $0.contentMode = .scaleAspectFill
    }
    let practicePlayView = PracticePlayView()
}
