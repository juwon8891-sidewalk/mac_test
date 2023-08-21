import Foundation
import RxCocoa
import RxSwift
import FSCalendar
import RealmSwift
import AVKit

final class ModifyVideoViewModel: NSObject {
    var coordinator : ModifyVideoViewCoordinator?
    var videoRepository: VideoRepository?
    var authRepository = AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    var hashTagRepository = HashTagRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    
    var videoId: String = ""
    var videoURL: String = ""
    
    var hashTagStringData: [String] = []
    var hashTagIdData: [String] = []
    var content: String = ""
    var thumbnailImage = UIImage()
    var isScoreOpen: Bool = false
    var isAllowComment: Bool = false
    
    var isNeonMode: Bool = false
    var selectedTime: CMTime?
    
    var neonVideoName: String = ""
    
    var input: Input?

    var isChangeContent: Bool = false
    var isChangeHashtag: Bool = false
    var isChangeAllowComment: Bool = false
    var isChangeDisplayScore: Bool = false
    var isVideoContentChanged = PublishRelay<Void>()
    
    var videoData: [Video] = []
    var videoDataRelay = PublishRelay<[Video]>()
    
    init(coordinator: ModifyVideoViewCoordinator,
         videoId: String,
         videoURL: String,
         videoRepository: VideoRepository) {
        self.coordinator = coordinator
        self.videoId = videoId
        self.videoURL = videoURL
        self.videoRepository = videoRepository
    }
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let backButtonTapped: Observable<Void>
        let previewImageTapped: Observable<UITapGestureRecognizer>
        let textView: UITextView
        let textViewPlaceHolder: UILabel
        let hashTagView: HashTagView
        let displayScoreSwitchSelcted: UISwitch
        let allowCommentSwitchSelected: UISwitch
        let uploadButtonTapped: Observable<Void>
    }
    
    struct Output {
        var previewImage = PublishRelay<String>()
        var didAlertViewHidden = PublishRelay<Bool>()
        var isLoadingStartFlag = PublishRelay<Void>()
        var isLoadingEndFlag = PublishRelay<Void>()
        
        var contentString = PublishRelay<String>()
        var hashTags = PublishRelay<[Hashtag]>()
        var isAllowComment = PublishRelay<Bool>()
        var isDisplayScore = PublishRelay<Bool>()
        
        var didChangeComplete = PublishRelay<Bool>()
    }
    

    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        self.input = input
        let output = Output()
        
        input.viewWillAppear
            .subscribe(onNext: { [weak self] in
                self?.getVideoInfo(disposeBag: disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.previewImageTapped
            .when(.recognized)
            .asDriver{ _ in .never()}
            .drive(onNext: { [weak self] gesture in
                print("preview view tapped")
            })
            .disposed(by: disposeBag)
        
        input.textView.rx.text.orEmpty.asObservable()
            .subscribe(onNext: { [weak self] text in
                self?.textViewDidEdit(input: input, textCount: text.count)
                self?.content = text
                self?.didChangeContent()
            })
            .disposed(by: disposeBag)
        
        input.hashTagView.firstHashTagInputView.rx.text.orEmpty.asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.didChangeHashtag()
            })
            .disposed(by: disposeBag)
        
        input.hashTagView.secondHashTagInputView.rx.text.orEmpty.asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.didChangeHashtag()
            })
            .disposed(by: disposeBag)
        
        input.hashTagView.thirdHashTagInputView.rx.text.orEmpty.asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.didChangeHashtag()
            })
            .disposed(by: disposeBag)
        
        input.backButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.pop()
            })
            .disposed(by: disposeBag)
        
        
        input.uploadButtonTapped
            .withUnretained(self)
            .throttle(.seconds(100), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { _ in
                if self.isChangeContent || self.isChangeHashtag || self.isChangeDisplayScore || self.isChangeAllowComment {
                    self.hashTagStringData = input.hashTagView.getHashTags()
                    self.patchModifyVideoData(disposeBag: disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        input.displayScoreSwitchSelcted.rx.value.changed.asObservable()
            .withUnretained(self)
            .subscribe(onNext: {(_, state) in
                self.isScoreOpen = state
                self.isChangeDisplayScore.toggle()
                self.isVideoContentChanged.accept(())
            })
            .disposed(by: disposeBag)
        
        input.allowCommentSwitchSelected.rx.value.changed.asObservable()
            .withUnretained(self)
            .subscribe(onNext: { (_, state) in
                self.isAllowComment = state
                self.isChangeAllowComment.toggle()
                self.isVideoContentChanged.accept(())
            })
            .disposed(by: disposeBag)
        
        self.videoDataRelay
            .bind(onNext: { [weak self] data in
                guard let self = self else {return}
                self.videoData = data
                output.contentString.accept(data[0].content)
                output.hashTags.accept(data[0].hashtag)
                output.isAllowComment.accept(data[0].allowComment)
                output.isDisplayScore.accept(data[0].openScore)
                output.previewImage.accept(self.videoData[0].thumbnailURL ?? "")
            })
            .disposed(by: disposeBag)
        
        isVideoContentChanged
            .withUnretained(self)
            .subscribe(onNext: { _ in
                if self.isChangeHashtag || self.isChangeContent || self.isChangeAllowComment || self.isChangeDisplayScore {
                    output.didChangeComplete.accept(true)
                } else {
                    output.didChangeComplete.accept(false)
                }
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
    
    private func didChangeContent() {
        if self.videoData.count > 0 {
            if self.content != self.videoData[0].content { //변경이 발생했을때
                self.isChangeContent = true
            } else {
                self.isChangeContent = false
            }
        }
        isVideoContentChanged.accept(())
        print(self.isChangeContent)
    }
    private func didChangeHashtag() {
        var hashTags = input!.hashTagView.getHashTags().map{ $0.replacingOccurrences(of: "#", with: "")}
        var originalHashTags: [String] = []
        if self.videoData.count > 0 {
            for i in 0 ... 2 {
                if !self.videoData[0].hashtag.indices.contains(i) {
                    originalHashTags.append("")
                } else {
                    originalHashTags.append(self.videoData[0].hashtag[i].keyword)
                }
            }
            var index: Int = 0
            for tag in originalHashTags {
                if tag != hashTags[index] {
                    self.isChangeHashtag = true
                    break
                } else {
                    self.isChangeHashtag = false
                }
                index += 1
            }
            print(originalHashTags, hashTags)
        }
        isVideoContentChanged.accept(())
        print(self.isChangeHashtag)
    }
    
    private func postIsVideoUploadComplete() {
        NotificationCenter.default.post(name: NSNotification.Name("is_video_upload_complete"),
                                        object: nil,
                                        userInfo: nil)
    }
    
    private func getVideoInfo(disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .flatMap { _ in (self.videoRepository?.getVideoInfo(videoId: self.videoId))!}
            .withUnretained(self)
            .subscribe(onNext: { (_, result) in
                self.videoDataRelay.accept(result.items)
            })
            .disposed(by: disposeBag)
    }
    
    private func getHashTagId(tag: String, disposeBag: DisposeBag) -> Observable<Void> {
        if tag.matchString(_string: tag).count > 0 {
            return self.authRepository.postRefreshToken()
                .flatMap { [weak self] _ in self!.hashTagRepository.getHashTagId(hashTag: tag.matchString(_string: tag)) }
                .map { [weak self] result in
                    self?.hashTagIdData.append(result.data.hashtag.id)
                    return ()
                }
        } else {
            return Observable.just(())
        }
    }
    
    private func uploadVideoThumbnail(result: UploadVideoDataModel, disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .observe(on: MainScheduler.asyncInstance)
            .flatMap { [weak self] _ in self!.patchUploadThumbnailFile(url: result.data.signedURL[1].signedURL,
                                                                       headerValue: result.data.signedURL[1].extensionHeadersValueArray,
                                                                       thumbnailImage: self!.thumbnailImage,
                                                                       disposeBag: disposeBag) }
            .subscribe(onNext: { [weak self] _ in
                DispatchQueue.main.async {
                    self!.coordinator?.pop()
                    self!.postIsVideoUploadComplete()
                }
            })
            .disposed(by: disposeBag)
    }

    private func patchUploadThumbnailFile(url: String,
                                          headerValue: [String],
                                          thumbnailImage: UIImage,
                                          disposeBag: DisposeBag) -> Observable<Void> {
        return self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in (self!.videoRepository?.patchUploadVideoThumbnailFile(url: url, headerValue: headerValue, thumbnail: thumbnailImage))! }
            .map { [weak self] result in
                print(result)
                return ()
            }
    }
    
    private func patchModifyVideoData(disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in self!.getHashTagId(tag: self!.hashTagStringData[0], disposeBag: disposeBag) }
            .flatMap { [weak self] _ in self!.getHashTagId(tag: self!.hashTagStringData[1], disposeBag: disposeBag) }
            .flatMap { [weak self] _ in self!.getHashTagId(tag: self!.hashTagStringData[2], disposeBag: disposeBag) }
            .withUnretained(self)
            .flatMap { [weak self] _ in ((self?.videoRepository?.patchModifyVideo(videoId: self!.videoId,
                                                                                  content: self!.content,
                                                                                  hashTag: self!.hashTagIdData,
                                                                                  allowComment: self!.isAllowComment,
                                                                                  openScore: self!.isScoreOpen))!)
            }
            .withUnretained(self)
            .subscribe(onNext: { (_, result) in
                DispatchQueue.main.async {
                    self.coordinator?.pop()
                }
                print(result)
            },
            onError: { _ in
                DispatchQueue.main.async {
                    self.coordinator?.pop()
                }
            })
            .disposed(by: disposeBag)
    }
}
