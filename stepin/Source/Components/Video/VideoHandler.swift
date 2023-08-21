import Foundation
import AVFoundation

enum VideoStatus {
    case none
    case loading
    case initialized
    case playing
    case paused
}

class VideoHandler: NSObject, ObservableObject {
    internal var videoPlayer: AVPlayer?
    internal var videoPlayerLayer: AVPlayerLayer = AVPlayerLayer()
    
    let videoPath: URL
    private var layer: CALayer?
    
    var playerItemContext = 0
    @Published var videoStatus = VideoStatus.none
    
    var asset: AVAsset?
    var item: AVPlayerItem?
    var isAutoPlay : Bool = false
    
    internal var timeObserver: Any?
    
    var currentVideoTime: Float = 0
    var currentVideoDuration: Float = 0
    var videoLoopCallback: (() -> Void)? = nil
    var initializedCallback: (() -> Void)? = nil
    var releasedCallback: (() -> Void)? = nil
    
    init(videoPath: URL) {
        self.videoPath = videoPath
        super.init()
    }
    
    func setTargetLayer(layer: CALayer) {
        self.layer = layer
    }
    
    func reinitialize(isAutoPlay: Bool = false) {
        if videoStatus == .none {
            videoStatus = .loading
            initialize()
            setVideoPlayerLayer(layer: self.layer)
        } else {
            if isAutoPlay {
                self.play()
            }
            else {
                self.pause()
            }
        }
        
        self.isAutoPlay = isAutoPlay
    }
    
    
    private func initialize() {
        self.videoPlayer = AVPlayer()
        getVideoItem()
        self.videoPlayer!.replaceCurrentItem(with: item)
        self.videoPlayer!.addObserver(self,
                                     forKeyPath: #keyPath(AVPlayerItem.status),
                                     options: [.old, .new],
                                     context: &self.playerItemContext)
        self.addVideoTimer()
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: self.item)
        
        self.videoPlayerLayer.player = self.videoPlayer
    }
    
    private func getVideoItem() {
        self.asset = AVURLAsset(url: self.videoPath)
        if let data = asset {
            self.item = AVPlayerItem(asset: data)
        }
        
    }
    
    // 외부에서 호출하도록 하자
    func setVideoPlayerLayer(layer: CALayer?) {
        self.videoPlayerLayer.frame = layer?.bounds ?? .zero
        self.videoPlayerLayer.videoGravity = .resizeAspectFill
        layer?.addSublayer(self.videoPlayerLayer)
    }
    
    func resize(size: CGSize) {
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.videoPlayerLayer.frame = .init(origin: .center, size: size)
        }
    }
    
    func addVideoTimer() {
        self.timeObserver = videoPlayer?.addPeriodicTimeObserver(forInterval: CMTime.init(value: 1, timescale: 600), queue: .main, using: { [weak self] time in
            guard let self = self else {return}
            if let duration = videoPlayer?.currentItem?.duration {
                let videoDuration = CMTimeGetSeconds(duration), time = CMTimeGetSeconds(time)
                currentVideoDuration = Float(videoDuration)
                currentVideoTime = Float(time)
            }
            
            if  self.videoStatus != .initialized {
                self.videoStatus = .initialized
                initializedCallback?()
            }
            
            videoLoopCallback?()
        })
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let initCondition = self.videoPlayer?.status else { return }
        
        
    
        guard let condition = self.videoPlayer?.timeControlStatus else { return }
        DispatchQueue.main.async {[weak self] in
            guard let self = self else { return }
            if condition == .playing {
                self.videoStatus = .playing
            }
            else if condition == .paused {
                self.videoStatus = .paused
            }
        }
    }
    
    @objc func playerDidFinishPlaying() {
        self.reset(isAutoPlay: self.isAutoPlay)
    }
    
    internal func play() {
        self.videoPlayer?.play()
    }
    
    internal func pause() {
        self.videoPlayer?.pause()
    }
    
    internal func setMute(isMuting: Bool) {
        self.videoPlayer?.isMuted = isMuting
    }
    
    internal func seekTo(time: Float, callback: (() -> Void)?) {
        let oneFrame = CMTime(seconds: Double(time), preferredTimescale: 600)
        let addTime = CMTimeAdd(CMTime(value: 0, timescale: 600), oneFrame)
        self.videoPlayer?.seek(to: addTime, completionHandler:  { [weak self] success in
            if success {
                callback?()
            }
        })
    }
    
    func reset(isAutoPlay: Bool) {
        self.videoPlayer?.pause()
        
        let oneFrame = CMTime(seconds: Double(0), preferredTimescale: 600)
        self.videoPlayer?.seek(to: oneFrame, completionHandler: { [weak self] success in
            if success {
                if isAutoPlay {
                    self?.videoPlayer?.play()
                }
            } else {
                print("Seek failed")
            }
        })
    }
    
    func release() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if videoStatus != .loading {
                NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
                self.videoPlayer?.pause()
                self.videoPlayer?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
                self.videoPlayer?.removeTimeObserver(self.timeObserver)
                self.videoPlayer?.replaceCurrentItem(with: nil)
                self.videoPlayerLayer.removeFromSuperlayer()
                
                self.asset = nil
                self.item = nil
                self.videoPlayer = nil
                
                self.timeObserver = nil
                self.videoStatus = .none
                
                releasedCallback?()
            }
        }   
    }
    
    deinit {
        release()
        print("DEINITED")
    }
    
}
