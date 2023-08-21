import UIKit
import AVFoundation
import CoreML
import VideoToolbox
import Vision
import VisionKit
import Sentry

protocol AiResultDataProtocol: AnyObject {
    func getData(buffer: CVPixelBuffer, data: [Float32], valueOfTimestamp: CMTime, confidence: [Float32])
}


class CoreMLModelHandler {
    // yolo model
    private var yoloModel: rtmpose_l_192x256?
    
    private var model: VNCoreMLModel?
    var request: VNCoreMLRequest?
    var handler: VNImageRequestHandler?
    var humanRectanguleRequest: VNDetectHumanRectanglesRequest?
    weak var delegate: AiResultDataProtocol?
    
    internal var isPredicting: Bool = false
    internal var isInferencePredicting: Bool = false
    
    var timeStamp: CMTime?
    var buffer: CVPixelBuffer?
    
    private var queue: DispatchQueue?
    internal var mesureInterverTime: [Double] = []
    internal var aiData: [Float32] = []
    
    
    deinit {
        self.yoloModel = nil
        self.model = nil
        self.request = nil
        self.handler = nil
        self.humanRectanguleRequest = nil
        self.buffer = nil
        self.timeStamp = nil
        self.queue = nil
        print("deinit model handler")
    }
    
    //bbox추출
    internal func getBBox(pixelBuffer: CVPixelBuffer, timeStamp: CMTime) {
        self.isPredicting = true
        humanRectanguleRequest = VNDetectHumanRectanglesRequest()
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .down)
        let imageRect: CGRect = .init(origin: .zero, size: .zero)
        
        self.humanRectanguleRequest?.upperBodyOnly = false
        do {
            try handler.perform([humanRectanguleRequest!])
            if let mainObservation = humanRectanguleRequest?.results {
                let bBox = VNImageRectForNormalizedRect(mainObservation.first?.boundingBox ?? imageRect,
                                                        720,
                                                        1280)
                let nomalizeBbox = CGRect(x: max(0, bBox.minX - 50),
                                          y: max(0, bBox.minY - 100),
                                          width: bBox.width + 100,
                                          height: bBox.height + 200)
                
                if let image = UIImage(pixelBuffer: pixelBuffer) {
                    let croppedImage = self.cropImage(image: image,
                                                      rect: nomalizeBbox)
                    guard let buffer = croppedImage.pixelBuffer() else {return}
                    self.setPixelBuffer(pixelBuffer: pixelBuffer, timeStamp: timeStamp)
                }
            }
        } catch {
            SentrySDK.capture(error: error)
        }
    }
    
    
    internal func setPixelBuffer(pixelBuffer: CVPixelBuffer, timeStamp: CMTime) {
        do {
            self.timeStamp = timeStamp
            self.buffer = pixelBuffer.deepCopy()
            self.handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
            try? self.handler!.perform([request!])
        } catch {
            SentrySDK.capture(error: error)
            print(error)
        }
    }
    
    internal func loadModel(completion: () -> Void) {
        do{
            let configuration1 = MLModelConfiguration()
            configuration1.computeUnits = .all
            self.yoloModel = try? rtmpose_l_192x256(configuration: configuration1)
            self.model = try VNCoreMLModel(for: self.yoloModel!.model)
            self.request = VNCoreMLRequest(model: self.model!, completionHandler: { [weak self] data, error in
               guard let self = self else {return}
                self.request?.imageCropAndScaleOption = .scaleFit
                if let observation = data.results?.first as? VNCoreMLFeatureValueObservation, let confidences = data.results?[1] as? VNCoreMLFeatureValueObservation {
                    let featureValue = observation.featureValue
                    let confienceValue = confidences.featureValue
                    if let multiArray = featureValue.multiArrayValue, let confidencesArray = confienceValue.multiArrayValue {
                        let confidencePointer = confidencesArray.dataPointer.bindMemory(to: Float32.self, capacity: confidencesArray.count)
                        let confidenceBuffer = UnsafeBufferPointer(start: confidencePointer, count: confidencesArray.count)
                        let ConfidenceArrayvalues = Array(confidenceBuffer)
                        
                        let pointer = multiArray.dataPointer.bindMemory(to: Float32.self, capacity: multiArray.count)
                        let buffer = UnsafeBufferPointer(start: pointer, count: multiArray.count)
                        let values = Array(buffer)
                        
                        if let pixelBuffer = self.buffer, let timeStamp = self.timeStamp {
                            self.delegate?.getData(buffer: pixelBuffer,
                                                   data: values,
                                                   valueOfTimestamp: timeStamp,
                                                   confidence: ConfidenceArrayvalues)
                            self.isPredicting = false
                        }
                    }
                }
            })
            completion()
            
        }
        catch{
            SentrySDK.capture(error: error)
            print(error)
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
    
}



