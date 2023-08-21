import UIKit
import AVFoundation
import CoreML
import VideoToolbox
import SnapKit
import Vision
import VisionKit
import Sentry

class AutoReadyHandler: NSObject{
    private var humanRectanguleRequest: VNDetectHumanRectanglesRequest?
    private var readyCount: Int = 0
    weak var delegate: AutoReadyProtocol?
    var isPrediction: Bool = false

    internal func getBBox(pixelBuffer: CVPixelBuffer) {
        self.isPrediction = true
        humanRectanguleRequest = VNDetectHumanRectanglesRequest()
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .down)
        let imageRect: CGRect = .init(origin: .zero, size: .zero)
        
        self.humanRectanguleRequest?.upperBodyOnly = false
        do {
            try handler.perform([humanRectanguleRequest!])
            
            if let mainObservation = humanRectanguleRequest?.results {
                let bBox = VNImageRectForNormalizedRect(mainObservation.first?.boundingBox ?? imageRect,
                                                        Int(UIScreen.main.bounds.width),
                                                        Int(UIScreen.main.bounds.height))
                self.autoReadyRecognizer(bbox: bBox)
                self.isPrediction = false
            }
        } catch {
            SentrySDK.capture(error: error)
        }
    }
    
    //MARK: - dispose
    internal func disposeModel() {
        if timer != nil {
            self.stopTimer()
        }
        self.humanRectanguleRequest?.cancel()
        self.humanRectanguleRequest = nil
    }
    deinit {
        print("deinit autoReady")
    }
    
    //MARK: - Timer
    var timer: Timer? = nil
    var isPause: Bool = true
    
    func startTimer() {
        guard self.timer == nil else { return }
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 1,
                                              target: self,
                                              selector: #selector(self.setCurrentValue),
                                              userInfo: nil,
                                              repeats: true)
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func setCurrentValue() {
        self.readyCount += 1
    }
    
    private func autoReadyRecognizer(bbox: CGRect) {
        /**
         (50,50) ~ (deviceWidth - 50, diviceHeight - 50)
         */
        if (bbox.minX > 50 && bbox.minY > 50) &&
            (bbox.maxX < (UIScreen.main.bounds.width - 50) &&
             bbox.maxY < (UIScreen.main.bounds.height + 10)){
            startTimer()
            
            if self.readyCount >= 2 {
                stopTimer()
                delegate?.isReadyComplete()
                self.humanRectanguleRequest = nil
            }
        } else {
            self.readyCount = 0
            stopTimer()
        }
        isPrediction = false
    }
}

