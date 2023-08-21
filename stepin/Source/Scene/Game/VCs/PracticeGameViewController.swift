import UIKit
import SDSKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class PracticeGameViewController: UIViewController {
    var viewModel: PracticeGameViewModel?
    var disposeBag = DisposeBag()
    
    override func loadView() {
        super.loadView()
        self.view = practiceView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.bindViewModel()
    }
    
    func bindViewModel() {
        let output = self.viewModel?.transform(from: .init(viewDidAppear: self.rx.methodInvoked(#selector(viewDidAppear(_:)))
            .map({ _ in })
            .asObservable(),
                                                           navigationBackButtonTap: self.practiceView.navigationBar.backButton.rx.tap.asObservable(),
                                                           navigationCloseButtonTap: self.practiceView.navigationBar.rightButton.rx.tap.asObservable(),
                                                           changeCameraOrient: self.practiceView.gameReadyView.changeButton.rx.tap.asObservable(),
                                                           bodyZoomToggleState: self.practiceView.gameReadyView.bodyZoomSwitch.rx.value.asObservable(),
                                                           neonColorSelectView: self.practiceView.gameReadyView.neonColorSelectView,
                                                           videoSlider: self.practiceView.practicePlayView.videoSlider,
                                                           startButton: self.practiceView.practicePlayView.playButton,
                                                           rewindButton: self.practiceView.practicePlayView.rewindButton,
                                                           forwardButton: self.practiceView.practicePlayView.forwardButton),
                                               disposeBag: disposeBag)
        
        output?.preiviewImage
            .withUnretained(self)
            .bind(onNext: { (vc, image) in
                DispatchQueue.main.async {
                    vc.practiceView.imageView.image = image
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
                vc.practiceView.loadingView.bindData(imagePath: data.coverURL,
                                                     title: data.title,
                                                     artist: data.artist,
                                                     gameStateLabel: "play_game_alert_practice_button_title".localized())
            })
            .disposed(by: disposeBag)
        
        output?.neonRelay
            .withUnretained(self)
            .bind(onNext: { (vc, handler) in
                vc.practiceView.neonView.setNeonHandler(neonHandler: handler)
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
                        vc.practiceView.loadingView.isHidden = true
                    }
                    break
                case .startCountDown:
                    DispatchQueue.main.async {
                        vc.practiceView.startEndImageView.isHidden = true
                        vc.practiceView.practicePlayView.isHidden = true
                        vc.practiceView.hiddenReadyView()
                        vc.practiceView.startEndImageView.image = SDSIcon.icGameStart
                    }
                    break
                case .progress:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        vc.practiceView.startEndImageView.isHidden = true
                        vc.practiceView.practicePlayView.isHidden = false
                    }
                    break
                case .finish:
                    DispatchQueue.main.async {
                        vc.practiceView.startEndImageView.isHidden = true
                    }
                    break
                case .completeGame:
                    DispatchQueue.main.async {
                        vc.practiceView.startEndImageView.image = SDSIcon.icGameFinish
                        vc.practiceView.startEndImageView.isHidden = false
                    }
                    break
                }
            })
            .disposed(by: disposeBag)
        
        output?.musicTitle
            .withUnretained(self)
            .bind(onNext: { (vc, title) in
                vc.practiceView.navigationBar.setTitle(title: title)
            })
            .disposed(by: disposeBag)
        
        output?.countDownState
            .withUnretained(self)
            .bind(onNext: { (vc, count) in
                self.showCountDownImage(count: count)
            })
            .disposed(by: disposeBag)
        
        output?.currentTimeString
            .withUnretained(self)
            .bind(onNext: { (vc, timeStr) in
                self.practiceView.practicePlayView.startTimeLabel.text = timeStr
            })
            .disposed(by: disposeBag)
        
        output?.endTimeString
            .withUnretained(self)
            .bind(onNext: { (vc, timeStr) in
                self.practiceView.practicePlayView.endTimeLabel.text = timeStr
            })
            .disposed(by: disposeBag)
        
        output?.forwardRatioText
            .withUnretained(self)
            .bind(onNext: { (vc, ratio) in
                self.practiceView.practicePlayView.forwardStateLabel.text = ratio
            })
            .disposed(by: disposeBag)
        
        output?.rewindRatioText
            .withUnretained(self)
            .bind(onNext: { (vc, ratio) in
                self.practiceView.practicePlayView.rewindStateLabel.text = ratio
            })
            .disposed(by: disposeBag)
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
    
    private func showCountDownImage(count: Int) {
        DispatchQueue.main.async {
            switch count {
            case 6:
                self.practiceView.countDownImageView.isHidden = false
                self.practiceView.countDownImageView.image = SDSIcon.icGamePlay5
            case 5:
                self.practiceView.countDownImageView.image = SDSIcon.icGamePlay4
            case 4:
                self.practiceView.countDownImageView.image = SDSIcon.icGamePlay3
            case 3:
                self.practiceView.countDownImageView.image = SDSIcon.icGamePlay2
            case 2:
                self.practiceView.countDownImageView.image = SDSIcon.icGamePlay1
            case 1:
                self.practiceView.countDownImageView.isHidden = true
                self.practiceView.startEndImageView.isHidden = false
            case 0:
                self.practiceView.startEndImageView.isHidden = true
            default:
                break
            }
        }
    }
    
    
    private let practiceView = PracticeGameView()
}
