import Foundation
import UIKit
import AVFoundation
import RxSwift

class MusicPlayer: NSObject {
    var player: AVPlayer?
    private var playerItemContext = 0
    weak var delegate: MusicPlayerProtocol?

    var playerTime = BehaviorSubject<Float64>(value: 0.0)
    var isPlaying: Bool = false
    //MARK: - Life Cycle
    init(musicPath: String,
         startTime: Float,
         endTime: Float) {
        super.init()
        //Music init
        guard let url = URL(string: musicPath) else {return}
        let item = AVPlayerItem(url: url)
        self.player = AVPlayer(playerItem: item)
        
        //add music observer
        self.player?.addObserver(self,
                                forKeyPath: #keyPath(AVPlayerItem.status),
                                options: [.old, .new],
                                context: &self.playerItemContext)
        //setStartTime
        self.setTimeToMusic(time: startTime)
    }
    
    deinit {
        self.player = nil
        print("deinit musicplayer")
    }
    
    internal func setTimeToMusic(time: Float) {
        let oneFrame = CMTime(seconds: Double(time), preferredTimescale: 600)
        let addTime = CMTimeAdd(CMTime(value: 0, timescale: 600), oneFrame)
        self.player?.seek(to: addTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    internal func setTimeToMusic(time: Float, completion: @escaping (Bool) -> Void) {
        let oneFrame = CMTime(seconds: Double(time), preferredTimescale: 600)
        let addTime = CMTimeAdd(CMTime(value: 0, timescale: 600), oneFrame)
        self.player?.pause()
        self.player?.seek(to: addTime, completionHandler: completion)
    }
    
    override open func observeValue(forKeyPath keyPath: String?,
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
                self.isMusicPlaying()
            case .failed:
                break
            case .unknown:
                break
            }
        }
        
    }
    
    private func isMusicPlaying() {
        player?.addPeriodicTimeObserver(forInterval: CMTime.init(value: 1, timescale: 3333333), queue: .main, using: { [weak self] time in
            guard let strongSelf = self else {return}
            if let duration = strongSelf.player?.currentItem?.duration {
                let duration = CMTimeGetSeconds(duration), time = CMTimeGetSeconds(time)
                strongSelf.delegate?.getCurrentMusicTime(CGFloat(time))
                strongSelf.playerTime.onNext(time)
            }
        })
    }
    
    
    func play() {
        self.isPlaying = true
        player?.play()
    }
    
    func pause() {
        self.isPlaying = false
        player?.pause()
    }
    
    func remove() {
        self.isPlaying = false
        player?.replaceCurrentItem(with: nil)
    }
}


