import AVFoundation
import UIKit
import Lottie

@available(iOS 16.0, *)
class BaseVideoView: UIView {
    internal var isPlaying: Bool = false
    internal var didLoad: Bool = false
    internal var currentVideoIsPlay: Bool = false
    internal var timeObserver: Any?
    private var playerItemContext = 0
    
    open var player = AVPlayer()
    internal var playerLayer = AVPlayerLayer()
    
    internal var loadingView = LottieAnimationView(name: "loading")
    
    //MARK: - initFunc
    init() {
        super.init(frame: .zero)
        setPlayerLayer()
        setLoadingView()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .stepinWhite20
        setPlayerLayer()
        setLoadingView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    private func setLoadingView() {
        self.backgroundColor = .stepinWhite20
        self.addSubview(loadingView)
        loadingView.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 100))
        }
        loadingView.play()
        loadingView.loopMode = .loop
    }
    
    internal func setLoadingViewHidden() {
        DispatchQueue.main.async {
            self.loadingView.stop()
            self.loadingView.isHidden = true
        }
    }
    
    open func setPlayerLayer() {
        self.playerLayer = AVPlayerLayer()
        playerLayer.frame = self.bounds
        playerLayer.videoGravity = .resizeAspectFill
        self.layer.addSublayer(self.playerLayer)
    }
    
    
    internal func initVideo(videoPath: URL) {
        self.loadingView.isHidden = false
        self.loadingView.play()
        self.playerLayer.player = nil
        let asset = AVURLAsset(url: videoPath)
        let item = AVPlayerItem(asset: asset)
        self.player.replaceCurrentItem(with: item)
        self.playerLayer.player = self.player
        self.player.addObserver(self,
                                forKeyPath: #keyPath(AVPlayerItem.status),
                                options: [.old, .new],
                                context: &self.playerItemContext)
    }
    

    
    //MARK: - controll Func
    internal func isLayerReadyForDisplay() -> Bool {
        return self.playerLayer.isReadyForDisplay
    }
    
    internal func playVideo() {
        self.player.play()
    }
    
    internal func pauseVideo() {
        self.player.pause()    }
    
    internal func muteOn() {
        self.player.isMuted = true
    }
    
    internal func muteOff() {
        self.player.isMuted = false
    }
    
    internal func stopVideo() {
        self.player.replaceCurrentItem(with: nil)
    }
    
    
    internal func setFrameToVideo(currentValue: Float) {
        let seconds = Double(currentValue) / Double(30)
        let oneFrame = CMTime(seconds: seconds, preferredTimescale: 600)
        let addTime = CMTimeAdd(CMTime(value: 0, timescale: 600), oneFrame)
        self.player.seek(to: addTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    
    internal func setTimeToVideo(time: Float) {
        let oneFrame = CMTime(seconds: Double(time), preferredTimescale: 600)
        let addTime = CMTimeAdd(CMTime(value: 0, timescale: 600), oneFrame)
        self.player.seek(to: addTime)
    }
    
    
    //kvo to avplayer to isready ,failed, unknown
    //Key value obserbing to avplayer is ready to play
    override internal func observeValue(forKeyPath keyPath: String?,
                                        of object: Any?,
                                        change: [NSKeyValueChangeKey : Any]?,
                                        context: UnsafeMutableRawPointer?) {
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            
            // Switch over status value
            switch status {
            case .readyToPlay:
                break
            case .failed:
                break
            case .unknown:
                break
            }
        }
        
    }
    
}
