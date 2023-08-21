import Foundation
import SDSKit
import RxCocoa
import RxSwift
import FSCalendar
import RealmSwift
import AVKit

final class EditVideoViewModel: NSObject {
    var disposeBag = DisposeBag()
    var coordinator : EditVideoCoordinator?
    var danceData: HistoryVideoDataModel?
    var videoHandler: VideoPlayHandler?
    var input: Input?
    var timeObserver: AnyObject?
    

    //videoRanger
    var isNeonMode: Bool = false
    var isNeonCreate: Bool = false
    
    var shouldUpdateProgressIndicator = false
    var isSeeking = false
    var currentDurationRelay = PublishRelay<Float>()
    var isUpdateComplete = PublishRelay<Void>()
    
    private var startTime: Float?
    private var currentTime: Float?
    private var endTime: Float?
    
    private var color: CIColor = .init(red: 1, green: 1, blue: 1, alpha: 1)
    
    //neonAi
    private var neonHandler: NeonManager?
    
    internal var videoName: String = ""
    
    init(coordinator: EditVideoCoordinator, danceData: HistoryVideoDataModel) {
        self.coordinator = coordinator
        self.danceData = danceData
    }
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let videoView: BaseVideoView
        let didViewButtonTapped: Observable<Void>
        let didNeonButtonTapped: Observable<Void>
        let continueButtonTapp: Observable<Void>
        let createButtonTapp: Observable<Void>
        let backButtonTapped: Observable<Void>
        let playButton: UIButton
        let rangeSlider: VideoRangeSlider
        let loadingView: NeonLoadingView
        let neonColorSelect: HistoryNeonColorSelectButton
    }
    
    struct Output {
        var didNeonButtonTapped = PublishRelay<Bool>()
        var didViewButtonTapped = PublishRelay<Bool>()
        var didNextButtonTapped = PublishRelay<Bool>()
        var didNeonCreate = PublishRelay<[Bool]>()
        var currentTime = PublishRelay<String>()
        var endTime = PublishRelay<String>()
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        self.input = input
        input.rangeSlider.delegate = self
        self.videoHandler = VideoPlayHandler(videoView: input.videoView)
        self.videoHandler?.delegate = self
        
        input.viewWillAppear
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { (vm, _) in
                DispatchQueue.main.async {
                    input.videoView.loadingView.isHidden = true
                }
                let doucumentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let videoURL = doucumentDirectory.appendingPathComponent("\((vm.danceData?.video_url)!)")
                input.videoView.initVideo(videoPath: videoURL)
                input.rangeSlider.setProgressIndicatorImage(image: ImageLiterals.icCurrentVideoLocate)
                output.currentTime.accept("00:00")
                if let endTime = vm.danceData?.end_time {
                    output.endTime.accept(vm.chnageTimeToString(endTime) ?? "00:00")
                }
                
                if let neonVideoURL = vm.danceData?.neonVideo_url {
                    if neonVideoURL == "" {
                        vm.isNeonCreate = false
                    } else {
                        vm.isNeonCreate = true
                    }
                }
                output.didNeonCreate.accept([vm.isNeonMode, vm.isNeonCreate])

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
        
        input.continueButtonTapp
            .withUnretained(self)
            .subscribe(onNext: { (vm, _) in
                //네온 생성 안됬을때는, 네온비디오를 생성함
                //아닐 경우에는 컨티뉴 버튼 자체가 사라짐
                if !self.isNeonCreate {
                    let doucumentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let videoURL = doucumentDirectory.appendingPathComponent("\((vm.danceData?.video_url)!)")
                    vm.initNeonModel(videoPath: videoURL,
                                     color: vm.color)
                    
                    DispatchQueue.main.async {
                        input.loadingView.isHidden = false
                    }
                    
                    output.didNextButtonTapped.accept(true)
                    vm.neonHandler?.didNeonCreateEnd = { [weak self] videoName in
                        //네온 비디오 생성 완 . . . .
                        let neonVideoName: String = videoName
                        let realmRepository = RealmRepository()
                        if let danceData = vm.danceData {
                            realmRepository.updateNeonVideoURL(id: danceData.id,
                                                               videoURL: neonVideoName)
                            vm.isNeonCreate = true
                            vm.updateVideoInfo()
                        }
                    }
                }
            }, onError: { _ in
            })
            .disposed(by: disposeBag)
        
        //최초 네온 생성 완료했을때
        self.isUpdateComplete
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                output.didNeonCreate.accept([vm.isNeonMode, vm.isNeonCreate])
                guard let danceData = vm.danceData else {return}
                vm.isNeonMode = true
                if vm.isNeonCreate {
                    vm.videoHandler?.pauseVideo()
                    let doucumentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let videoURL = doucumentDirectory.appendingPathComponent(danceData.neonVideo_url)
                    input.videoView.initVideo(videoPath: videoURL)
                    input.videoView.loadingView.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        
        input.createButtonTapp
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                guard let danceData = vm.danceData else {return}
                vm.coordinator?.pushToCreateDanceView(data: danceData,
                                                      isNeonMode: self.isNeonMode)
            })
            .disposed(by: disposeBag)
        
        input.loadingView.cancelButton.rx.tap.asObservable()
            .withUnretained(self)
            .subscribe(onNext: { (vm, _) in
                vm.neonHandler?.disposeNeonHandler()
                DispatchQueue.main.async {
                    input.loadingView.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        input.didNeonButtonTapped
            .withUnretained(self)
            .subscribe(onNext: {(vm, _) in
                if !vm.isNeonMode {
                    output.didNeonButtonTapped.accept(true)
                    output.didNeonCreate.accept([vm.isNeonMode, vm.isNeonCreate])
                    guard let danceData = vm.danceData else {return}
                    vm.isNeonMode = true
                    if vm.isNeonCreate {
                        vm.videoHandler?.pauseVideo()
                        let doucumentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let videoURL = doucumentDirectory.appendingPathComponent(danceData.neonVideo_url)
                        input.videoView.initVideo(videoPath: videoURL)
                        input.videoView.loadingView.isHidden = true
                    }
                }
            })
            .disposed(by: disposeBag)
        
        input.didViewButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { (vm, _) in
                if vm.isNeonMode {
                    output.didViewButtonTapped.accept(true)
                    output.didNeonCreate.accept([vm.isNeonMode, vm.isNeonCreate])
                    vm.isNeonMode = false
                    if vm.isNeonCreate {
                        vm.videoHandler?.pauseVideo()
                        let doucumentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let videoURL = doucumentDirectory.appendingPathComponent("\((vm.danceData?.video_url)!)")
                        input.videoView.initVideo(videoPath: videoURL)
                        input.videoView.loadingView.isHidden = true
                    }
                }
            })
            .disposed(by: disposeBag)
        
        input.backButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { (vm, _) in
                vm.videoHandler?.pauseVideo()
                vm.coordinator?.pop()
            })
            .disposed(by: disposeBag)
        
        input.neonColorSelect.selectedNeonColorCompletion = { [weak self] color in
            guard let strongSelf = self else {return}
            strongSelf.color = CIColor(color: color)
            strongSelf.neonHandler?.setNeonColor(strongSelf.color)
        }
        
        currentDurationRelay
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .bind(onNext: { (vm, time) in
                guard let danceData = vm.danceData else {return}
                let duration = danceData.end_time - danceData.start_time
                vm.currentTime = time
                input.rangeSlider.setDuration(duration: Float64(duration))
                input.rangeSlider.progressBackgroundView.backgroundColor = .PrimaryWhiteNormal
                input.rangeSlider.updateProgressIndicator(seconds: Float64(time))
                
                if let currentTimeString = vm.chnageTimeToString(time), let endTimeString = vm.chnageTimeToString(duration) {
                    output.currentTime.accept(currentTimeString)
                    output.endTime.accept(endTimeString)
                }
              
            })
            .disposed(by: disposeBag)
               
        return output
    }
    
    func updateVideoInfo() {
        let realmRepository = RealmRepository()
        guard let danceData else {return}
        let newData = realmRepository.getVideoItem(id: danceData.id)
        self.danceData = newData
        self.isUpdateComplete.accept(())
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
    
    private func initNeonModel(videoPath: URL, color: CIColor) {
        self.neonHandler = NeonManager(videoURL: videoPath,
                                       color: color,
                                       musicUrl: self.danceData?.music_url ?? "",
                                       startTime: self.danceData?.start_time ?? 0,
                                       endTime: self.danceData?.end_time ?? 0)
        self.neonHandler?.setNeonLoadingView(input!.loadingView)
        self.input?.loadingView.setEstimateTime(totalFrame: 200,
                                                currentFrame: 4,
                                                inferenceTime: 0.2)
    }
    
    @objc private func getNeonVideoUrl(_ sender: NSNotification) {
        guard let videoName = sender.object as? String else {return}
        self.videoName = videoName
    }
}
extension EditVideoViewModel: VideoRangeSliderDelegate {
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
        self.videoHandler?.playVideo()
        self.input?.playButton.isSelected = true
        self.input?.playButton.isHidden = true
        self.shouldUpdateProgressIndicator = true
    }
    
    func tapGesture(position: Float64) {
        self.videoHandler?.setTimeToVideo(time: Float(position)) { _ in
            self.videoHandler?.playVideo()
            self.input?.playButton.isSelected = true
            self.input?.playButton.isHidden = true
            self.shouldUpdateProgressIndicator = true
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
extension EditVideoViewModel: VideoHandlerDelegate {
    func getCurrentVideo(data: Video) {}
    
    func getCurrentPlayTime(time: Float, totalPlayTime: Float) {
        currentDurationRelay.accept(time)
    }
    
    
}
