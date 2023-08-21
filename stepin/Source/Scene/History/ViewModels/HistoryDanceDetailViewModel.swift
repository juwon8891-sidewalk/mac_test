import Foundation
import RxCocoa
import RxSwift
import FSCalendar
import RealmSwift
import AVFoundation

final class HistoryDanceDetailViewModel {
    var disposeBag = DisposeBag()
    var coordinator : HistoryDanceDetailCoordinator?
    var danceData: HistoryVideoDataModel?
    var videoHandler: VideoPlayHandler?
    
    //skeleton play
    var input: Input?
    var skeletonHelper: SkeletonHelper?
    var isSkeletonMode: Bool = false
    var isLikeState: Bool = false
    var oldLayer = CALayer()
    var timeObserver: AnyObject?
    
    init(coordinator: HistoryDanceDetailCoordinator, danceData: HistoryVideoDataModel) {
        self.coordinator = coordinator
        self.danceData = danceData
    }
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let videoView: BaseVideoView
        let playButton: UIButton
        let uploadButtonTapped: Observable<Void>
        let dismissButtonTapped: Observable<Void>
        let skeletonButton: UIButton
        let likeButtonTapped: Observable<Void>
    }
    
    struct Output {
        var selectedDateString = PublishRelay<Date>()
        var selectedTimeString = PublishRelay<Date>()
        var danceInfoDescription = PublishRelay<String>()
        var totalState = PublishRelay<String>()
        var totalScore = PublishRelay<Float>()
        var detailScoreArray = PublishRelay<[Float]>()
        var musicInfoData = PublishRelay<HistoryVideoDataModel>()
        var likeButtonState = PublishRelay<Bool>()
    }

    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        self.input = input
        
        self.videoHandler = VideoPlayHandler(videoView: input.videoView)
        self.videoHandler?.delegate = self
        
        DispatchQueue.main.async {
            input.videoView.layer.addSublayer(self.oldLayer)
        }
        
        skeletonHelper = SkeletonHelper(data: self.danceData!)
        input.viewWillAppear
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] in
                DispatchQueue.main.async {
                    input.videoView.loadingView.isHidden = true
                }
                let doucumentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let videoURL = doucumentDirectory.appendingPathComponent("\((self!.danceData?.video_url)!)")
                output.danceInfoDescription.accept("\(self!.danceData!.dance_name)-\(self!.danceData!.artist_name)")
                output.selectedDateString.accept(self!.danceData!.created_at)
                output.selectedTimeString.accept(self!.danceData!.created_at)
                
                if let data = self?.danceData {
                    output.musicInfoData.accept(data)
                    output.totalScore.accept(data.score)
                    output.totalState.accept(self?.getScoreState(score: self?.danceData?.score ?? 0.0) ?? "")
                    output.detailScoreArray.accept((self?.getScoreState(score: data.scoreData))!)
                    self?.isLikeState = data.isLiked
                    output.likeButtonState.accept(data.isLiked)
                }

                input.videoView.initVideo(videoPath: videoURL)
            })
            .disposed(by: disposeBag)
        
        input.dismissButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { (vm, _) in
                vm.videoHandler?.pauseVideo()
                vm.coordinator?.pop()
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
            })
            .disposed(by: disposeBag)
        
        
        input.uploadButtonTapped
            .subscribe(onNext: { [weak self] in
                input.videoView.pauseVideo()
                self!.coordinator?.pushToEditVideoView(data: self!.danceData!)
            })
            .disposed(by: disposeBag)
        
        input.skeletonButton.rx.tap.asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                input.skeletonButton.isSelected.toggle()
                self.isSkeletonMode.toggle()
                print(input.skeletonButton.isSelected)
            })
            .disposed(by: disposeBag)
        
        input.likeButtonTapped
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                vm.isLikeState.toggle()
                vm.updateVideoState(state: vm.isLikeState)
                output.likeButtonState.accept(vm.isLikeState)
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
    
    private func updateVideoState(state: Bool) {
        let realmRepo = RealmRepository()
        if let danceData = self.danceData {
            realmRepo.updateIsLikedState(id: danceData.id,
                                         state: state)
        }
    }
    
    
    private func getScoreState(score: Float) -> String {
        switch score {
        case 90.0 ... 100.0:
            return "history_view_score_text_perfect".localized()
        case 70.0 ... 90.0:
            return "history_view_score_text_great".localized()
        case 40.0 ... 70.0:
            return "history_view_score_text_good".localized()
        default:
            return "history_view_score_text_bad".localized()
        }
    }
    
    private func getScoreState(score: [Score]) -> [Float] {
        var perfectCount = 0
        var greatCount = 0
        var goodCount = 0
        var badCount = 0
        score.forEach { score in
            switch score.score {
            case 90.0 ... 100.0:
                perfectCount += 1
            case 70.0 ... 90.0:
                greatCount += 1
            case 40.0 ... 70.0:
                goodCount += 1
            case 1.0 ... 40.0:
                badCount += 1
            default:
                break
            }
        }
        let returnValue = [Float(perfectCount) / Float(score.count) * 100,
                           Float(greatCount) / Float(score.count) * 100,
                           Float(goodCount) / Float(score.count) * 100,
                           Float(badCount) / Float(score.count) * 100]
        return returnValue
    }
    
}
extension HistoryDanceDetailViewModel: VideoHandlerDelegate {
    func getCurrentVideo(data: Video) {}
    
    func getCurrentPlayTime(time: Float, totalPlayTime: Float) {
        guard let input = self.input else {return}
        if self.isSkeletonMode {
            self.oldLayer.isHidden = false
            if let layer = self.skeletonHelper?.drawSkeleton(view: input.videoView,
                                                             currentTime: Int(time * 1000)) {
                DispatchQueue.main.async {
                    input.videoView.layer.replaceSublayer(self.oldLayer, with: layer)
                    self.oldLayer = layer
                }
            }
        } else {
            self.oldLayer.isHidden = true
        }
        
        if time >= totalPlayTime {
            self.videoHandler?.pauseVideo()
            self.videoHandler?.setTimeToVideo(time: 0) { [weak self] _ in
                guard let strongSelf = self else {return}
                strongSelf.videoHandler?.playVideo()
            }
        }
    }
}
