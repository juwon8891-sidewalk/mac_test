import Foundation
import AVFoundation
import RxSwift
import RxCocoa

final class PracticeGameUseCase: NSObject {
    var disposeBag = DisposeBag()
    weak var delegate: PracticeGameProtocol?
    
    private var playRepository: PlayRepository = PlayRepository(defaultURLSessionNetworkService: .init())
    private var authRepository: AuthRepository = AuthRepository(defaultURLSessionNetworkService: .init())
    
    var gameHandler: GameHandler? = GameHandler()
    private var startTime: CMTime?
    private var endTime: CMTime?
    
    override init() {
        super.init()
        initHandler()
    }
    
    deinit {
        print("deinit usecase")
    }
    
    func disposeHandler() {
        self.gameHandler?.delegate = nil
        self.gameHandler?.disposeHandler()
        self.gameHandler = nil
    }
    
    private func initHandler() {
        gameHandler?.delegate = self
    }
    
    func changeCameraOrient() {
        self.gameHandler?.setCameraOrient()
    }
    
    func changeNeonColor(blurColor: UIColor) {
        self.gameHandler?.neonHandler?.changeNeonBlurColor(color: blurColor)
    }
    
    func makeSession(danceId: String) {
        self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap { (uc, _) in uc.playRepository.postCreatePlaySession(danceId: danceId,
                                                                          gameType: "PRACTICE")}
            .withUnretained(self)
            .subscribe(onNext: { (uc, result) in
                uc.gameHandler?.initMusicPlayer(musicPath: result.data.playDanceData.musicURL,
                                               startTime: result.data.playDanceData.startTime,
                                               endTime: result.data.playDanceData.endTime)
                uc.gameHandler?.initNeonHandler(neonPath: result.data.playDanceData.guideURL ?? "",
                                               neonLineColor: .PrimaryWhiteNormal,
                                               neonBlurColor: .PrimaryWhiteNormal)
                uc.gameHandler?.modelHandler?.loadModel { [weak self] in
                    guard let strongSelf = self else {return}
                    guard let gameHandler = strongSelf.gameHandler else {return}
                    strongSelf.gameHandler?.gameState = .loadingComplete
                    strongSelf.delegate?.getGameState(state: gameHandler.gameState)
                    strongSelf.getNeonLayer()
                    strongSelf.changeNeonColor(blurColor: .PrimaryWhiteNormal)
                }
            },
                       onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
    
}
extension PracticeGameUseCase: GameProtocol {
    
    func getMusicDuration(time: Float,
                          startTime: Float,
                          endTime: Float) {
        self.delegate?.getMusicTime(time: time,
                                    startTime: startTime,
                                    endTime: endTime)
    }

    func getPixelBuffer(pixelBuffer: CVPixelBuffer, timeStamp: CMTime) {
        self.delegate?.getPreviewImage(buffer: pixelBuffer)
        guard let gameHandler = self.gameHandler else {return}
    }
    
    func getCountDownValue(count: Int) {
        self.delegate?.getCountDownValue(count: count)
        if count <= 6 && count != 1 {
            self.delegate?.getGameState(state: .startCountDown)
        }
        if count == 1 {
            self.delegate?.getGameState(state: .progress)
        }
    }
    
    func getGameState(state: GameState) {
        delegate?.getGameState(state: state)
        if state == .completeGame {
//            self.gameHandler?.gameState = .startCountDown
            //게임 완료 되었을때
        }
    }
    
    func getBodyPose(pose: [CGPoint], poseValue: [Float32], timeStamp: CMTime) {}
    
    func getBodyZoomRect(rect: CGRect) {
        delegate?.getBodyZoomRect(rect: rect)
    }
    
    func getNeonLayer() {
        guard let gameHandler = self.gameHandler else {return}
        if let handler = gameHandler.neonHandler {
            self.delegate?.getNeonHandler(handler: handler)
        }
    }
    
    
}
