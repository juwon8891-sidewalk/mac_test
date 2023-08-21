import Foundation
import RxCocoa
import RxSwift
import FSCalendar
import RealmSwift
import AVKit

final class CreateDanceViewModel: NSObject {
    var coordinator : CreateDanceCoordinator?
    var videoRepository: VideoRepository?
    var authRepository = AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    var hashTagRepository = HashTagRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    var danceData: HistoryVideoDataModel?
    var hashTagStringData: [String] = []
    var hashTagIdData: [String] = []
    var content: String = ""
    var thumbnailImage = UIImage()
    var isScoreOpen: Bool = true
    var isAllowComment: Bool = true
    
    var isNeonMode: Bool = false
    var selectedTime: CMTime?
    
    var neonVideoName: String = ""
    
    var input: Input?
    
    var isLoadingEndRelay = PublishRelay<Void>()
    
    init(coordinator: CreateDanceCoordinator, danceData: HistoryVideoDataModel, videoRepository: VideoRepository) {
        self.coordinator = coordinator
        self.danceData = danceData
        self.videoRepository = videoRepository
    }
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let backButtonTapped: Observable<Void>
        let previewImageTapped: Observable<UITapGestureRecognizer>
        let textView: UITextView
        let textViewPlaceHolder: UILabel
        let hashTagView: HashTagView
        let alertViewOkButton: UIButton
        let displayScoreSwitchSelcted: UISwitch
        let allowCommentSwitchSelected: UISwitch
        let uploadButtonTapped: Observable<Void>
    }
    
    struct Output {
        var previewImage = PublishRelay<UIImage>()
        var didAlertViewHidden = PublishRelay<Bool>()
        var isLoadingStartFlag = PublishRelay<Void>()
        var isLoadingEndFlag = PublishRelay<Void>()
        var showToastMessage = PublishRelay<String>()
    }
    

    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        self.input = input
        let output = Output()
        
        input.viewWillAppear
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { (vm, _) in
                guard let danceData = vm.danceData else {return}
                let doucumentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                var videoURL: URL?
                if vm.isNeonMode {
                    videoURL = doucumentDirectory.appendingPathComponent(danceData.neonVideo_url)
                } else {
                    videoURL = doucumentDirectory.appendingPathComponent(danceData.video_url)
                }
                output.previewImage.accept(ABVideoHelper.thumbnailFromVideo(videoUrl: videoURL!,
                                                                            time: vm.selectedTime ?? .zero))
            })
            .disposed(by: disposeBag)
        
        input.previewImageTapped
            .when(.recognized)
            .asDriver{ _ in .never()}
            .drive(onNext: { [weak self] gesture in
                if self!.isNeonMode {
                    self?.coordinator?.pushToSelectThumbnailView(data: self!.danceData!,
                                                                 isNeonMode: self!.isNeonMode,
                                                                 neonVideoName: self?.neonVideoName ?? "")
                } else {
                    self?.coordinator?.pushToSelectThumbnailView(data: self!.danceData!,
                                                                 isNeonMode: self!.isNeonMode)
                }
            })
            .disposed(by: disposeBag)
        
        input.textView.rx.text.orEmpty.asObservable()
            .subscribe(onNext: { [weak self] text in
                self?.textViewDidEdit(input: input, textCount: text.count)
                self?.content = text
            })
            .disposed(by: disposeBag)
        
        input.backButtonTapped
            .subscribe(onNext: { [weak self] in
                output.didAlertViewHidden.accept(true)
            })
            .disposed(by: disposeBag)
        
        input.alertViewOkButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.popToDetailView()
            })
            .disposed(by: disposeBag)
        
        input.uploadButtonTapped
            .throttle(.seconds(100), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] in
                output.isLoadingStartFlag.accept(())
                self?.hashTagStringData = input.hashTagView.getHashTags()
                self?.getVideoStorageUrl(disposeBag: disposeBag)
            }, onError: { _ in
            })
            .disposed(by: disposeBag)
        
        input.displayScoreSwitchSelcted.rx.value.changed.asObservable()
            .subscribe(onNext: { [weak self] state in
                self?.isScoreOpen = state
            })
            .disposed(by: disposeBag)
        
        input.allowCommentSwitchSelected.rx.value.changed.asObservable()
            .subscribe(onNext: { [weak self] state in
                print(state)
                self?.isAllowComment = state
            })
            .disposed(by: disposeBag)
        
        self.isLoadingEndRelay
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                output.isLoadingEndFlag.accept(())
                output.showToastMessage.accept("history_upload_fail_title".localized())
            })
            .disposed(by: disposeBag)
        return output
    }
    
    private func textViewDidEdit(input: Input, textCount: Int) {
        if textCount > 0 {
            input.textViewPlaceHolder.isHidden = true
        } else {
            input.textViewPlaceHolder.isHidden = false
        }
    }
    
    private func postIsVideoUploadComplete() {
        NotificationCenter.default.post(name: NSNotification.Name("is_video_upload_complete"),
                                        object: nil,
                                        userInfo: nil)
    }
    
    private func getHashTagId(tag: String, disposeBag: DisposeBag) -> Observable<Void> {
        if tag.count > 0 {
            return self.authRepository.postRefreshToken()
                .flatMap { [weak self] _ in self!.hashTagRepository.getHashTagId(hashTag: tag) }
                .map { [weak self] result in
                    self?.hashTagIdData.append(result.data.hashtag.id)
                    return ()
                }
        } else {
            return Observable.just(())
        }
    }
    
    private func getVideoStorageUrl(disposeBag: DisposeBag) {
        //데이터베이스에 danceID추가 필요, gameType도 저장 필요 // 게임 이후 업데이트 // 우선은 7로 진행
        self.hashTagIdData = []
        self.authRepository.postRefreshToken()
            .observe(on: MainScheduler.asyncInstance)
            .flatMap { [weak self] _ in self!.getHashTagId(tag: self!.hashTagStringData[0], disposeBag: disposeBag) }
            .flatMap { [weak self] _ in self!.getHashTagId(tag: self!.hashTagStringData[1], disposeBag: disposeBag) }
            .flatMap { [weak self] _ in self!.getHashTagId(tag: self!.hashTagStringData[2], disposeBag: disposeBag) }
            .flatMap { [weak self] _ in (self!.videoRepository?.postVideo(danceId: self?.danceData?.dance_id ?? "",
                                                                          score: String(self?.danceData?.score ?? 0.0) ?? "",
                                                                          content: self!.content,
                                                                          hashTags: self!.hashTagIdData,
                                                                          allowComment: self!.isAllowComment,
                                                                          openScore: self!.isScoreOpen,
                                                                          gameType: "CHALLENGE",
                                                                          sessionId: self?.danceData?.sessionId ?? ""))! }
            .withUnretained(self)
            .subscribe(onNext: { (vm, result) in
                guard let danceData = vm.danceData else {return}
                let doucumentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                var videoURL: URL?
                if vm.isNeonMode {
                    videoURL = doucumentDirectory.appendingPathComponent(danceData.neonVideo_url)
                } else {
                    videoURL = doucumentDirectory.appendingPathComponent(danceData.video_url)
                }
                vm.thumbnailImage = ABVideoHelper.thumbnailFromVideo(videoUrl: videoURL!, time: vm.selectedTime ?? .zero)
                vm.uploadVideoThumbnail(result: result, disposeBag: disposeBag)
            }, onError: { _ in
                self.isLoadingEndRelay.accept(())
            })
            .disposed(by: disposeBag)
    }
    private func uploadVideoThumbnail(result: UploadVideoDataModel, disposeBag: DisposeBag) {
        guard let danceData = self.danceData else {return}
        let docFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        var outPutPath: String = ""
        if self.isNeonMode {
            outPutPath = docFolder.appending(danceData.neonVideo_url)
        } else {
            outPutPath = docFolder.appending(danceData.video_url)
        }
        
        self.authRepository.postRefreshToken()
            .observe(on: MainScheduler.asyncInstance)
            .flatMap { [weak self] _ in self!.patchUploadVideoFile(url: result.data.signedURL[0].signedURL,
                                                                   headerValue: result.data.signedURL[0].extensionHeadersValueArray,
                                                                   videoPath: outPutPath,
                                                                   disposeBag: disposeBag)
            }
            .flatMap { [weak self] _ in self!.patchUploadThumbnailFile(url: result.data.signedURL[1].signedURL,
                                                                       headerValue: result.data.signedURL[1].extensionHeadersValueArray,
                                                                       thumbnailImage: self!.thumbnailImage,
                                                                       disposeBag: disposeBag) }
            .subscribe(onNext: { [weak self] _ in
                DispatchQueue.main.async {
                    self!.coordinator?.popToHistoryView()
                    self!.postIsVideoUploadComplete()
                }
            }, onError: { _ in
                self.isLoadingEndRelay.accept(())
            })
            .disposed(by: disposeBag)
    }
    private func patchUploadVideoFile(url: String,
                                      headerValue: [String],
                                      videoPath: String,
                                      disposeBag: DisposeBag) -> Observable<Void>{
        return self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in (self!.videoRepository?.patchUploadVideoFile(url: url, headerValue: headerValue, videoPath: videoPath))! }
            .map { [weak self] result in
                    print(result)
                    return ()
            }
    }
    
    private func patchUploadThumbnailFile(url: String,
                                          headerValue: [String],
                                          thumbnailImage: UIImage,
                                          disposeBag: DisposeBag) -> Observable<Void> {
        return self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in (self!.videoRepository?.patchUploadVideoThumbnailFile(url: url, headerValue: headerValue, thumbnail: thumbnailImage))! }
            .map { [weak self] result in
                print(result)
                self?.deleteVideo()
                return ()
            }
    }
    
    private func deleteVideo() {
        guard let danceData else {return}
        do {
            let realm = try Realm()
            let fileManager: FileManager = FileManager.default
            let documentPath: URL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let video = realm.objects(VideoInfoTable.self).filter("id == %@", danceData.id).first
            
            if video?.neonvideo_url != "" {
                let neonDirectoryPath = documentPath.appendingPathComponent(video?.neonvideo_url ?? "")
                do {
                    try fileManager.removeItem(at: neonDirectoryPath)
                } catch let e {
                    print(e.localizedDescription)
                }
            }
            let videoDirectoryPath = documentPath.appendingPathComponent(video?.video_url ?? "")
            do {
                try fileManager.removeItem(at: videoDirectoryPath)
            } catch let e {
                print(e.localizedDescription)
            }
            
            try realm.write {
                if let video = video {
                    realm.delete(video)
                }
            }
        } catch {
            print("remove failed")
        }
    }
}
