import Foundation
import UIKit
import AVFoundation
import Sentry

class CameraHandler : NSObject{
    public weak var delegate: VideoCaptureDelegate?
    let captureSession = AVCaptureSession()
    let sessionQueue = DispatchQueue(label: "session queue", qos: .userInteractive)
    let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera,
                                                                          .builtInDualCamera,
                                                                          .builtInWideAngleCamera],
                                                            mediaType: .video,
                                                            position: .unspecified)
    private var isMirrorMode: Bool = true
    /**
     Frames Per Second; used to throttle capture rate
     */
    public var fps = 60
    
    //mirrormode 수정
    
    var lastTimestamp = CMTime()
    
    override init() {
        super.init()
    }
    
    deinit {
        self.delegate = nil
        print("deinit camera")
    }
    
    func bestDevice(in position: AVCaptureDevice.Position) -> AVCaptureDevice {
        let devices = self.discoverySession.devices
        guard !devices.isEmpty else {
            SentrySDK.capture(event: .init(level: .error))
            fatalError("Missing capture devices.")
        }
        
        devices.forEach {
            print($0.position.rawValue)
        }
        
        return devices.first(where: { device in device.position == position })!
    }
    
    func initCamera(_ position: AVCaptureDevice.Position) -> Bool{
        // 여러 구성 처리를 일괄 작업한다는 신호를 보낸다. 변경사항은 commitConfiguration 메서드르 호출해야 반영된다.
        captureSession.beginConfiguration()
        //원하는 품질을 고른다.
        
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1280x720
        guard let captureDevice = AVCaptureDevice.default(bestDevice(in: position).deviceType,
                                                          for: AVMediaType.video,
                                                          position: position) else{
            print("ERROR : no video device available")
            return false
        }
        if captureDevice.position == .front {
            self.isMirrorMode = true
        } else {
            self.isMirrorMode = false
        }
        
        captureSession.inputs.forEach {
            captureSession.removeInput($0)
        }
        guard let videoInput = try? AVCaptureDeviceInput(device: captureDevice) else{
            print("ERROR : could not create AVCaptureDeviceInput")
            return false
        }
        if captureSession.canAddInput(videoInput){
            captureSession.addInput(videoInput)
        }
        
        //프레임의 도착지
        let videoOutput = AVCaptureVideoDataOutput()
        let settings:[String:Any] = [
            kCVPixelBufferPixelFormatTypeKey as String : NSNumber(value: kCVPixelFormatType_32BGRA) //풀컬러
        ]
        videoOutput.videoSettings = settings
        videoOutput.alwaysDiscardsLateVideoFrames = false // 디스패치 큐가 사용중일 때 도착한 프레임은 모두 폐기된다.
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue) // 디스패치 큐로 유입된 프레임을 전달하는 델리게이트를 구현한다.
        
        captureSession.outputs.forEach {
            captureSession.removeOutput($0)
        }
        
        
        if captureSession.canAddOutput(videoOutput){
            captureSession.addOutput(videoOutput) // 출력의 구성요청의 일부로 세션에 추가한다.
        }
        videoOutput.connection(with: AVMediaType.video)?.videoOrientation = .portrait // 이미지가 회전하는것을 방지하기위해 세로방향으로 요청한다.
        captureSession.commitConfiguration() // 구성을 커밋하여 변경사항을 반영한다.
       
        return true
    }
    
    /**
     Start capturing frames
     This is a blocking call which can take some time, therefore you should perform session setup off
     the main queue to avoid blocking it.
     */
    public func asyncStartCapturing(completion: (() -> Void)? = nil){
        //startRunning 과 stopRunnin은 메인 스레드를 block 하기 때문에
        //UI버벅이지 않게 하려면 메인 스레드와 분리해서 실행한다.
        sessionQueue.async {
            if !self.captureSession.isRunning{
                //startRunning을 호출하면 카메라(입력)으로 부터 델리게이트(출력)까지 데이터 흐름이 시작된다.
                self.captureSession.startRunning()
            }
            if let completion = completion {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    /**
     Stop capturing frames
     */
    public func asyncStopCapturing(completion: (() -> Void)? = nil){
        if self.captureSession.isRunning{
            self.captureSession.stopRunning()
        }
        if let completion = completion {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    /**
     Zoom camera
     */
    public func zoom(Position: AVCaptureDevice.Position,
                     zoomScale: CGFloat) {
        let device = self.bestDevice(in: Position)
        
        var initialScale: CGFloat = device.videoZoomFactor
        let minAvailableZoomScale = 1.0
        let maxAvailableZoomScale = device.maxAvailableVideoZoomFactor
        
        do {
            try device.lockForConfiguration()
            if(zoomScale < minAvailableZoomScale){
                device.videoZoomFactor = minAvailableZoomScale
            }
            else if(zoomScale > maxAvailableZoomScale){
                device.videoZoomFactor = maxAvailableZoomScale
            } else {
                device.videoZoomFactor = zoomScale
            }
        } catch {
            return
        }
        device.unlockForConfiguration()
        
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraHandler: AVCaptureVideoDataOutputSampleBufferDelegate{
    /**
     Called when a new video frame was written
     */
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //output은 AVCaptureVideoDataOutput 형식이고 프레임 관련 출력이다.
        //sample buffer는 CMSampleBuffer 형식이고 프레임의 데이터 접근을 위해 사용된다
        
        connection.isVideoMirrored = self.isMirrorMode
        guard let delegate = self.delegate else { return } //delegate가 할당되지 않았을 경우를 방지한다.
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)//최신 프레임과 관련된 시간을 얻는다.
        
        let elapsedTime = timestamp - lastTimestamp
        if elapsedTime >= CMTimeMake(value: 1, timescale: Int32(fps)){
            lastTimestamp = timestamp
            let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)//충분한 시간이 지난 뒤 샘플의 이미지 버퍼에 대한 참조를 얻어 델리게이트에 전달한다.
            
            delegate.onFrameCaptured(videoCapture: self, pixelBuffer: imageBuffer, timestamp: timestamp)
        }
    }
}
