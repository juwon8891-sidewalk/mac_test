import Foundation
import AVFoundation
import UIKit
import RxSwift
import RxCocoa
import RxRelay

class ChallengeGameUseCase: NSObject {
    var disposeBag = DisposeBag()
    weak var delegate: ChallengeGameProtocol?

    private var playRepository: PlayRepository = PlayRepository(defaultURLSessionNetworkService: .init())
    private var authRepository: AuthRepository = AuthRepository(defaultURLSessionNetworkService: .init())
    private var gameRepository: GameRepository = GameRepository(defaultURLSessionNetworkService: .init())
    
    private var gameHandler: GameHandler? = GameHandler()
    private var recordHandler: RecordHandler?
    private var startTime: CMTime?
    private var endTime: CMTime?
    private var sessionData: PlaySessionDataModel?
    
    private var sessionToken: String = ""
    
    private var mesureStartTime: CMTime?
    private var runningTime: Double = 0
    
    private var scoreData: [Score] = []
    private var poseData: [PoseData] = []
    private var poseScoreData: [PoseData] = []{
        didSet(oldValue) {
            if poseScoreData.count % 5 == 0 {
                uploadScoreData(poseData: poseScoreData, token: scoreToken, data: scoreServerData)
            }
        }
    }
    private var resultScoreData: GameScoreDataModel?
    
    private var scoreServerData: String = ""
    private var scoreToken = ""
    
    private var scoringTimeStamp: [Int] = []
    private var scoringTimeIndex: Int = 0
    private var gameStartTime: CMTime?
    private var currentTime: CMTime?
    
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
    
    //MARK: - controll
    func changeNeonColor(blurColor: UIColor) {
        self.gameHandler?.neonHandler?.changeNeonBlurColor(color: blurColor)
    }
    
    func getAverageScore(lastScores: [Score]) -> Float {
        var totalScore: Float = 0
        lastScores.forEach {
            totalScore += $0.score
        }
        return totalScore / Float(lastScores.count)
    }
    
    //MARK: - Network
    func makeSession(danceId: String) {
        self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap { (uc, _) in uc.playRepository.postCreatePlaySession(danceId: danceId,
                                                                          gameType: "CHALLENGE")}
            .withUnretained(self)
            .subscribe(onNext: { (uc, result) in
                uc.sessionData = result
                uc.scoreToken = result.data.playSessionData?.token ?? ""
                uc.getScoreTimeStamp(danceId: uc.sessionData?.data.playDanceData.danceID ?? "")
                uc.gameHandler?.initMusicPlayer(musicPath: result.data.playDanceData.musicURL,
                                               startTime: result.data.playDanceData.startTime,
                                               endTime: result.data.playDanceData.endTime)
                uc.gameHandler?.initNeonHandler(neonPath: result.data.playDanceData.guideURL ?? "",
                                               neonLineColor: .PrimaryWhiteNormal,
                                               neonBlurColor: .PrimaryWhiteNormal)
                uc.gameHandler?.modelHandler?.loadModel { [weak self] in
                    guard let strongSelf = self else {return}
                    guard let gameHandler = strongSelf.gameHandler else {return}
                    strongSelf.recordHandler = RecordHandler(sessionData: result)
                    strongSelf.gameHandler?.gameState = .loadingComplete
                    strongSelf.delegate?.getGameState(state: gameHandler.gameState)
                    strongSelf.getNeonLayer()
                    strongSelf.changeNeonColor(blurColor: .PrimaryWhiteNormal)
                    strongSelf.recordHandler?.didRecordingReady(cameraHandler: gameHandler.videoCapture!)
                }
            },
                       onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
    
    func getScoreTimeStamp(danceId: String) {
        self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap { (uc, _) in uc.gameRepository.getGameTimeStampData(danceId: danceId) }
            .withUnretained(self)
            .subscribe(onNext: { (uc, result) in
                self.scoringTimeStamp = result.time
                self.scoringTimeIndex = 0
            })
            .disposed(by: disposeBag)
    }
    
    func uploadScoreData(poseData: [PoseData],
                         token: String,
                         data: String?) {
        self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap { (uc, _) in uc.gameRepository.postGamePoseData(poseData: poseData,
                                                                     token: token,
                                                                     data: data)}
            .withUnretained(self)
            .subscribe(onNext: { (uc, result) in
                print(result)
                uc.delegate?.getTotalScore(score: result.scores)
                uc.resultScoreData = result
                uc.delegate?.getScore(score: result.score)
                uc.delegate?.getAverageScore(avgScore: uc.getAverageScore(lastScores: result.scores.suffix(5)))
                
                uc.scoreData = result.scores
            },
                       onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
    
    func endGame(poseData: [PoseData], token: String) {
        self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap { (uc, _) in uc.gameRepository.postPlayEndGame(poseData: poseData, token: token)}
            .withUnretained(self)
            .subscribe(onNext: { (uc, _) in
                if let gameHandler = uc.gameHandler {
                    gameHandler.gameState = .finish
                }
            }, onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
}
extension ChallengeGameUseCase: GameProtocol {
    func getMusicDuration(time: Float, startTime: Float, endTime: Float) {}
    
    func getGameState(state: GameState) {
        delegate?.getGameState(state: state)
        if state == .completeGame {
            if let resultScoreData = self.resultScoreData, let endTime = self.endTime {
                DispatchQueue.main.async {
                    self.recordHandler?.didRecordingFinish(score: resultScoreData.score,
                                                           endTime: endTime,
                                                           poseData: self.poseData,
                                                           scoreData: self.scoreData) {
                        self.endGame(poseData: self.poseScoreData,
                                     token: self.scoreToken)
                    }
                }
            }
        }
    }
    
    func getBodyZoomRect(rect: CGRect) {
        delegate?.getBodyZoomRect(rect: rect)
    }
    
    func makePosition(data: [CGPoint]) -> CALayer {
        let layer = CALayer()
        for index in 0 ... data.count - 1 {
            let borderLayer = CALayer()
            borderLayer.frame = .init(x: data[index].x,
                                      y: data[index].y,
                                      width: 4,
                                      height: 4)
            borderLayer.cornerRadius = 2
            borderLayer.backgroundColor = UIColor.yellow.cgColor
            layer.addSublayer(borderLayer)
        }
        return layer
    }
    
    
    func getBodyPose(pose: [CGPoint], poseValue: [Float32], timeStamp: CMTime) {
        
        self.currentTime = timeStamp
        guard let gameHandler = self.gameHandler else {return}
        if gameHandler.gameState == .progress {
            //최초값 세팅
            if mesureStartTime == nil {
                mesureStartTime = timeStamp
            }
            
            self.currentTime = timeStamp
            let elapseTime = CMTimeSubtract(timeStamp, self.startTime ?? timeStamp).seconds
            
            //스켈레톤 그릴 데이터
            let mesureTime = CMTimeSubtract(timeStamp, self.mesureStartTime ?? timeStamp).seconds
            
            if elapseTime > 0.18 {
                self.startTime = timeStamp
                //서버에 보내 점수 받을 데이터
                self.poseData.append(.init(data: self.changePoseValueToPhoneRatio(pose: poseValue),
                                           time: Int(mesureTime * 1000)))
                if self.scoringTimeStamp.count != 0 {
                    let scoreTimeStamp = self.scoringTimeStamp.removeFirst()
                    self.poseScoreData.append(.init(data: poseValue, time: scoreTimeStamp))
                }
            }
            
            let layer = self.makePosition(data: pose)
            delegate?.getBodyPoseData(pose: layer)
        }
    }
    
    func changePoseValueToPhoneRatio(pose: [Float32]) -> [Float32] {
        var pointArray: [Float32] = []
        for index in stride(from: 0, to: pose.count - 1, by: 3) {
            pointArray.append(Float32(pose[index]))
            pointArray.append(Float32(pose[index + 1]))
        }
        return pointArray
    }
    
    func getPixelBuffer(pixelBuffer: CVPixelBuffer, timeStamp: CMTime) {
        self.delegate?.getPreviewImage(buffer: pixelBuffer)
        guard let gameHandler = self.gameHandler else {return}
        if gameHandler.gameState == .progress {
            self.recordHandler?.didRecording(buffer: pixelBuffer, time: timeStamp)
            self.endTime = timeStamp
        }
        
    }
    
    func getNeonLayer() {
        guard let gameHandler = self.gameHandler else {return}
        if let handler = gameHandler.neonHandler {
            self.delegate?.getNeonHandler(handler: handler)
        }
    }
    
    func getCountDownValue(count: Int) {
        self.delegate?.getCountDownValue(count: count)
        if count <= 6 && count != 1 {
            self.delegate?.getGameState(state: .startCountDown)
        }
        if count == 1 {
            if let currentTime = self.currentTime{
                self.startTime = currentTime
            }
            self.delegate?.getGameState(state: .progress)
            self.recordHandler?.startRecording()
        }
    }
    
}
