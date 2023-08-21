import UIKit
import AVFoundation
import CoreML
import VideoToolbox
import SnapKit
import Vision
import VisionKit
import Sentry

protocol BodyZoomDelegate: NSObject {
    func BodyPoseData(data: [CGPoint])
}

class BodyZoomHandler: NSObject {
    private var humanRectanguleRequest: VNDetectHumanRectanglesRequest? = VNDetectHumanRectanglesRequest()
    private var boundingBox: CGRect = CGRect(origin: .zero, size: .zero)
    var isPrediction: Bool = false
    weak var delegate: BodyZoomDelegate?
    
    private var bodyZoomRect: CGRect = .init(origin: .zero, size: CGSize(width: 720,
                                                                         height: 1280))
    private var rectTimestamp: CMTime?
    private var fromRect: CGRect?
    private var toRect: CGRect?
    
    override init() {
        super.init()
    }
    
    deinit {
        self.humanRectanguleRequest = nil
        self.delegate = nil
        print("deinit bodyzoom")
    }
    
    //바디 포즈 데이터로 바디줌 이미지 생성
    //timestamp
    func getBodyZoomRect(points: [CGPoint],
                         rootPoint: CGPoint,
                         imageHeight: CGFloat,
                         imageWidth: CGFloat,
                         timeStamp: CMTime) -> CGRect {
        var minX: CGFloat = 0
        var minY: CGFloat = 0
        var maxX: CGFloat = 0
        var maxY: CGFloat = 0
        
        
        if let minYPoints = points.min(by: { $0.y < $1.y }) {
            minY = minYPoints.y
        }
        
        if let maxYPoints = points.max(by: { $0.y < $1.y }) {
            maxY = maxYPoints.y
        }
        
        if let farPoint = points.max(by: { abs(rootPoint.x - $0.x) < abs(rootPoint.x - $1.x) }) {
            let width = abs(rootPoint.x - farPoint.x)
            minX = rootPoint.x - width
            maxX = rootPoint.x + width
        }
        
        let normalMinX = (minX / UIScreen.main.bounds.width) * 720
        let normalMaxX = (maxX / UIScreen.main.bounds.width) * 720
        let normalMinY = (minY / UIScreen.main.bounds.height) * 1280
        let normalMaxY = (maxY / UIScreen.main.bounds.height) * 1280
        
        let pointBbox = CGRect(x: normalMinX,
                               y: normalMinY,
                               width: abs(normalMaxX - normalMinX),
                               height: abs(normalMaxY - normalMinY))
        
        let bodyZoomRect = self.makeBodyZoomImage(width: imageWidth,
                                                  height: imageHeight,
                                                  rect: pointBbox,
                                                  timeStamp: timeStamp)
        return bodyZoomRect
    }
    
    func makeBodyZoomImage(width: CGFloat,
                           height: CGFloat,
                           rect: CGRect,
                           timeStamp: CMTime) -> CGRect {
        self.rectTimestamp = timeStamp
        let bbox = self.getImageRatioRect(rect: rect,
                                          imageWidth: width,
                                          imageHeight: height)
        if self.toRect == nil {
            self.fromRect = bbox
            self.toRect = bbox
        } else {
            self.fromRect = self.bodyZoomRect
            self.toRect = bbox
            self.rectTimestamp = timeStamp
        }
        
        if self.toRect != nil && self.fromRect != nil {
//            let duration = min(self.subtractCMTime(self.rectTimestamp ?? .zero, timeStamp), 500)
            let duration: Float = 0.05
            if let fromRect = fromRect, let toRect = toRect {
                self.bodyZoomRect = self.getInterpolationRectValue(from: fromRect,
                                                                   to: toRect,
                                                                   factor: duration)
            }
        }
        return self.bodyZoomRect
    }
    
    /**보간*/
    func getInterpolationRectValue(from: CGRect, to: CGRect, factor: Float) -> CGRect {
        let minX = from.minX + (to.minX - from.minX) * CGFloat(factor)
        let maxX = from.maxX + (to.maxX - from.maxX) * CGFloat(factor)
        let minY = from.minY + (to.minY - from.minY) * CGFloat(factor)
        let maxY = from.maxY + (to.maxY - from.maxY) * CGFloat(factor)
        
        
        return .init(origin: .init(x: minX,
                                   y: minY),
                     size: CGSize(width: abs(maxX - minX),
                                  height: abs(maxY - minY)))
    }
    
    public func getImageRatioRect(rect: CGRect,
                                  imageWidth: CGFloat,
                                  imageHeight: CGFloat) -> CGRect{
        let paddedRect = CGRect(origin: CGPoint(x: rect.minX - 40,
                                                y: rect.minY - 150),
                                size: CGSize(width: (rect.maxX - rect.minX) + 80,
                                             height: (rect.maxY - rect.minY) + 300))
        
        let centerX = (paddedRect.minX + paddedRect.maxX) / 2.0
        let centerY = (paddedRect.minY + paddedRect.maxY) / 2.0
        let width = (paddedRect.maxX - paddedRect.minX)
        let height = (paddedRect.maxY - paddedRect.minY)
        
        var resultMinX: CGFloat = 0
        var resultMinY: CGFloat = 0
        var resultMaxX: CGFloat = 0
        var resultMaxY: CGFloat = 0
        
        //width가 더 크니까 height을 width에 맞춰야 함
        if width / height > imageWidth / imageHeight {
            var targetHeight = imageHeight / imageWidth * width
            var halfWidth = width / 2.0
            var halfHeight = targetHeight / 2.0
            
            resultMinX = centerX - halfWidth
            resultMinY = centerY - halfHeight
            resultMaxX = centerX + halfWidth
            resultMaxY = centerY + halfHeight
            
            
            if resultMaxY > imageHeight {
                let factor = resultMaxY - imageHeight
                resultMaxY -= factor
                resultMinY -= factor
            }
            
            if (resultMaxY - resultMinY) > imageHeight {
                resultMinX = 0
                resultMinY = 0
                resultMaxX = imageWidth
                resultMaxY = imageHeight
            }
            
        } else {
            var targetWidth = imageWidth / imageHeight * height
            var halfWidth = targetWidth / 2.0
            var halfHeight = height / 2.0
            
            resultMinX = centerX - halfWidth
            resultMinY = centerY - halfHeight
            resultMaxX = centerX + halfWidth
            resultMaxY = centerY + halfHeight
            
            
            if resultMaxX > imageWidth {
                let factor = resultMaxX - imageWidth
                resultMaxX -= factor
                resultMinX -= factor
            }
            
            if (resultMaxX - resultMinX) > imageWidth {
                resultMinX = 0
                resultMinY = 0
                resultMaxX = imageWidth
                resultMaxY = imageHeight
            }
        }
        
        return CGRect(x: resultMinX,
                      y: resultMinY,
                      width: resultMaxX - resultMinX,
                      height: resultMaxY - resultMinY)
    }
    
    func subtractCMTime(_ time1: CMTime, _ time2: CMTime) -> Int {
        let timeDifference = CMTimeSubtract(time2, time1)
        let timeInSeconds = CMTimeGetSeconds(timeDifference)
        let milliseconds = Int(timeInSeconds * 1000)
        return milliseconds
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
