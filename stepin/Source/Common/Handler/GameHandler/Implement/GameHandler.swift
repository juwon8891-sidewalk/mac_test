import Foundation
import UIKit
import AVFoundation
import Vision

class GameHandler: NSObject {
    //1. 오토레디 기능
    private var autoReayHandler: AutoReadyHandler? = AutoReadyHandler()
    //2. 바디줌
    private var bodyZoomHandler: BodyZoomHandler? = BodyZoomHandler()
    //3. 네온
    var neonHandler: NeonPlayHandler?
    //4. 사운드
    var musicPlayer: MusicPlayer?
    //5. 카메라
    var videoCapture: CameraHandler? = CameraHandler()
    //6. 카운트다운 핸들러
    private var countDownHandler: CountDownHandler? = CountDownHandler()
    //7. bodyZoom을 위한 모델 핸들러
    var modelHandler: CoreMLModelHandler? = CoreMLModelHandler()
    
    
    //MARK: - Variable
    weak var delegate: GameProtocol?
    var cameraOrientMode: AVCaptureDevice.Position = .front
    var startTime: CGFloat = 0
    var endTime: CGFloat = 0
    var startNeonFlag: Bool = false
    

    private var _gameState: GameState = .none
    var gameState: GameState {
        get {
            return _gameState
        }
        set (newState) {
            _gameState = newState
            switch _gameState {
            case .none:
                break
            case .loadingComplete:
                self.initHandlerDelegate()
                self.autoReayHandler?.startTimer()
                self.neonHandler?.setIndex(index: 0)
                break
            case .startCountDown:
                self.musicPlayer?.setTimeToMusic(time: Float(self.startTime - 6)) { [weak self] _ in
                    guard let strongSelf = self else {return}
                    strongSelf.musicPlayer?.play()
                    strongSelf.countDownHandler?.startTimer()
                }
                break
            case .progress:
                self.startNeonFlag = true
                break
            case .completeGame:
                self.delegate?.getGameState(state: .completeGame)
                break
            case .finish:
                self.delegate?.getGameState(state: .finish)
                break
            }
        }
    }
    
    func disposeHandler() {
        self.musicPlayer?.pause()
        self.musicPlayer = nil
        self.videoCapture?.asyncStopCapturing { [weak self] in
            guard let strongSelf = self else {return}
            strongSelf.videoCapture = nil
            strongSelf.videoCapture?.delegate = nil
        }
        self.musicPlayer?.delegate = nil
        self.autoReayHandler?.delegate = nil
        self.countDownHandler?.delegate = nil
        self.bodyZoomHandler?.delegate = nil
        self.modelHandler?.delegate = nil
        self.autoReayHandler = nil
        self.bodyZoomHandler = nil
        self.neonHandler = nil
        self.countDownHandler = nil
        self.modelHandler = nil
    }
    
    override init() {
        super.init()
        self.startCapturing()
    }
    
    deinit {
        print("gameHandler deinit")
    }
    
    //MARK: - initializing handler
    func initMusicPlayer(musicPath: String,
                         startTime: Float,
                         endTime: Float){
        self.musicPlayer = MusicPlayer(musicPath: musicPath,
                                       startTime: startTime - 6,
                                       endTime: endTime)
        self.startTime = CGFloat(startTime)
        self.endTime = CGFloat(endTime)
    }
    
    func initNeonHandler(neonPath: String,
                         neonLineColor: UIColor,
                         neonBlurColor: UIColor) {
        self.neonHandler = NeonPlayHandler(neonPath: neonPath,
                                           neonLineColor: neonLineColor,
                                           neonBlurColor: neonBlurColor)
    }
    
    private func initHandlerDelegate() {
        self.videoCapture?.delegate = self
        self.musicPlayer?.delegate = self
        self.autoReayHandler?.delegate = self
        self.countDownHandler?.delegate = self
        self.bodyZoomHandler?.delegate = self
        self.modelHandler?.delegate = self
    }
    
    private func startCapturing() {
        if ((self.videoCapture?.initCamera(self.cameraOrientMode)) != nil) {
            self.videoCapture?.asyncStartCapturing()
        }else{
            fatalError("Fail to init Video Capture")
        }
    }
    
    func setCameraOrient() {
        if self.cameraOrientMode == .front {
            self.cameraOrientMode = .back
        } else {
            self.cameraOrientMode = .front
        }
        self.videoCapture?.initCamera(self.cameraOrientMode)
    }
    
    //MARK: - readyGame
    
    //MARK: - playGame
    //해당 부분의 경우 challenge와 practice의 로직이 다름
    
    //MARK: - endGame
    //해당 부분의 경우 challenge와 practice의 로직이 다름
    
    
    
}

extension GameHandler: VideoCaptureDelegate {
    func onFrameCaptured(videoCapture: CameraHandler, pixelBuffer: CVPixelBuffer?, timestamp: CMTime) {
        guard let buffer = pixelBuffer else {return}
//        guard let modelHandler = self.modelHandler else {return}
        guard let autoReayHandler = self.autoReayHandler else {return}
        
        if let copyBuffer = buffer.deepCopy() {
            DispatchQueue.global().async { [weak self] in
                guard let strongSelf = self else {return}
                if strongSelf.gameState != .completeGame {
                    strongSelf.delegate?.getPixelBuffer(pixelBuffer: copyBuffer, timeStamp: timestamp)
                }
            }
        }
        
        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else {return}
            guard let modelHandler = strongSelf.modelHandler else {return}
            if !modelHandler.isPredicting {
                modelHandler.getBBox(pixelBuffer: buffer, timeStamp: timestamp)
            }
        }
        
        
        switch gameState {
        case .none:
            break
        case .loadingComplete:
            if !autoReayHandler.isPrediction {
                autoReayHandler.getBBox(pixelBuffer: buffer)
            }
        case .startCountDown:
            break
        case .progress:
            break
        case .completeGame:
            break
        case .finish:
            break
        }
        
    }
}
extension GameHandler: MusicPlayerProtocol {
    func getCurrentMusicTime(_ time: CGFloat) {
        if startTime <= self.endTime && self.startNeonFlag && self.gameState == .progress {
            let index = max(0, Int((time - startTime) * 30))
            self.neonHandler?.setIndex(index: index)
            self.delegate?.getMusicDuration(time: max(0, Float(time - startTime)),
                                            startTime: Float(self.startTime),
                                            endTime: Float(self.endTime))
        }
        if time >= self.endTime {
            self.musicPlayer?.pause()
            if self.gameState != .completeGame && self.gameState != .startCountDown {
                self.gameState = .completeGame
            }
        }
    }
}
extension GameHandler: AutoReadyProtocol {
    func isReadyComplete() {
        self.gameState = .startCountDown
    }
}
extension GameHandler: CountDownProtocol {
    func countdownStatus(count: Int) {
        if self.gameState == .startCountDown {
            delegate?.getCountDownValue(count: count)
            if count == 1 {
                self.gameState = .progress
            }
        }
    }
}
extension GameHandler: BodyZoomDelegate {
    func BodyPoseData(data: [CGPoint]) {
    }
}
extension GameHandler: AiResultDataProtocol {
    func makePoseRequest(data: [Float32], confidence: [Float32]) -> [Float32] {
        var returnArray: [Float32] = []
        var confidenceIndex = 0
        for index in stride(from: 0, to: data.count - 1, by: 2) {
            returnArray.append(data[index]) //x
            returnArray.append(data[index + 1]) //y
            returnArray.append(confidence[confidenceIndex])
            confidenceIndex += 1
        }
        return returnArray
    }
    func getData(buffer: CVPixelBuffer, data: [Float32], valueOfTimestamp: CMTime, confidence confidences: [Float32]) {
        print(data)
        //포즈 데이터 전달
        var nomalizedPoint: [CGPoint] = []
        for index in stride(from: 0, to: data.count - 1, by: 2) {
            let point = CGPoint(x: Double(data[index]),
                                y: Double(data[index + 1]))
            
            let scaledImageWidth = (UIScreen.main.bounds.height / (256 / 192))
            let leftPadding = (scaledImageWidth - UIScreen.main.bounds.width) / 2
            
            let normalPoint = VNNormalizedPointForImagePoint(point,
                                                             720,
                                                             1280)
            let imagePoint = VNImagePointForNormalizedPoint(normalPoint,
                                                            720,
                                                            1280)
//            nomalizedPoint.append(.init(x: ((imagePoint.x / 192) * scaledImageWidth) - leftPadding,
//                                        y: (imagePoint.y / 256) * UIScreen.main.bounds.height))
            
            nomalizedPoint.append(.init(x: ((imagePoint.x / 192) * 720),
                                        y: (imagePoint.y / 256) * 1280))
        }
        print(nomalizedPoint)
        
        let rootPoint = CGPoint(x: (nomalizedPoint[11].x + nomalizedPoint[12].x) / 2,
                                y: (nomalizedPoint[11].y + nomalizedPoint[12].y) / 2)
        
        //normal point -> 실제 좌표 데이터
        //root point -> poseValue
        self.delegate?.getBodyPose(pose: nomalizedPoint,
                                   poseValue: self.makePoseRequest(data: data, confidence: confidences),
                                   timeStamp: valueOfTimestamp)
        let scaledImageWidth: CGFloat = (720 / (256 / 192))
        let scaledImageHeight: CGFloat = (1280 / (256 / 192))
        if let bodyZoomRect = self.bodyZoomHandler?.getBodyZoomRect(points: nomalizedPoint,
                                                                    rootPoint: rootPoint,
                                                                    imageHeight: 1280,
                                                                    imageWidth: scaledImageWidth,
                                                                    timeStamp: valueOfTimestamp) {
            self.delegate?.getBodyZoomRect(rect: bodyZoomRect)
        }
    }
}
