import UIKit
import AVFoundation

protocol VideoCaptureDelegate: AnyObject {
    func onFrameCaptured(videoCapture: CameraHandler, pixelBuffer:CVPixelBuffer?, timestamp:CMTime)
}
