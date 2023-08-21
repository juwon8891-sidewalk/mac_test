import AVFoundation

class NeonRecorder {
    
    private var assetWriter: AVAssetWriter?
    private var assetWriterInput: AVAssetWriterInput?
    private var frameCount: Int = 0
    private var writerInputPixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    let frameDuration = CMTimeMake(value: 1, timescale: 24)
    
    private var neonVidoURL: String = ""
    private var musicURL: String = ""
    private var startTime: Float = 0
    private var endTime: Float = 0
    
    var recordEndCompletion: (() -> Void)?
    var combineEndCompletion: ((String) -> Void)?
    
    init() {
        
    }
    internal func setVideoCombineData(musicURL: String,
                                      startTime: Float,
                                      endTime: Float) {
        self.musicURL = musicURL
        self.startTime = startTime
        self.endTime = endTime
        self.initRecorder()
    }
    
    internal func initRecorder() {
        // 알아서 함수화 하셈
        let docFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let outPutPath = docFolder.appending("/test\(Date().timeIntervalSince1970).mp4")
        self.neonVidoURL = outPutPath
        
        self.assetWriter = try! AVAssetWriter(url: URL(fileURLWithPath: outPutPath), fileType: .mp4)
        let videoSettings: [String : Any] = [
            AVVideoCodecKey: AVVideoCodecType.hevc,
            AVVideoWidthKey: 720,
            AVVideoHeightKey: 1280
        ]

        self.assetWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)
        self.assetWriterInput!.expectsMediaDataInRealTime = true

        let sourcePixelBufferAttributes: [String : Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
            kCVPixelBufferWidthKey as String: 720,
            kCVPixelBufferHeightKey as String: 1280,
        ]
        
        self.writerInputPixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: self.assetWriterInput!, sourcePixelBufferAttributes: sourcePixelBufferAttributes)

        self.assetWriter!.add(self.assetWriterInput!)

    }
    
    internal func startRecording() {
        self.assetWriter!.startWriting()
        self.assetWriter!.startSession(atSourceTime: .zero)
    }
    
    internal func stopRecording() {
        self.assetWriter!.finishWriting {
            guard let completion = self.recordEndCompletion else {return}
            completion()
            self.videoCombineToMusic()
            print("endRecording")
        }
    }
    
    internal func disposeRecording() {
        if(self.assetWriter != nil) {
            self.assetWriter!.finishWriting {
                
            }
        }
    }
    
    internal func videoCombineToMusic() {
        let combineVideoName = FFmpegHelper.combineVideoAudio(videoUrl: self.neonVidoURL,
                                                              audioUrl: self.musicURL,
                                                              startPosition: self.startTime,
                                                              endPosition: self.endTime)
        
        guard let completion = self.combineEndCompletion else {return}
        completion(combineVideoName)
    }
    
    internal func getRecordImage(buffer: CVPixelBuffer) {
        let presentationTime = CMTimeMake(value: Int64(frameCount) * frameDuration.value,
                                          timescale: frameDuration.timescale)
        if self.assetWriter != nil {
            if self.assetWriterInput!.isReadyForMoreMediaData {
                let success = self.writerInputPixelBufferAdaptor!.append(buffer, withPresentationTime: presentationTime)
                if !success {
                    print("Error appending pixel buffer: \(self.assetWriter!.error?.localizedDescription ?? "Unknown Error")")
                }
                frameCount += 1
            }
        }
    }
    
}
