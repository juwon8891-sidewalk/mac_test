import UIKit
import SDSKit
import SnapKit
import Then
import Lottie

final class ChallengeGameView: UIView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: .zero)
        self.setLayout()
        self.setLottieFiles()
        self.setLottieLayout()
    }
    private func setLayout() {
        self.addSubviews([imageView,
                          neonView,
                          gameReadyView,
                          gameReadyInfoView,
                          navigationBar,
                          loadingView,
                          countDownImageView,
                          startEndImageView,
                          scoreView])
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
        
        scoreView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16.adjusted)
            $0.top.equalTo(self.navigationBar.snp.bottom).offset(8.adjusted)
            $0.width.height.equalTo(72.adjusted)
        }
        scoreView.layer.cornerRadius = 36.adjusted
        scoreView.clipsToBounds = true
        scoreView.isHidden = true
    }
    
    func hiddenReadyView() {
        self.gameReadyInfoView.isHidden = true
        self.gameReadyView.bodyZoomSwitch.isHidden = true
        self.gameReadyView.changeButton.isHidden = true
        self.gameReadyView.neonColorSelectView.isHidden = true
        self.gameReadyView.stackView.isHidden = true
        self.gameReadyView.readyButton.isHidden = true
    }
    
    private func setLottieLayout() {
        self.addSubviews([missLottieView, badLottieView, goodLottieView, greatLottieView, perfectLottieView])
        self.missLottieView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(-50.adjusted)
            $0.width.height.equalTo(400.adjusted)
            $0.leading.equalToSuperview().offset(((UIScreen.main.bounds.width - 400.adjusted) / 2) + 20)
        }
        self.perfectLottieView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(-80.adjusted)
            $0.width.height.equalTo(450.adjusted)
            //(총넓이 - 450 / 2) - 10
            $0.leading.equalToSuperview().offset(((UIScreen.main.bounds.width - 450.adjusted) / 2) - 10)
        }
        self.goodLottieView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(10.adjusted)
            $0.width.height.equalTo(300.adjusted)
            $0.centerX.equalToSuperview()
        }
        self.badLottieView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(40.adjusted)
            $0.width.height.equalTo(250.adjusted)
            $0.centerX.equalToSuperview()
        }
        self.greatLottieView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(40.adjusted)
            $0.width.height.equalTo(250.adjusted)
            $0.centerX.equalToSuperview()
        }

        self.missLottieView.isHidden = true
        self.badLottieView.isHidden = true
        self.goodLottieView.isHidden = true
        self.greatLottieView.isHidden = true
        self.perfectLottieView.isHidden = true
        
    }
    
    private func setLottieFiles() {
        Bundle.allBundles.forEach {
            if $0.bundleIdentifier == "SDSKit-SDSKit-resources" {
                perfectLottieView = LottieAnimationView(name: SDSLottieName.perfect.name, bundle: $0)
                greatLottieView = LottieAnimationView(name: SDSLottieName.great.name, bundle: $0)
                goodLottieView = LottieAnimationView(name: SDSLottieName.good.name, bundle: $0)
                badLottieView = LottieAnimationView(name: SDSLottieName.bad.name, bundle: $0)
                missLottieView = LottieAnimationView(name: SDSLottieName.miss.name, bundle: $0)
            }
        }
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
    let scoreView = ScoreView(frame: .init(origin: .zero, size: CGSize(width: 72.adjusted,
                                                                       height: 72.adjusted)))
    
    var perfectLottieView = LottieAnimationView()
    var greatLottieView = LottieAnimationView()
    var goodLottieView = LottieAnimationView()
    var badLottieView = LottieAnimationView()
    var missLottieView = LottieAnimationView()
    
}
