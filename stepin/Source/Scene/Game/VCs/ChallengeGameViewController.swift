import UIKit
import SDSKit
import Lottie
import RxSwift
import RxCocoa

final class ChallengeGameViewController: UIViewController {
    var disposeBag = DisposeBag()
    var viewModel: ChallengeGameViewModel?
    var rect: CGRect?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        self.bindViewModel()
        addLayer()
    }
    
    override func loadView() {
        super.loadView()
        self.view = challengeView
    }
    
    private func bindViewModel() {
        let output = self.viewModel?.transform(from: .init(viewDidAppear: self.rx.methodInvoked(#selector(viewDidAppear(_:)))
            .map({ _ in })
            .asObservable(),
                                                           navigationBackButtonTap: self.challengeView.navigationBar.backButton.rx.tap.asObservable(),
                                                           navigationCloseButtonTap: self.challengeView.navigationBar.rightButton.rx.tap.asObservable(),
                                                           changeCameraOrient: self.challengeView.gameReadyView.changeButton.rx.tap.asObservable(),
                                                           bodyZoomToggleState: self.challengeView.gameReadyView.bodyZoomSwitch.rx.value.asObservable(),
                                                           neonColorSelectView: self.challengeView.gameReadyView.neonColorSelectView),
                                               disposeBag: disposeBag)
        output?.preiviewImage
            .withUnretained(self)
            .bind(onNext: { (vc, image) in
                DispatchQueue.main.async {
                    vc.challengeView.imageView.image = image
                }
            })
            .disposed(by: disposeBag)
        
        output?.didExitGameInProgress
            .withUnretained(self)
            .bind(onNext: { (vc, _) in
                vc.showAlert()
            })
            .disposed(by: disposeBag)
        
        output?.danceData
            .withUnretained(self)
            .bind(onNext: { (vc, data) in
                vc.challengeView.loadingView.bindData(imagePath: data.coverURL,
                                                      title: data.title,
                                                      artist: data.artist)
            })
            .disposed(by: disposeBag)
        
        output?.neonRelay
            .withUnretained(self)
            .bind(onNext: { (vc, handler) in
                vc.challengeView.neonView.setNeonHandler(neonHandler: handler)
            })
            .disposed(by: disposeBag)
        
        output?.gameState
            .withUnretained(self)
            .bind(onNext: { (vc, state) in
                switch state {
                case .none:
                    break
                case .loadingComplete:
                    DispatchQueue.main.async {
                        vc.challengeView.loadingView.isHidden = true
                    }
                    break
                case .startCountDown:
                    DispatchQueue.main.async {
                        vc.challengeView.startEndImageView.isHidden = true
                        vc.challengeView.hiddenReadyView()
                        vc.challengeView.startEndImageView.image = SDSIcon.icGameStart
                    }
                    break
                case .progress:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        vc.challengeView.startEndImageView.isHidden = true
                        vc.challengeView.scoreView.isHidden = false
                    }
                    break
                case .finish:
                    DispatchQueue.main.async {
                        vc.challengeView.startEndImageView.isHidden = true
                        vc.view.removeLoadingIndicator()
                    }
                    break
                case .completeGame:
                    DispatchQueue.main.async {
                        vc.challengeView.startEndImageView.image = SDSIcon.icGameFinish
                        vc.challengeView.startEndImageView.isHidden = false
                        vc.view.showLoadingIndicator()
                    }
                    break
                }
            })
            .disposed(by: disposeBag)
        
        output?.countDownState
            .withUnretained(self)
            .bind(onNext: { (vc, count) in
                self.showCountDownImage(count: count)
            })
            .disposed(by: disposeBag)
        
        output?.musicTitle
            .withUnretained(self)
            .bind(onNext: { (vc, title) in
                vc.challengeView.navigationBar.setTitle(title: title)
            })
            .disposed(by: disposeBag)
        
//        output?.bBoxLayer
//            .withUnretained(self)
//            .bind(onNext: { (vc, layer) in
//                DispatchQueue.main.async {
//                    vc.challengeView.imageView.layer.replaceSublayer(vc.dummyLayer, with: layer)
//                    vc.dummyLayer = layer
//                }
//            })
//            .disposed(by: disposeBag)
//
        output?.scoreData
            .withUnretained(self)
            .bind(onNext: { (vc, score) in
                DispatchQueue.main.async {
                    let percentValue = Double(score) / 100
                    let doubleValue = Double(score)
                    
                    let strValue = String(format: "%.02f", doubleValue)
                    vc.challengeView.scoreView.progressAnimation(duration: 0.8,
                                                                 value: percentValue)
                    vc.challengeView.scoreView.setPercent(value: Double(strValue) ?? 0)
                }
            })
            .disposed(by: disposeBag)
        
        output?.avgScoreData
            .withUnretained(self)
            .bind(onNext: { (vc, avgScore) in
                DispatchQueue.main.async {
                    print(avgScore, "avg Score")
                    vc.showScoreAnimate(score: avgScore)
                }
            })
            .disposed(by: disposeBag)
        
//        output?.bodyZoomRect
//            .withUnretained(self)
//            .bind(onNext: { (vc, rect) in
//                DispatchQueue.main.async {
//                    vc.rect = rect
//                    print(vc.rect)
//                }
//            })
//            .disposed(by: disposeBag)
//
    }
    
    var dummyLayer = CALayer()
    func addLayer() {
        self.challengeView.imageView.layer.addSublayer(dummyLayer)
    }
    
    private func showScoreAnimate(score: Float) {
        switch score {
        case 90.0 ... 100.0:
            self.challengeView.perfectLottieView.isHidden = false
            self.challengeView.perfectLottieView.play() { _ in self.challengeView.perfectLottieView.isHidden = true}
        case 70.0 ... 89.99:
            self.challengeView.greatLottieView.isHidden = false
            self.challengeView.greatLottieView.play() { _ in self.challengeView.greatLottieView.isHidden = true}
        case 40.0 ... 69.99:
            self.challengeView.goodLottieView.isHidden = false
            self.challengeView.goodLottieView.play() { _ in self.challengeView.goodLottieView.isHidden = true}
        case 1.0 ... 39.99:
            self.challengeView.badLottieView.isHidden = false
            self.challengeView.badLottieView.play() { _ in self.challengeView.badLottieView.isHidden = true}
        default:
            self.challengeView.missLottieView.isHidden = false
            self.challengeView.missLottieView.play() { _ in self.challengeView.missLottieView.isHidden = true}
        }
    }
    
    private func showCountDownImage(count: Int) {
        DispatchQueue.main.async {
            switch count {
            case 6:
                self.challengeView.countDownImageView.isHidden = false
                self.challengeView.countDownImageView.image = SDSIcon.icGamePlay5
            case 5:
                self.challengeView.countDownImageView.image = SDSIcon.icGamePlay4
            case 4:
                self.challengeView.countDownImageView.image = SDSIcon.icGamePlay3
            case 3:
                self.challengeView.countDownImageView.image = SDSIcon.icGamePlay2
            case 2:
                self.challengeView.countDownImageView.image = SDSIcon.icGamePlay1
            case 1:
                self.challengeView.countDownImageView.isHidden = true
                self.challengeView.startEndImageView.isHidden = false
            case 0:
                self.challengeView.startEndImageView.isHidden = true
            default:
                break
            }
        }
    }
    
    private func showAlert() {
        let alert = self.showSDSAlert(size: .init(width: 272,
                                                  height: 260),
                          icon: SDSIcon.icWarning,
                          title: "play_game_exit_warning_title".localized(),
                          titleColor: .SystemYellow,
                          description: "play_game_exit_warning_description".localized(),
                          descriptionColor: .PrimaryWhiteNormal)
        
        alert.okButtonTapCompletion = { [weak self] in
            guard let storngSelf = self else {return}
            storngSelf.viewModel?.exitGame()
        }
        alert.cancelButtonTapCompletion = { [weak self] in
            guard let storngSelf = self else {return}
            storngSelf.hideSDSAlertView(alert)
        }
    }
    
    let challengeView = ChallengeGameView()
}
