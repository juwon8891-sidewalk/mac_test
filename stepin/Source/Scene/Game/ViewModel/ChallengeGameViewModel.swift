import Foundation
import RxSwift
import RxRelay
import RxDataSources
import AVFoundation
import Lottie

final class ChallengeGameViewModel: NSObject {
    var disposeBag: DisposeBag?
    var coordinator: ChallengeGameCoordinator?
    var input: Input?
    
    var danceData: PlayDance?
    var bodyZoomState: Bool = false
    
    //useCase
    var challengeGameUseCase = ChallengeGameUseCase()
    
    //relay
    var previewRelay = PublishRelay<UIImage>()
    var bodyZoomRect = PublishRelay<CGRect>()
    var neonRelay = PublishRelay<NeonPlayHandler>()
    var loadingDataRelay = PublishRelay<PlayDance>()
    var gameStateRelay = PublishRelay<GameState>()
    var countDownRelay = PublishRelay<Int>()
    var bBoxRelay = PublishRelay<CALayer>()
    var bodyPoseRelay = PublishRelay<CALayer>()
    var scoreRelay = PublishRelay<Float>()
    var scoreAnimationRelay = PublishRelay<Float>()
    
    var scoreData: [String] = []
    var score: Float = 0
    
    //handler
    
    init(coordinator: ChallengeGameCoordinator) {
        self.coordinator = coordinator
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        challengeGameUseCase.delegate = self
        
        //Input
        input.neonColorSelectView.selectedNeonColorCompletion = { [weak self] color in
            guard let strongSelf = self else {return}
            strongSelf.challengeGameUseCase.changeNeonColor(blurColor: color)
        }
        input.viewDidAppear
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                if let dance = vm.danceData {
                    output.danceData.accept(dance)
                    output.musicTitle.accept(dance.title)
                    vm.challengeGameUseCase.makeSession(danceId: dance.danceID)
                }
            })
            .disposed(by: disposeBag)
        
        input.navigationBackButtonTap
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                output.didExitGameInProgress.accept(())
            })
            .disposed(by: disposeBag)
        
        input.navigationCloseButtonTap
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                output.didExitGameInProgress.accept(())
            })
            .disposed(by: disposeBag)
        
        input.changeCameraOrient
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                vm.challengeGameUseCase.changeCameraOrient()
            })
            .disposed(by: disposeBag)
        
        input.bodyZoomToggleState
            .withUnretained(self)
            .bind(onNext: { (vm, state) in
                vm.bodyZoomState = state
            })
            .disposed(by: disposeBag)
        
        neonRelay
            .withUnretained(self)
            .bind(onNext: { (vm, handler) in
                handler.setIndex(index: 0)
                output.neonRelay.accept(handler)
            })
            .disposed(by: disposeBag)
        
        loadingDataRelay
            .withUnretained(self)
            .bind(onNext: { (vm, data) in
                output.danceData.accept(data)
            })
            .disposed(by: disposeBag)
        
        gameStateRelay
            .withUnretained(self)
            .bind(onNext: { (vm, state) in
                output.gameState.accept(state)
                if state == .finish {
                    DispatchQueue.main.async {
                        vm.exitGame()
                        vm.coordinator?.pushToResultViewController(scoreData: vm.scoreData,
                                                                     score: vm.score,
                                                                     danceData: vm.danceData)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        countDownRelay
            .withUnretained(self)
            .bind(onNext: { (vm, count) in
                output.countDownState.accept(count)
            })
            .disposed(by: disposeBag)
        
        bodyPoseRelay
            .withUnretained(self)
            .bind(onNext: { (vm, layer) in
                output.bBoxLayer.accept(layer)
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(bodyZoomRect.asObservable(),
                                 previewRelay.asObservable())
        .withUnretained(self)
        .subscribe(onNext: { (vm, previewTuple) in
            let (rect, image) = previewTuple
            if vm.bodyZoomState {
                output.preiviewImage.accept(vm.cropImage(image: image, rect: rect))
            } else {
                output.preiviewImage.accept(image)
            }
        })
        .disposed(by: disposeBag)
        
        scoreRelay
            .withUnretained(self)
            .bind(onNext: { (vm, score) in
                output.scoreData.accept(score)
                vm.score = score
            })
            .disposed(by: disposeBag)
        
        scoreAnimationRelay
            .withUnretained(self)
            .bind(onNext: { (vm, avgScore) in
                output.avgScoreData.accept(avgScore)
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
    func cropImage(image: UIImage, rect: CGRect) -> UIImage {
        if let cgCroppedImage = image.cgImage!.cropping(to: rect) {
            let returnImage = UIImage(cgImage: cgCroppedImage).resizedImage(width: UIScreen.main.bounds.width,
                                                                            height: UIScreen.main.bounds.height) ?? UIImage()
            return returnImage
        }
        return UIImage()
    }
    
    func exitGame() {
        self.challengeGameUseCase.disposeHandler()
        self.challengeGameUseCase.delegate = nil
        self.coordinator?.pop()
    }
    
    
    struct Input {
        var viewDidAppear: Observable<Void>
        var navigationBackButtonTap: Observable<Void>
        var navigationCloseButtonTap: Observable<Void>
        var changeCameraOrient: Observable<Void>
        var bodyZoomToggleState: Observable<Bool>
        var neonColorSelectView: NeonColorSelectButton
    }

    struct Output {
        let danceData = PublishRelay<PlayDance>()
        let preiviewImage = PublishRelay<UIImage>()
        let neonRelay = PublishRelay<NeonPlayHandler>()
        let isFrontCameraUse = PublishRelay<Bool>()
        let didExitGameInProgress = PublishRelay<Void>()
        let countDownState = PublishRelay<Int>()
        let musicTitle = PublishRelay<String>()
        let bBoxLayer = PublishRelay<CALayer>()
        let poseLayer = PublishRelay<CALayer>()
        let bodyZoomImage = PublishRelay<UIImage>()
        let scoreData = PublishRelay<Float>()
        let avgScoreData = PublishRelay<Float>()
        
        let gameState = PublishRelay<GameState>()
    }
}
extension ChallengeGameViewModel: ChallengeGameProtocol {
    func getTotalScore(score: [Score]) {
        var scoreResultData: [String] = []
        score.forEach {
            let state = String($0.score).scoreToState(score: $0.score)
            scoreResultData.append(state)
        }
        self.scoreData = scoreResultData
    }
    func getAverageScore(avgScore: Float) {
        print(avgScore)
        scoreAnimationRelay.accept(avgScore)
        
        switch avgScore {
        case 90.0 ... 100.0:
            self.scoreData.append("Perfect")
        case 71.0 ... 89.0:
            self.scoreData.append("Great")
        case 40.0 ... 69.0:
            self.scoreData.append("Good")
        default:
            self.scoreData.append("bad")
        }
    }
    
    func getScore(score: Float) {
        scoreRelay.accept(score)
    }
    
    func getPreviewImage(buffer: CVPixelBuffer) {
        if let image = UIImage(pixelBuffer: buffer) {
            self.previewRelay.accept(image)
        }
    }
    
    func getBodyZoomRect(rect: CGRect) {
        self.bodyZoomRect.accept(rect)
    }
    
    func getBodyPoseData(pose: CALayer) {
        self.bodyPoseRelay.accept(pose)
    }
    
    func getGameState(state: GameState) {
        self.gameStateRelay.accept(state)
    }
    
    func getBboxLayer(layer: CALayer) {
        self.bBoxRelay.accept(layer)
    }
    
    func getNeonHandler(handler: NeonPlayHandler) {
        self.neonRelay.accept(handler)
    }
    
    func getCountDownValue(count: Int) {
        self.countDownRelay.accept(count)
    }
    
}
