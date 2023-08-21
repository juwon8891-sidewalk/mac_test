import Foundation
import RxSwift
import RxCocoa

final class PracticeGameViewModel: NSObject {
    var disposeBag: DisposeBag?
    var coordinator: PracticeGameCoordinator?
    
    var danceInfo: PlayDance?
    var bodyZoomState: Bool = false

    private var playSpeed: Float = 1.0
    
    var shouldUpdateProgressIndicator = true
    var isSeeking = false
    var musicStartFlag: Bool = true
    
    private var startTime: Float?
    private var currentTime: Float?
    private var endTime: Float?
    
    //useCase
    var practiceGameUseCase: PracticeGameUseCase? = PracticeGameUseCase()
    
    //relay
    var previewRelay = PublishRelay<UIImage>()
    var bodyZoomRect = PublishRelay<CGRect>()
    var neonRelay = PublishRelay<NeonPlayHandler>()
    var loadingDataRelay = PublishRelay<PlayDance>()
    var gameStateRelay = PublishRelay<GameState>()
    var countDownRelay = PublishRelay<Int>()
    var currentDurationRelay = PublishRelay<[Float]>()
    var isMusicPlayDrag = PublishRelay<Void>()
    
    init(coordinator: PracticeGameCoordinator) {
        self.coordinator = coordinator
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        practiceGameUseCase?.delegate = self
        
        
        input.neonColorSelectView.selectedNeonColorCompletion = { [weak self] color in
            guard let strongSelf = self else {return}
            strongSelf.practiceGameUseCase?.changeNeonColor(blurColor: color)
        }
        
        input.viewDidAppear
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                if let dance = vm.danceInfo {
                    output.danceData.accept(dance)
                    output.musicTitle.accept(dance.title)
                    vm.practiceGameUseCase?.makeSession(danceId: dance.danceID)
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
                vm.practiceGameUseCase?.changeCameraOrient()
            })
            .disposed(by: disposeBag)
        
        input.bodyZoomToggleState
            .withUnretained(self)
            .bind(onNext: { (vm, state) in
                vm.bodyZoomState = state
            })
            .disposed(by: disposeBag)
        
        input.startButton.rx.tap.asObservable()
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                if input.startButton.isSelected {
                    vm.practiceGameUseCase?.gameHandler?.musicPlayer?.player?.rate = vm.playSpeed
                } else {
                    vm.practiceGameUseCase?.gameHandler?.musicPlayer?.pause()
                }
                
                input.startButton.isSelected.toggle()
            })
            .disposed(by: disposeBag)
        
        input.rewindButton.rx.tap.asObservable()
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                if vm.playSpeed >= 0.5 {
                    vm.playSpeed -= 0.25
                }
                if vm.playSpeed < 1.0 {
                    output.rewindRatioText.accept("\(vm.playSpeed)x")
                    output.forwardRatioText.accept("")
                    input.rewindButton.isSelected = true
                    input.forwardButton.isSelected = false
                }
                if vm.playSpeed > 1.0 {
                    output.rewindRatioText.accept("")
                    output.forwardRatioText.accept("\(vm.playSpeed)x")
                    input.rewindButton.isSelected = false
                    input.forwardButton.isSelected = true
                }
                if vm.playSpeed == 1.0 {
                    output.rewindRatioText.accept("")
                    output.forwardRatioText.accept("")
                    input.rewindButton.isSelected = false
                    input.forwardButton.isSelected = false
                }
                if vm.practiceGameUseCase?.gameHandler?.musicPlayer?.player?.rate != 0 && vm.practiceGameUseCase?.gameHandler?.musicPlayer?.player?.error == nil {
                    vm.practiceGameUseCase?.gameHandler?.musicPlayer?.player?.rate = vm.playSpeed
                }
            })
            .disposed(by: disposeBag)
        
        input.forwardButton.rx.tap.asObservable()
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                if vm.playSpeed <= 1.75 {
                    vm.playSpeed += 0.25
                }
                if vm.playSpeed > 1.0 {
                    output.forwardRatioText.accept("\(vm.playSpeed)x")
                    output.rewindRatioText.accept("")
                    input.rewindButton.isSelected = false
                    input.forwardButton.isSelected = true
                }
                if vm.playSpeed < 1.0 {
                    output.rewindRatioText.accept("\(vm.playSpeed)x")
                    output.forwardRatioText.accept("")
                    input.rewindButton.isSelected = true
                    input.forwardButton.isSelected = false
                }
                if vm.playSpeed == 1.0 {
                    output.rewindRatioText.accept("")
                    output.forwardRatioText.accept("")
                    input.rewindButton.isSelected = false
                    input.forwardButton.isSelected = false
                }
                if vm.practiceGameUseCase?.gameHandler?.musicPlayer?.player?.rate != 0 && vm.practiceGameUseCase?.gameHandler?.musicPlayer?.player?.error == nil {
                    vm.practiceGameUseCase?.gameHandler?.musicPlayer?.player?.rate = vm.playSpeed
                }
            })
            .disposed(by: disposeBag)
        
        neonRelay
            .withUnretained(self)
            .bind(onNext: { (vm, handler) in
                handler.setIndex(index: 0)
                output.neonRelay.accept(handler)
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
        
        countDownRelay
            .withUnretained(self)
            .bind(onNext: { (vm, count) in
                output.countDownState.accept(count)
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
        
        gameStateRelay
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .bind(onNext: { (vm, state) in
                output.gameState.accept(state)
                if state == .completeGame {
                    if let startTime = vm.startTime {
                        vm.practiceGameUseCase?.gameHandler?.musicPlayer?.setTimeToMusic(time: startTime - 6) { [weak self] _ in
                            vm.practiceGameUseCase?.gameHandler?.neonHandler?.drawFirstFrame()
                            vm.practiceGameUseCase?.gameHandler?.gameState = .startCountDown
                        }
                    }
                }
                if state == .startCountDown {
                    vm.practiceGameUseCase?.gameHandler?.musicPlayer?.play()
                }
                if state == .progress {
                    input.startButton.isSelected = false
                    vm.practiceGameUseCase?.gameHandler?.musicPlayer?.player?.rate = vm.playSpeed
                }
            })
            .disposed(by: disposeBag)
        
        loadingDataRelay
            .withUnretained(self)
            .bind(onNext: { (vm, data) in
                output.danceData.accept(data)
            })
            .disposed(by: disposeBag)
        
        currentDurationRelay
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .bind(onNext: { (vm, times ) in
                let duration = times[2] - times[1]
                input.videoSlider.setDuration(duration: Float64(duration))
                input.videoSlider.progressBackgroundView.backgroundColor = .PrimaryWhiteNormal
                input.videoSlider.updateProgressIndicator(seconds: Float64(times[0]))
                
                if let currentTime = vm.chnageTimeToString(times[0]), let endTime = vm.chnageTimeToString(times[2] - times[1]) {
                    output.currentTimeString.accept(currentTime)
                    output.endTimeString.accept(endTime)
                }
                
                vm.currentTime = times[0]
                vm.startTime = times[1]
                vm.endTime = times[2]
            })
            .disposed(by: disposeBag)
        
        input.videoSlider.delegate = self
        
        self.isMusicPlayDrag
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                input.startButton.isSelected = true
            })
            .disposed(by: disposeBag)

        return output
    }
    
    func chnageTimeToString(_ time: Float) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad

        // 숫자를 "0:00" 형태로 변환합니다.
        if let formattedString = formatter.string(from: TimeInterval(time)) {
            return formattedString
        } else {
            return nil
            print("Error formatting the time.")
        }
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
        self.practiceGameUseCase?.disposeHandler()
        self.practiceGameUseCase?.delegate = nil
        self.coordinator?.pop()
    }
    
    struct Input {
        var viewDidAppear: Observable<Void>
        var navigationBackButtonTap: Observable<Void>
        var navigationCloseButtonTap: Observable<Void>
        var changeCameraOrient: Observable<Void>
        var bodyZoomToggleState: Observable<Bool>
        var neonColorSelectView: NeonColorSelectButton
        var videoSlider: VideoRangeSlider
        var startButton: UIButton
        var rewindButton: UIButton
        var forwardButton: UIButton
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
        let rewindRatioText = PublishRelay<String>()
        let forwardRatioText = PublishRelay<String>()
        let currentTimeString = PublishRelay<String>()
        let endTimeString = PublishRelay<String>()
        
        let gameState = PublishRelay<GameState>()
    }
}
extension PracticeGameViewModel: PracticeGameProtocol {
    func getMusicTime(time: Float, startTime: Float, endTime: Float) {
        self.currentDurationRelay.accept([time, startTime, endTime])
    }
    
    func getPreviewImage(buffer: CVPixelBuffer) {
        if let image = UIImage(pixelBuffer: buffer) {
            self.previewRelay.accept(image)
        }
    }
    
    func getGameState(state: GameState) {
        self.gameStateRelay.accept(state)
    }
    
    func getBodyZoomRect(rect: CGRect) {
        self.bodyZoomRect.accept(rect)
    }
    
    func getNeonHandler(handler: NeonPlayHandler) {
        self.neonRelay.accept(handler)
    }
    
    func getCountDownValue(count: Int) {
        self.countDownRelay.accept(count)
    }
    
}
extension PracticeGameViewModel: VideoRangeSliderDelegate {
    func didChangeValue(videoRangeSlider: VideoRangeSlider, startTime: Float64, endTime: Float64) {
        let musicPlayer = self.practiceGameUseCase?.gameHandler?.musicPlayer
        if !self.isSeeking {
            self.isSeeking = true
            musicPlayer?.pause()
            if let startTime = self.startTime, let currentTime = self.currentTime {
                musicPlayer?.setTimeToMusic(time: startTime + Float(currentTime)) { [weak self] _ in
                    guard let strongSelf = self else {return}
                    musicPlayer?.player?.rate = strongSelf.playSpeed
                    strongSelf.isSeeking = false
                }
            }
        }
        
    }
    
    func indicatorDidChangePosition(videoRangeSlider: VideoRangeSlider, position: Float64) {
        let musicPlayer = self.practiceGameUseCase?.gameHandler?.musicPlayer
        if !self.isSeeking {
            self.isSeeking = true
            musicPlayer?.pause()
            if let startTime = self.startTime {
                musicPlayer?.setTimeToMusic(time: startTime + Float(position)) { [weak self] _ in
                    guard let strongSelf = self else {return}
                    if musicPlayer?.player?.rate != 0 && musicPlayer?.player?.error == nil {
                        musicPlayer?.player?.rate = strongSelf.playSpeed
                    }
                    strongSelf.isSeeking = false
                    strongSelf.isMusicPlayDrag.accept(())
                }
            }
        }
    }
}
