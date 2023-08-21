import Foundation
import AVFoundation
import RealmSwift
import Sentry

class RecordHandler: NSObject {
    private var videoOutput: AVCaptureMovieFileOutput = AVCaptureMovieFileOutput()
    var assetWriter: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    private var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    
    private var videoName: String = ""
    private var sessionData: PlaySessionDataModel?
    
    let frameRate: Float64 = 30
    let frameDuration = CMTimeMake(value: 1, timescale: 30)
    var frameCount: Int64 = 0

    override init() {
        super.init()
    }
    init(sessionData: PlaySessionDataModel) {
        super.init()
        self.sessionData = sessionData
    }
    
    func didRecordingReady(cameraHandler: CameraHandler) {
        self.videoOutput = AVCaptureMovieFileOutput()
        
        if cameraHandler.captureSession.canAddOutput(self.videoOutput) {
            cameraHandler.captureSession.addOutput(self.videoOutput)
        }
        
        
        let docFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        self.videoName = String(Date().timeIntervalSince1970)
        let outPutPath = docFolder.appending("/" + self.videoName)
        
        self.assetWriter = try! AVAssetWriter(url: URL(fileURLWithPath: outPutPath), fileType: .mp4)
        let videoSettings: [String : Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: 720,
            AVVideoHeightKey: 1280
        ]
        
        self.videoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)
        guard let videoInput = self.videoInput else {return}
        videoInput.expectsMediaDataInRealTime = true
        
        let sourcePixelBufferAttributes: [String : Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: 720,
            kCVPixelBufferHeightKey as String: 1280,
        ]
        self.pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoInput,
                                                                       sourcePixelBufferAttributes: sourcePixelBufferAttributes)
        
        self.assetWriter?.add(videoInput)
        self.assetWriter?.startWriting()
    }
    func startRecording() {
        self.assetWriter?.startSession(atSourceTime: .zero)
    }
    
    func didRecordingFinish(score: Float,
                            endTime: CMTime,
                            poseData: [PoseData],
                            scoreData: [Score],
                            completion: @escaping (() -> Void)) {
        guard let sessionData = self.sessionData else {return}
        guard let assetWriter = self.assetWriter else {return}
        
        DispatchQueue.main.async {
            self.videoInput?.markAsFinished()
            assetWriter.finishWriting { [weak self] in
                guard let strongSelf = self else { return }
                if assetWriter.status == .completed {
                    let presentationTime = CMTimeMake(value: strongSelf.frameCount * strongSelf.frameDuration.value,
                                                      timescale: strongSelf.frameDuration.timescale)
                    
                    let doucumentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let videoURL = doucumentDirectory.appendingPathComponent(strongSelf.videoName)
                    
                    if let sessionData = strongSelf.sessionData {
                        let combindVideoName = FfmpegHandler.combineVideoAudio(videoUrl: videoURL.absoluteString,
                                                                              audioUrl: sessionData.data.playDanceData.musicURL,
                                                                              startPosition: sessionData.data.playDanceData.startTime,
                                                                              endPosition: sessionData.data.playDanceData.endTime)
                        strongSelf.saveVideo(score: score,
                                             videoName: combindVideoName,
                                             poseData: poseData,
                                             scoreData: scoreData)
                        
                        strongSelf.assetWriter = nil
                        strongSelf.videoInput = nil
                        
                        completion()
                    } else {
                        print("Failed to finish writing")
                    }
                }
            }
        }
    }
    
    func didRecording(buffer: CVPixelBuffer, time: CMTime) {
        guard let videoInput = self.videoInput else {return}
        guard let assetWriter = self.assetWriter else {return}
        guard let pixelBufferAdaptor = self.pixelBufferAdaptor else {return}
        
        if videoInput.isReadyForMoreMediaData {
            print("넣는중넣는중")
            if assetWriter.status == .writing {
                let success = pixelBufferAdaptor.append(buffer, withPresentationTime: time)
                if !success {
                    print("Error appending pixel buffer: \(assetWriter.error?.localizedDescription ?? "Unknown Error")")
                }
                frameCount += 1
            }
        }
    }
    
    func saveVideo(score: Float,
                   videoName: String,
                   poseData: [PoseData],
                   scoreData: [Score]) {
        let realmRepository = RealmRepository()
        guard let data = self.sessionData?.data else {return}
        
            var videoData = VideoInfoTable(dance_id: data.playDanceData.danceID,
                                           video_url: videoName,
                                           created_at: Date(),
                                           dance_name: data.playDanceData.title,
                                           artist_name: data.playDanceData.artist,
                                           music_url: data.playDanceData.musicURL,
                                           start_time: data.playDanceData.startTime,
                                           end_time: data.playDanceData.endTime,
                                           score: score,
                                           sessionId: data.playSessionData?.sessionID ?? "",
                                           cover_url: data.playDanceData.coverURL)
            
            do {
                let realm = try Realm()
                    try realm.write {
                        videoData.poseDataList.removeAll()
                        poseData.forEach { pose in
                            videoData.poseDataList.append(pose.managedObject())
                        }
                        videoData.scoreDataList.removeAll()
                        scoreData.forEach { score in
                            videoData.scoreDataList.append(score.managedObject())
                        }
                        realm.add(videoData)
                        try realm.commitWrite()
                    }
            } catch {
                SentrySDK.capture(error: error)
                print("Error creating video: \(error)")
            }
    }
}
