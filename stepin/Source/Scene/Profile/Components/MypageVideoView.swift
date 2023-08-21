import Foundation
import UIKit
import AVFoundation
import Lottie


@available(iOS 16.0, *)
class MyPageVideoView: UIView {
    internal var isPlaying: Bool = false
    internal var didLoad: Bool = false
    internal var currentVideoIsPlay: Bool = false
    private var playerItemContext = 0
    
    var isCriteriaVideo: Bool = false
    var isValueUse: Bool = false
    var playTime: Float = 0
    
    
    var isPlayEnd: Bool = false
    
    
    open var player = AVPlayer()
    internal var playerLayer = AVPlayerLayer()
    private var loadingView = LottieAnimationView(name: "loading")
    private var currentVideoIndex: Int = 0

    
    //MARK: - initFunc
    init() {
        super.init(frame: .zero)
//        setPlayerLayer()
        setLoadingView()
    }
    
    internal func disposeVideoView() {
        self.player.replaceCurrentItem(with: nil)
        self.playerLayer.removeFromSuperlayer()
    }
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
//        setPlayerLayer()
        setLoadingView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    private func setLoadingView() {
        self.backgroundColor = .stepinBlack100
        self.addSubview(loadingView)
        loadingView.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 100))
        }
        loadingView.play()
        loadingView.loopMode = .loop
        loadingView.isHidden = true
    }
    
    open func setPlayerLayer() {
        self.playerLayer = AVPlayerLayer()
        playerLayer.frame = self.bounds
        playerLayer.videoGravity = .resize
        playerLayer.isOpaque = true
        self.layer.addSublayer(self.playerLayer)
    }
    
    
    internal func initVideo(videoPath: URL) {
        self.setPlayerLayer()
        self.playerLayer.player = nil
        let asset = AVURLAsset(url: videoPath)
        let item = AVPlayerItem(asset: asset)
        self.player.replaceCurrentItem(with: item)
        self.playerLayer.player = self.player
        self.player.addObserver(self,
                                forKeyPath: #keyPath(AVPlayerItem.status),
                                options: [.old, .new],
                                context: &self.playerItemContext)
        self.startTimer()
    }
    
    internal func refreshVideoLayer() {
        self.layer.setNeedsDisplay()
    }
    
    
    //MARK: - Timer
    var timer: Timer? = nil

    open func startTimer() {
        guard timer == nil else { return }
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 0.1,
                                              target: self,
                                              selector: #selector(self.isReadyToPlay),
                                              userInfo: nil,
                                              repeats: true)
        }
    }

    open func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func isReadyToPlay() {
        if self.playerLayer.isReadyForDisplay {
            // 미디어 컨텐츠가 로드되어 준비된 상태인 경우
            // playerLayer를 view의 layer에 추가하면 미디어 컨텐츠가 화면에 표시됩니다.
            self.loadingView.stop()
            self.loadingView.isHidden = true
            self.stopTimer()
            self.didLoad = true
        } else {
            // 미디어 컨텐츠가 로딩 중인 경우
        }
    }
    
    //MARK: - controll Func
    internal func playVideo() {
        self.isPlaying = true
        self.player.play()
    }
    
    internal func pauseVideo() {
        if self.isPlaying {
            self.player.pause()
            self.isPlaying = false
        }
    }
    
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
    
    internal func setTimeToVideo(time: Float, completion: @escaping (Bool) -> Void) {
        let oneFrame = CMTime(seconds: Double(time), preferredTimescale: 600)
        let addTime = CMTimeAdd(CMTime(value: 0, timescale: 600), oneFrame)
        self.player.pause()
        self.player.seek(to: addTime, completionHandler: completion)
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
                playVideoObserving()
                break
            case .failed:
                break
            case .unknown:
                break
            }
        }
        
    }
    var timeObserver: Any?
    internal func playVideoObserving() {
        self.timeObserver = self.player.addPeriodicTimeObserver(forInterval: CMTime.init(value: 1, timescale: 600), queue: .main, using: { time in
            if let duration = self.player.currentItem?.duration {
                let duration = CMTimeGetSeconds(duration), time = CMTimeGetSeconds(time)
                print(duration, time)
                if floor(time) >= floor(duration) {
                    self.isPlayEnd = true
                } else {
                    self.isPlayEnd = false
                }
            }
        })
    }
    
    internal func removeVideoObserving() {
        if let timeObserver = timeObserver {
            self.player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }
}
