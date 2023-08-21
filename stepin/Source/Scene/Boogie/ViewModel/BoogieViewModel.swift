import Foundation
import RxSwift
import RxRelay
import RxDataSources

enum BoogiePaginationType {
    case now
    case other
}

final class BoogieViewModel: NSObject {
    let tokenUtil = TokenUtils()
    var disposeBag = DisposeBag()
    var boogieCoordinator : BoogieCoordinator?
    var videoRepository: VideoRepository?
    var authRepository = AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    var userRepository = UserRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())


    var dataSource: RxCollectionViewSectionedReloadDataSource<BoogieVideoCollectionViewDataSection>?
    var pageNum: Int = 1
    var boogieResult: [BoogieVideoCollectionViewDataSection] = []
    var isNewReloadCell: Bool = true
    
    var paginationType: BoogiePaginationType = .now
    var danceId: String = ""
    var musicId: String = ""
    
    private var boogieResultRelay = PublishRelay<[BoogieVideoCollectionViewDataSection]>()
    private var loadingRelay = PublishRelay<Bool>()
    private var input: Input?
    
    init(coordinator: BoogieCoordinator, videoRepository: VideoRepository) {
        self.videoRepository = videoRepository
        self.boogieCoordinator = coordinator
    }
    
    internal func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        var output = Output()
        self.disposeBag = disposeBag
        self.input = input
        dataSource = RxCollectionViewSectionedReloadDataSource<BoogieVideoCollectionViewDataSection>(
            configureCell: {  [weak self] dataSource, collectionView, indexPath, item in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BoogieVideoCVC.identifier, for: indexPath) as? BoogieVideoCVC else {return UICollectionViewCell()}
                cell.setCellVideoData(videoPath: dataSource[indexPath.section].items[indexPath.row].videoURL ?? "",
                                      profilePath: dataSource[indexPath.section].items[indexPath.row].profileURL ?? "",
                                      userName: dataSource[indexPath.section].items[indexPath.row].identifierName,
                                      userId: dataSource[indexPath.section].items[indexPath.row].userID,
                                      hashTags: dataSource[indexPath.section].items[indexPath.row].hashtag,
                                      content: dataSource[indexPath.section].items[indexPath.row].content,
                                      likeCount: dataSource[indexPath.section].items[indexPath.row].likeCount,
                                      isLiked: dataSource[indexPath.section].items[indexPath.row].alreadyLiked,
                                      commentCount: dataSource[indexPath.section].items[indexPath.row].commentCount,
                                      isCommentEnabled: dataSource[indexPath.section].items[indexPath.row].allowComment,
                                      isOpenScore: dataSource[indexPath.section].items[indexPath.row].openScore,
                                      score: dataSource[indexPath.section].items[indexPath.row].score,
                                      coordinator: (self?.boogieCoordinator)!)
                //like
                cell.interactionStackView.likeButtonCompletion = { [weak self] state in
                    guard let strongSelf = self else {return}
                    if UserDefaults.standard.bool(forKey: UserDefaultKey.LoginStatus) {
                        var commentState = 0
                        if state {
                            strongSelf.boogieResult[indexPath.section].items[indexPath.row].likeCount -= 1
                            strongSelf.boogieResult[indexPath.section].items[indexPath.row].alreadyLiked = !strongSelf.boogieResult[indexPath.section].items[indexPath.row].alreadyLiked
                            cell.interactionStackView.bindData(commentCnt: strongSelf.boogieResult[indexPath.section].items[indexPath.row].commentCount,
                                                               isCommentEnabled: strongSelf.boogieResult[indexPath.section].items[indexPath.row].allowComment,
                                                               likeCnt: strongSelf.boogieResult[indexPath.section].items[indexPath.row].likeCount,
                                                               isLiked: strongSelf.boogieResult[indexPath.section].items[indexPath.row].alreadyLiked)
                            commentState = -1
                        } else {
                            strongSelf.boogieResult[indexPath.section].items[indexPath.row].likeCount += 1
                            strongSelf.boogieResult[indexPath.section].items[indexPath.row].alreadyLiked = !strongSelf.boogieResult[indexPath.section].items[indexPath.row].alreadyLiked
                            cell.interactionStackView.bindData(commentCnt: strongSelf.boogieResult[indexPath.section].items[indexPath.row].commentCount,
                                                               isCommentEnabled: strongSelf.boogieResult[indexPath.section].items[indexPath.row].allowComment,
                                                               likeCnt: strongSelf.boogieResult[indexPath.section].items[indexPath.row].likeCount,
                                                               isLiked: strongSelf.boogieResult[indexPath.section].items[indexPath.row].alreadyLiked)
                            commentState = 1
                        }
                        self?.likeComment(videoId: dataSource[indexPath.section].items[indexPath.row].videoID,
                                          state: commentState,
                                          disposeBag: disposeBag)
                    } else {
                        self?.boogieCoordinator?.pushToLogin()
                    }
                   
                }
                //comment
                cell.interactionStackView.commentCompletion = { [weak self] in
                    guard let strongSelf = self else {return}
                    if UserDefaults.standard.bool(forKey: UserDefaultKey.LoginStatus) {
                        strongSelf.boogieCoordinator?.presentToComment(videoId: dataSource[indexPath.section].items[indexPath.row].videoID)
                    } else {
                        strongSelf.boogieCoordinator?.pushToLogin()
                    }
                }
                
                //more
                cell.interactionStackView.moreButtonCompletion = { [weak self] in
                    guard let strongSelf = self else {return}
                    strongSelf.loadingRelay.accept(true)
                    if UserDefaults.standard.bool(forKey: UserDefaultKey.LoginStatus) {
                        //내 프로필일때
                        if UserDefaults.standard.string(forKey: UserDefaultKey.userId) == strongSelf.boogieResult[indexPath.section].items[indexPath.row].userID {
                            strongSelf.didCheckUserBlock(userId: strongSelf.boogieResult[indexPath.section].items[indexPath.row].userID,
                                                    videoId: strongSelf.boogieResult[indexPath.section].items[indexPath.row].videoID,
                                                    type: .myVideo)
                        } else { //아닐때
                            strongSelf.didCheckUserBlock(userId: strongSelf.boogieResult[indexPath.section].items[indexPath.row].userID,
                                                    videoId: strongSelf.boogieResult[indexPath.section].items[indexPath.row].videoID,
                                                    type: .otherVideo)
                        }
                    } else {
                        strongSelf.boogieCoordinator?.pushToLogin()
                    }
                }
                
                return cell
            })
        
        
        //play video
        input.collectionView.rx.didEndDecelerating.asObservable()
            .subscribe(onNext: { [weak self] in
                let indexPath = self!.getCurrentCellIndex(input: input)
                self?.changeBoogieTag(musicId: self!.boogieResult[indexPath.section].items[indexPath.row].danceID,
                                      musicName: self!.boogieResult[indexPath.section].items[indexPath.row].title)
                if let cell = input.collectionView.cellForItem(at: indexPath) as? BoogieVideoCVC {
                    cell.playVideo()
                }
            })
            .disposed(by: disposeBag)
        
        input.collectionView.rx.didEndDragging.asObservable()
        //셀 확실하게 정지 후 시작
            .subscribe(onNext: { [weak self] _ in
                input.collectionView.visibleCells.forEach { cell in
                    let visiableCell = cell as! BoogieVideoCVC
                    visiableCell.stopVideo()
                }
            })
            .disposed(by: disposeBag)
        
        //비디오 데이터 disposed
        input.viewWillDisappear
            .subscribe(onNext: { [weak self] in
                input.collectionView.visibleCells.forEach { cell in
                    let visiableCell = cell as! BoogieVideoCVC
                    visiableCell.stopVideo()
                }
            })
            .disposed(by: disposeBag)
        
        //pagination
        input.collectionView.rx.contentOffset.asObservable()
            .throttle(.seconds(3), scheduler: MainScheduler.asyncInstance)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] offset in
                if offset.y > input.collectionView.contentSize.height - input.collectionView.frame.height {
                    if self!.paginationType == .now {
                        self?.getNowVideoData(input: input,
                                              disposeBag: disposeBag)
                    } else {
                        self?.getBoogieDancesData(input: input,
                                                  disposeBag: disposeBag,
                                                  musicId: self!.musicId)
                    }
                }
            })
        
        
        input.viewDidAppeared
            .subscribe(onNext: { [weak self] in
                self?.getNowVideoData(input: input, disposeBag: disposeBag)
            })
            .disposed(by: disposeBag)
        
        boogieResultRelay
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: input.collectionView.rx.items(dataSource: self.dataSource!))
            .disposed(by: disposeBag)
        
        
        input.collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        loadingRelay
            .withUnretained(self)
            .bind(onNext: { (vm, state) in
                if state {
                    output.isLoadingStart.accept(())
                } else {
                    output.isLoadingEnd.accept(())
                }
            })
            .disposed(by: disposeBag)
        
        //상단 셀 선택시
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(otherBoogieCategoryTapped(_:)),
            name: NSNotification.Name("selected_boogie_data"),
            object: nil
        )
        
        //하단 노래 선택시
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(otherBoogieMusicCategoryTapped(_:)),
            name: NSNotification.Name("boogie_data_bottom_musicID"),
            object: nil
        )
        
        return output
    }
    
    struct Input {
        let viewDidAppeared: Observable<Void>
        let viewWillDisappear: Observable<Void>
        let collectionView: UICollectionView
    }
    struct Output {
        var isLoadingStart = PublishRelay<Void>()
        var isLoadingEnd = PublishRelay<Void>()
    }
    
    private func changeBoogieTag(musicId: String,
                                 musicName: String) {
        if self.paginationType == .now {
            NotificationCenter.default.post(name: NSNotification.Name("child_boogie_tag"),
                                            object: [ChildBoogieTag(musicID: "",
                                                                    music: musicName)],
                                            userInfo: nil)
        }
    }
    
    
    //하단 셀 선택시 실행
    @objc private func otherBoogieMusicCategoryTapped(_ sender: NSNotification) {
        self.input!.collectionView.visibleCells.forEach { cell in
            let visiableCell = cell as! BoogieVideoCVC
            visiableCell.removeVideo()
        }
        self.pageNum = 1
        self.boogieResult = []
        let musicId = sender.object as! String
        self.musicId = musicId
        self.paginationType = .other
        self.getBoogieDancesData(input: input!,
                                 disposeBag: disposeBag,
                                 musicId: musicId)
    }
    
    //상단 셀 선택시 실행
    @objc private func otherBoogieCategoryTapped(_ sender: NSNotification) {
        self.input!.collectionView.visibleCells.forEach { cell in
            let visiableCell = cell as! BoogieVideoCVC
            visiableCell.removeVideo()
        }
        self.pageNum = 1
        self.boogieResult = []

        let boogieData = sender.object as! BoogieTag
        //맨 처음 뮤직 아이디
        if boogieData.artist != "Now" {
            self.paginationType = .other
            self.musicId = boogieData.childBoogieTag[0].musicID
            self.getBoogieDancesData(input: input!,
                                     disposeBag: self.disposeBag,
                                     musicId: self.musicId)
        } else {
            self.paginationType = .now
            self.getNowVideoData(input: input!,
                                 disposeBag: disposeBag)
        }
    }
    
    
    private func getCurrentCellIndex(input: Input) -> IndexPath {
        var visiableRect = CGRect()
        visiableRect.origin = input.collectionView.contentOffset
        visiableRect.size = input.collectionView.bounds.size
        let visibleRect = CGPoint(x: visiableRect.midX, y: visiableRect.midY)
        guard let currentCellIndexPath = input.collectionView.indexPathForItem(at: visibleRect) else { return IndexPath(row: 0, section: 0)}

        return currentCellIndexPath
    }
    
    //now는 포지션 자체가 다름
    //now를 제외한 다른 비디오들은 해당 function으로 조회
    //artist
    
    private func getBoogieDancesData(input: Input, disposeBag: DisposeBag, musicId: String) {
        self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in (self!.videoRepository?.getBoogieTypeVideo(type: GetTypeVideoType.music,
                                                                                   targetId: musicId,
                                                                                   page: self!.pageNum))! }
            .subscribe(onNext: { [weak self] result in
                if !result.items.isEmpty {
                    self?.pageNum += 1
                }
                if !self!.boogieResult.isEmpty {
                    self!.boogieResult[0].items.append(contentsOf: result.items)
                } else {
                    self!.boogieResult.append(contentsOf: [result])
                }
                self!.boogieResultRelay.accept(self!.boogieResult)
                DispatchQueue.main.async {
                    if self?.pageNum == 1 {
                        input.collectionView.setContentOffset(.init(x: 0, y: 0), animated: false)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func getNowVideoData(input: Input, disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in (self!.videoRepository?.getNowVideo(page: self!.pageNum))! }
            .subscribe(onNext: { [weak self] result in
                print(result)
                if !result.items.isEmpty {
                    self?.pageNum += 1
                }
                if !self!.boogieResult.isEmpty {
                    self!.boogieResult[0].items.append(contentsOf: result.items)
                } else {
                    self!.boogieResult.append(contentsOf: [result])
                }
                self!.boogieResultRelay.accept(self!.boogieResult)
                DispatchQueue.main.async {
                    if self?.pageNum == 1 {
                        input.collectionView.setContentOffset(.init(x: 0, y: 0), animated: false)
                    }
                    let indexPath = self!.getCurrentCellIndex(input: input)
                    self?.changeBoogieTag(musicId: self!.boogieResult[indexPath.section].items[indexPath.row].danceID,
                                          musicName: self!.boogieResult[indexPath.section].items[indexPath.row].title)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func likeComment(videoId: String, state: Int, disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .flatMap{ [weak self] _ in (self?.videoRepository?.patchLikeVideo(videoId: videoId, state: state))! }
            .subscribe(onNext: { [weak self] result in
                print(result)
            })
            .disposed(by: disposeBag)
    }
    
    private func didCheckUserBlock(userId: String,
                                   videoId: String,
                                   type: BottomSheetType) {
        let userProfileObservable = self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap { (viewModel, _) in
                viewModel.userRepository.getUserProfile(type: "id", data: userId)
            }
            .withUnretained(self)

        let boostIsPossibleObservable = userProfileObservable
            .flatMap { (viewModel, _) in
                viewModel.userRepository.getBoostIsPossible()
            }
            .withUnretained(self)
        
        Observable.zip(userProfileObservable, boostIsPossibleObservable)
            .subscribe(onNext: { (arg0, arg1) in
                let (vm, userProfile) = arg0
                let (_, isBoostPossible) = arg1
            
                DispatchQueue.main.async {
                    vm.boogieCoordinator?.presentBottomSheet(userId: userId,
                                                             videoId: videoId,
                                                             isFollowed: userProfile.data.isFollowed,
                                                             isBlocked: userProfile.data.isBlocked,
                                                             isBoosted: isBoostPossible.data.possible,
                                                             type: type)
                    vm.loadingRelay.accept(false)
                }
            })
            .disposed(by: disposeBag)
        
    }

}

extension BoogieViewModel: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? BoogieVideoCVC {
            cell.stopVideo()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if let cell = cell as? BoogieVideoCVC {
                cell.playVideo()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? BoogieVideoCVC {
            print(cell.isSelected)
            if cell.isPlaying {
                cell.stopVideo()
            } else {
                cell.playVideo()
            }
        }
    }
    
}
