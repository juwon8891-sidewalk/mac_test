import AVFoundation
import Foundation

class NeonManager {
    private var generator: AVAssetImageGenerator?
    private var asset: AVAsset?
    private var color: CIColor
    private var duration: Float64 = 0
    private var frameCount: Float64 = 0
    private var recordStackCount: Int = 0
    
    private var isFirstPredicting: Bool = false
    private var isSecondPredicting: Bool = false
    private var isThirdPredicting: Bool = false
    
    var didNeonCreateEnd: ((String) -> Void)?
    
    private var handler: NeonCreateHandler?
    private var neonLoadingView: NeonLoadingView?
    
    private var recordHandler = NeonRecorder()
    
    private var recordedImage: [Int: UIImage] = [:]
    
    init(videoURL: URL,
         color: CIColor,
         musicUrl: String,
         startTime: Float,
         endTime: Float) {
        self.color = color
        self.initGenerator(videoURL: videoURL)
        self.initModels()
        self.recordHandler.setVideoCombineData(musicURL: musicUrl,
                                               startTime: startTime,
                                               endTime: endTime)
        self.setNeonColor(color)
        Task.init {
            await self.getDuration()
        }
    }
    func disposeNeonHandler() {
        self.handler = nil
        self.recordHandler.disposeRecording()
        self.recordHandler = NeonRecorder()
    }
    
    func setNeonLoadingView(_ neonLoadingView: NeonLoadingView) {
        self.neonLoadingView = neonLoadingView
    }
    
    func setNeonColor(_ color: CIColor) {
        self.handler?.setNeonColor(ciColor: color)
    }
    
    func initGenerator(videoURL: URL) {
        self.asset = AVAsset(url: videoURL)
        self.generator = AVAssetImageGenerator(asset: self.asset!)
    }
    
    func initModels() {
        self.handler = NeonCreateHandler(color: color)
        self.handler?.loadNeonModel()
    }
    
    func getDuration() async {
        do {
            self.duration = try await CMTimeGetSeconds((self.asset?.load(.duration))!) * 24
            self.runModels()
        } catch {
            print(error)
        }
    }
    
    func runModels() {
        self.recordHandler.startRecording()
        while true {
            guard let model = handler else {return}
            do {
                if !self.isFirstPredicting {
                    self.isFirstPredicting = true
                        autoreleasepool{
                            if let image = self.captureFrame(seconds: self.frameCount * 0.0416666667) {
                                do {
                                    let resultImage = try model.runModel(onFrame: image)
                                    self.isFirstPredicting = false
                                    self.recordedImage[Int(self.frameCount)] = resultImage
                                    self.frameCount += 1
                                    self.recordFrame()
//                                    if Int(self.frameCount) % 30 == 0 || Int(self.frameCount) == 1 {
                                        self.neonLoadingView?.setEstimateTime(totalFrame: Int(self.duration),
                                                                              currentFrame: Int(self.frameCount),
                                                                              inferenceTime: Float(model.infrenceTime))
//                                    }
                                    self.recordHandler.recordEndCompletion = {
//                                        self.neonLoadingView?.stopTimer()
                                        DispatchQueue.main.async {
                                            self.neonLoadingView?.loadingBackgroundView.isHidden = false
                                            self.neonLoadingView?.circleLoadingView.play()
                                        }
                                    }
                                    self.recordHandler.combineEndCompletion = { [weak self] videoName in
                                        guard let strongSelf = self else {return}
                                        DispatchQueue.main.async {
                                            strongSelf.neonLoadingView?.isHidden = true
                                        }
                                        guard let completion = strongSelf.didNeonCreateEnd else {return}
                                        completion(videoName)
                                    }
                                } catch {
                                    
                                }
                            }
                        }
                }
            } catch {
                
            }
            
            if Int(self.frameCount) >= Int(self.duration) {
                break
            }
        }
    }
    
    func recordFrame() {
        self.recordedImage.forEach { (key, value)  in
            guard let buffer = value.buffer() else {return}
            if key == self.recordStackCount {
                self.recordHandler.getRecordImage(buffer: buffer)
                self.recordedImage.removeValue(forKey: key)
                self.recordStackCount += 1
            }
        }
        if Int(self.recordStackCount) >= Int(self.duration) {
            self.recordHandler.stopRecording()
        }
    }
    
    func captureFrame(seconds: Float64) -> UIImage? {
        generator?.requestedTimeToleranceBefore = .zero
        generator?.requestedTimeToleranceAfter = .zero
        generator?.appliesPreferredTrackTransform = true
        
        let track = asset!.tracks(withMediaType: AVMediaType.video).first!
        let time = CMTime(seconds: seconds, preferredTimescale: track.naturalTimeScale)
        var actualTime = CMTime.zero
        let imageRef: CGImage
        do {
            imageRef = try generator!.copyCGImage(at: time, actualTime: &actualTime)
            return UIImage(cgImage: imageRef)
        } catch {
            print("Error generating frame: \(error.localizedDescription)")
            return nil
        }
    }
}



