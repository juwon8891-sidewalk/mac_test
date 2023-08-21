import Foundation
import RxCocoa
import RxSwift
import FSCalendar
import RealmSwift
import AVKit

final class ThumbnailViewModel: NSObject {
    var disposeBag = DisposeBag()
    var coordinator : ThumbnailViewCoordinator?
    var danceData: HistoryVideoDataModel?
    var videoHandler: VideoPlayHandler?
    var input: Input?
    var selectedTime: CMTime?

    //videoRanger
    var isNeonMode: Bool = false
    var shouldUpdateProgressIndicator = true
    var currentDurationRelay = PublishRelay<Float>()
    var isSeeking = false

    private var startTime: Float?
    private var currentTime: Float?
    private var endTime: Float?
    
    var videoName: String = ""
    
    init(coordinator: ThumbnailViewCoordinator, danceData: HistoryVideoDataModel) {
        self.coordinator = coordinator
        self.danceData = danceData
    }
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let videoView: BaseVideoView
        let applyButtonTapped: Observable<Void>
        let backButtonTapped: Observable<Void>
        let playButton: UIButton
        let rangeSlider: VideoRangeSlider
    }
    
    struct Output {
        var currentTimeString = PublishRelay<String>()
        var endTimeString = PublishRelay<String>()
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        self.input = input
        input.rangeSlider.delegate = self
        self.videoHandler = VideoPlayHandler(videoView: input.videoView)
        self.videoHandler?.delegate = self
        
        input.viewWillAppear
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { (vm, _) in
                guard let danceData = vm.danceData else {return}
                let doucumentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                var videoURL: URL?
                if vm.isNeonMode {
                    videoURL = doucumentDirectory.appendingPathComponent(danceData.neonVideo_url)
                } else {
                    videoURL = doucumentDirectory.appendingPathComponent(danceData.video_url)
                }
                
                if let url = videoURL {
                    input.videoView.initVideo(videoPath: url)
                }
                input.rangeSlider.progressBackgroundView.backgroundColor = .clear
                input.rangeSlider.setVideoURL(videoURL: videoURL!)
            })
            .disposed(by: disposeBag)
        
        input.playButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] in
                if input.playButton.isSelected {
                    input.videoView.pauseVideo()
                    input.playButton.isHidden = false
                } else {
                    input.videoView.playVideo()
                    input.playButton.isHidden = true
                }
                input.playButton.isSelected = !input.playButton.isSelected
                self!.shouldUpdateProgressIndicator = true
            })
            .disposed(by: disposeBag)
        
        input.videoView.rx.tapGesture().asObservable()
            .when(.recognized)
            .asDriver{ _ in .never()}
            .drive(onNext: { [weak self] gesture in
                if input.playButton.isSelected {
                    input.videoView.pauseVideo()
                    input.playButton.isHidden = false
                } else {
                    input.videoView.playVideo()
                    input.playButton.isHidden = true
                }
                input.playButton.isSelected = !input.playButton.isSelected
                self!.shouldUpdateProgressIndicator = true
            })
            .disposed(by: disposeBag)
        
        input.applyButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { (vm, _) in
                vm.coordinator?.popToData(selectedTime: .init(value: CMTimeValue(vm.currentTime ?? 0),
                                                              timescale: 1) )
            })
            .disposed(by: disposeBag)
      
        input.backButtonTapped
            .subscribe(onNext: { [weak self] in
                self!.coordinator?.pop()
            })
            .disposed(by: disposeBag)
        
        currentDurationRelay
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .bind(onNext: { (vm, time) in
                guard let danceData = vm.danceData else {return}
                let duration = danceData.end_time - danceData.start_time
                vm.currentTime = time
                input.rangeSlider.setDuration(duration: Float64(duration))
                input.rangeSlider.updateProgressIndicator(seconds: Float64(time))
                
                if let currentTimeString = vm.chnageTimeToString(time), let endTimeString = vm.chnageTimeToString(duration) {
                    output.currentTimeString.accept(currentTimeString)
                    output.endTimeString.accept(endTimeString)
                }
              
            })
            .disposed(by: disposeBag)
                
        return output
    }
    
    func chnageTimeToString(_ time: Float) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad

        // 숫자를 "0:00" 형태로 변환합니다.
        if let formattedString = formatter.string(from: TimeInterval(time)) {
            return formattedString
        } else {
            return nil
            print("Error formatting the time.")
        }
    }
    
}
extension ThumbnailViewModel: VideoRangeSliderDelegate {
    func didChangeValue(videoRangeSlider: VideoRangeSlider, startTime: Float64, endTime: Float64) {
        if self.isSeeking {
            if let startTime = self.danceData?.start_time, let currentTime = self.currentTime {
                videoHandler?.setTimeToVideo(time: startTime + Float(currentTime)) { [weak self] _ in
                }
            }
        }
    }
    
    func indicatorDidChangePosition(videoRangeSlider: VideoRangeSlider, position: Float64) {
        if self.isSeeking {
            if let startTime = self.danceData?.start_time {
                videoHandler?.setTimeToVideo(time: Float(position)) { [weak self] _ in
                }
            }
        }
    }
    
    func sliderGesturesBegan() {
        self.isSeeking = true
        self.videoHandler?.pauseVideo()
        self.input?.playButton.isHidden = false
        self.input?.playButton.isSelected = false
        self.shouldUpdateProgressIndicator = true
    }
    
    func sliderGesturesEnded() {
        self.isSeeking = false
    }
    
    func tapGesture(position: Float64) {
        self.videoHandler?.setTimeToVideo(time: Float(position)) { _ in
        }
    }
    
    func resetPosition() {
        self.videoHandler?.setTimeToVideo(time: 0) { _ in
            self.videoHandler?.playVideo()
            self.input?.playButton.isSelected = true
            self.input?.playButton.isHidden = true
            self.shouldUpdateProgressIndicator = true
        }
    }
    
}
extension ThumbnailViewModel: VideoHandlerDelegate {
    func getCurrentVideo(data: Video) {}
    
    func getCurrentPlayTime(time: Float, totalPlayTime: Float) {
        currentDurationRelay.accept(time)
    }
}
