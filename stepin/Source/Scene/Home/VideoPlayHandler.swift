import Foundation
import AVFoundation

enum VideoPlayState {
    case isLoading
    case isReadyToPlay
    case isPlay
    case isPause
    case isEndToPlay
}
enum VideoShowState {
    case show
    case notShow
}

protocol VideoHandlerDelegate: AnyObject {
    func getCurrentVideo(data: Video)
    func getCurrentPlayTime(time: Float, totalPlayTime: Float)
}

class VideoPlayHandler: NSObject {
    internal var videoPlayState: VideoPlayState = .isLoading
    internal var videoShowStatus: VideoShowState = .notShow
    private var videoView: BaseVideoView?
    
    
    internal var videoId: String = ""
    internal var danceId: String = ""
    internal var userId: String = ""
    internal var likeCount: Int = 0
    internal var commentCount: Int = 0
    
    
    private var _currentIndex: Int = 0
    internal var currentIndex: Int {
        get {
            return _currentIndex
        }
        set(value) {
            if value != currentIndex {
                self.isSendData = false
            }
            _currentIndex = value
        }
    }
    private var section: [Section]? = []
    private var videoViewData: SuperShortform?
    private var isSendData: Bool = false
    
    weak var delegate: VideoHandlerDelegate?
    
    init(seekTimeList: [Section]? = nil,
         videoView: BaseVideoView,
         videoData: SuperShortform? = nil) {
        super.init()
        self.section = seekTimeList
        self.videoViewData = videoData
        self.videoView = videoView
        self.startObserbingLayer()
    }
    //MARK: - setData
    internal func setData(userId: String,
                          danceId: String,
                          videoId: String,
                          commentCount: Int,
                          likeCount: Int) {
        self.userId = userId
        self.danceId = danceId
        self.videoId = videoId
        self.commentCount = commentCount
        self.likeCount = likeCount
        
    }
    //MARK: - controller
    internal func getCurrentIndex() -> Int {
        return self.currentIndex
    }
    
    internal func getNextIndex() -> Int {
        if let section {
            if self.currentIndex < section.count - 1 {
                self.currentIndex += 1
                self.isSendData = false
            }
            return self.currentIndex
        } else {
            return 0
        }
    }
    
    internal func getBeforeIndex() -> Int {
        if self.currentIndex > 0{
            self.currentIndex -= 1
            self.isSendData = false
        }
        return self.currentIndex
    }
    
    internal func pauseVideo() {
        self.videoPlayState = .isPause
        self.videoView?.pauseVideo()
    }
    
    internal func playVideo() {
        self.videoPlayState = .isPlay
        self.videoView?.playVideo()
    }
    
    //MARK: - seekTime 판단
    /**
     비디오 뷰의 플레이 위치를 지정해 줍니다.
     */
    internal func setTimeToVideo(time: Float, completion: @escaping (Bool) -> Void) {
        guard let videoView = self.videoView else {return}
        let oneFrame = CMTime(seconds: Double(time), preferredTimescale: 600)
        let addTime = CMTimeAdd(CMTime(value: 0, timescale: 600), oneFrame)
        videoView.pauseVideo()
        videoView.player.seek(to: addTime, completionHandler: completion)
    }
    /**
     현재 플레이 시간 및, 총 듀레이션을 받아옵니다.
     해당 함수의 호출 부분은, videoPlayState가 isReadyToPlay일때 입니다.
     */
    internal func playVideoObserving() {
        guard let videoView = videoView else {return}
        videoView.timeObserver = videoView.player.addPeriodicTimeObserver(forInterval: CMTime.init(value: 1, timescale: 600), queue: .main, using: { [weak self] time in
            guard let self = self else {return}
            if let duration = videoView.player.currentItem?.duration {
                let duration = CMTimeGetSeconds(duration), time = CMTimeGetSeconds(time)
                self.delegate?.getCurrentPlayTime(time: Float(time), totalPlayTime: Float(duration))
                //start section 바뀔때마다 값 전달
                var index = 0
                guard let section else {return}
                section.forEach {
                    if Float(time) >= $0.start && Float(time) <= $0.end {
                        self.currentIndex = index
                    } else {
                        index += 1
                    }
                }
                
                if !self.isSendData {
                    if let data = self.videoViewData {
                        if self.currentIndex < data.video.count - 1 {
                            self.delegate?.getCurrentVideo(data: data.video[self.currentIndex])
                            self.isSendData = true
                        }
                    }
                }
                
                if time >= floor(duration) {
                    self.setTimeToVideo(time: 0) { _ in
                        self.playVideo()
                    }
                }
            }
        })
    }
    
    internal func removeVideoObserving() {
        guard let videoView = videoView else {return}
        if let timeObserver = videoView.timeObserver {
            videoView.player.removeTimeObserver(timeObserver)
            videoView.timeObserver = nil
        }
    }
    
    //MARK: - timer를 이용해서, 플레이 준비상태가 완료되었는지를 체킹
    var timer: Timer? = nil
    /**
     플레이어 레이어가 플레이 준비 상태인지를 체킹 합니다.
     */
    open func startObserbingLayer() {
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
        if let videoView = self.videoView {
            if videoView.isLayerReadyForDisplay() {
                self.stopTimer()
                videoView.setLoadingViewHidden()
                self.videoPlayState = .isReadyToPlay
                self.playVideoObserving()
                
                if self.videoShowStatus == .show {
                    self.videoView?.playVideo()
                }
            }
        }
    }
    
}
