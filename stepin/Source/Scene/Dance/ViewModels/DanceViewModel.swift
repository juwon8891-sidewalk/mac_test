import Foundation
import RxSwift
import RxRelay
import RxDataSources
import AVFoundation

final class DanceViewModel: NSObject {
    let tokenUtil = TokenUtils()
    var danceCoordinator : DanceViewCoordinator?
    var danceRepository: DanceRepository?
    var userRepository = UserRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    var videoRepository = VideoRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    var authRepository = AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())

    var rankDataSource: RxTableViewSectionedReloadDataSource<RankingTableviewDataSection>?
    var rankPageNum: Int = 1
    var rankResult: [RankingTableviewDataSection] = []
    var rankHeaderData: [DanceRankList] = []
    var hotDanceDataSource: RxCollectionViewSectionedReloadDataSource<HotCollectionViewDataSection>?
    var hotDancePageNum: Int = 1
    var hotDanceResult: [HotCollectionViewDataSection] = []
    
    var playDanceData: PlayDance?
    private var isChallengeMode: Bool = true
    
    var danceId: String = ""
    
    private var rankResultRelay = PublishRelay<[RankingTableviewDataSection]>()
    private var hotResultRelay = PublishRelay<[HotCollectionViewDataSection]>()
    
    private var startLottieRelay = PublishRelay<Void>()
    private var removeLottieRelay = PublishRelay<Void>()
    
    private var isEnergyEnoughRelay = PublishRelay<Bool>()
    private var input: Input?
    
    private var isInitialized: Bool = false
    private var musicPlayerItem: AVPlayerItem?

    
    init(coordinator: DanceViewCoordinator, danceRepository: DanceRepository) {
        self.danceRepository = danceRepository
        self.danceCoordinator = coordinator
    }
    
    internal func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        var output = Output()
        self.input = input
        rankDataSource = RxTableViewSectionedReloadDataSource<RankingTableviewDataSection>(
            configureCell: {  [weak self] dataSource, tableview, indexPath, item in
                guard let cell = tableview.dequeueReusableCell(withIdentifier: RankingTVC.identifier, for: indexPath) as? RankingTVC else { return UITableViewCell() }
                
                if self!.rankHeaderData.count == 3 { //헤더데이터가 있을때
                    cell.setData(profilePath: dataSource[indexPath.section].items[indexPath.row].profileURL ?? "",
                                 userName: dataSource[indexPath.section].items[indexPath.row].identifierName,
                                 score: dataSource[indexPath.section].items[indexPath.row].score,
                                 ranking: indexPath.row + 4,
                                 isBlocked: dataSource[indexPath.section].items[indexPath.row].isBlock)
                } else {
                    cell.setData(profilePath: dataSource[indexPath.section].items[indexPath.row].profileURL ?? "",
                                 userName: dataSource[indexPath.section].items[indexPath.row].identifierName,
                                 score: dataSource[indexPath.section].items[indexPath.row].score,
                                 ranking: indexPath.row + 1,
                                 isBlocked: dataSource[indexPath.section].items[indexPath.row].isBlock)
                }
                
                return cell
            })
        
        hotDanceDataSource = RxCollectionViewSectionedReloadDataSource<HotCollectionViewDataSection>(
            configureCell: {  [weak self] dataSource, collectionView, indexPath, item in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HotVideoCVC.identifier, for: indexPath) as? HotVideoCVC else {return UICollectionViewCell()}
                cell.setData(thumbnailPath: dataSource[indexPath.section].items[indexPath.row].thumbnailURL ?? "",
                             viewCount: 0)
                return cell
            })
        
        input.tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
                
        input.viewDidAppeared
            .subscribe(onNext: { [weak self] in
                if !(self?.isInitialized ?? false) {
                    self?.isInitialized = true
                    self?.hotDancePageNum = 1
                    self?.hotDanceResult = []
                    self?.rankPageNum = 1
                    self?.rankDataSource = nil
                    self?.getRankedDanceData(input: input, disposeBag: disposeBag)
                    self?.getHotDancesData(disposeBag: disposeBag)
                    self?.getInfoDanceData(input: input, disposeBag: disposeBag)
                }
                if input.danceInfoView.progressBar.musicPlayer?.player?.currentItem == nil {
                    input.danceInfoView.progressBar.musicPlayer?.player?.replaceCurrentItem(with: self?.musicPlayerItem)
                }
            })
            .disposed(by: disposeBag)
        
        input.viewWillDisappear
            .subscribe(onNext: { [weak self] in
                self?.musicPlayerItem = input.danceInfoView.progressBar.musicPlayer?.player?.currentItem
                input.danceInfoView.progressBar.musicPlayer?.remove()
            })
        
        //바텀 스크롤 시, 하단 뷰에 섀도잉
        input.tableView.rx.contentOffset.asObservable()
            .subscribe(onNext: { [weak self] point in
                if point.y > 0 {
                    output.didSelectViewShadow.accept(true)
                } else {
                    output.didSelectViewShadow.accept(false)
                }
            })
            .disposed(by: disposeBag)
        
        //pagination
        input.tableView.rx.contentOffset.asObservable()
            .skip(1)
            .throttle(.seconds(3), scheduler: MainScheduler.asyncInstance)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] offset in
                if offset.y > input.tableView.contentSize.height - input.tableView.frame.height {
                    self?.getRankedDanceData(input: input, disposeBag: disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        input.collectionView.rx.contentOffset.asObservable()
            .skip(1)
            .throttle(.seconds(3), scheduler: MainScheduler.asyncInstance)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] offset in
                if offset.y > input.collectionView.contentSize.height - input.collectionView.frame.height {
                    self?.getHotDancesData(disposeBag: disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        input.collectionView.rx.contentOffset.asObservable()
            .subscribe(onNext: { [weak self] point in
                if point.y > 0 {
                    output.didSelectViewShadow.accept(true)
                } else {
                    output.didSelectViewShadow.accept(false)
                }
            })
            .disposed(by: disposeBag)
        
        input.hotButtonTapped
            .subscribe(onNext: {
                output.didHotButtonTapped.accept(true)
                input.collectionView.isHidden = false
            })
            .disposed(by: disposeBag)
        
        input.collectionView.rx.itemSelected.asObservable()
            .withUnretained(self)
            .subscribe(onNext: { (_, indexPath) in
                var videoData: [NormalVideoCollectionViewDataSection] = [.init(items: [])]
                videoData[0].items = self.hotDanceResult[0].items
                self.danceCoordinator?.pushToNormalVideoView(videoData: videoData,
                                                             pageNum: self.hotDancePageNum,
                                                             type: .dance,
                                                             indexPath: indexPath)
            })
            .disposed(by: disposeBag)

        input.rankingButtonTapped
            .subscribe(onNext: {
                output.didRankingButtonTapped.accept(true)
                input.collectionView.isHidden = true
            })
            .disposed(by: disposeBag)

        
        input.backButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.danceCoordinator?.pop()
            })
            .disposed(by: disposeBag)
        
        
        //datasource 구현 및 empty cell 구현
        rankResultRelay
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: input.tableView.rx.items(dataSource: rankDataSource!))
            .disposed(by: disposeBag)
        
        rankResultRelay
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] _ in
                output.isRankingViewEmpty.accept(self!.rankResult[0].items.isEmpty)
            })
            .disposed(by: disposeBag)
        
        hotResultRelay
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: input.collectionView.rx.items(dataSource: hotDanceDataSource!))
            .disposed(by: disposeBag)
        
        hotResultRelay
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] _ in
                output.isHotDanceViewEmpty.accept(self!.hotDanceResult[0].items.isEmpty)
            })
            .disposed(by: disposeBag)
        
        
        //플로팅 버튼 선택시
        input.gameStartButtonTapped
            .when(.recognized)
            .withUnretained(self)
            .asDriver{ _ in .never()}
            .drive(onNext: { (vm, gesture) in
                output.didPlayButtonTapped.accept(())
            })
            .disposed(by: disposeBag)
        
        input.playAlertView.okButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] in
                input.playAlertView.isHidden = true
                self?.getEnergyData(disposeBag: disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.playAlertView.cancelButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] in
                output.didCancelButtonTapped.accept(())
            })
            .disposed(by: disposeBag)
        
        self.isEnergyEnoughRelay
            .withUnretained(self)
            .subscribe(onNext: { (_, data) in
                if data {
                    //challengemode
                    DispatchQueue.main.async {
                        if self.isChallengeMode {
                            self.danceCoordinator?.pushToChallengeGameView(danceData: self.playDanceData!)
                        } else { //practicemode
                            self.danceCoordinator?.pushToPracticeGameView(danceData: self.playDanceData!)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        input.danceInfoView.progressBar.musicPlayer?.pause()
                        input.danceInfoView.progressBar.musicPlayButton.isSelected = false
                        self.danceCoordinator?.presentToStoreView()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        self.startLottieRelay
            .withUnretained(self)
            .subscribe(onNext: { _ in
                output.didStartLoadData.accept(())
            })
            .disposed(by: disposeBag)
        
        self.removeLottieRelay
            .withUnretained(self)
            .subscribe(onNext: { _ in
                output.didLoadData.accept(())
            })
            .disposed(by: disposeBag)
        
        input.playAlertView.isChallengeMode
            .withUnretained(self)
            .bind(onNext: { (vm, state) in
                vm.isChallengeMode = state
            })
            .disposed(by: disposeBag)
        
        input.danceInfoView.heartButton.rx.tap.asObservable()
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                if input.danceInfoView.heartButton.isSelected {
                    input.danceInfoView.heartButton.isSelected = false
                    vm.patchLikeDance(input: input, state: -1, disposebag: disposeBag)
                } else {
                    input.danceInfoView.heartButton.isSelected = true
                    vm.patchLikeDance(input: input, state: 1, disposebag: disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
    struct Input {
        let viewDidAppeared: Observable<Void>
        let viewWillDisappear: Observable<Void>
        let backButtonTapped: Observable<Void>
        let rankingButtonTapped: Observable<Void>
        let hotButtonTapped: Observable<Void>
        let gameStartButtonTapped: Observable<UITapGestureRecognizer>
        let danceInfoView: DanceInfoView
        let playAlertView: SelectGameAlertView
        let collectionView: UICollectionView
        let tableView: UITableView
        
    }
    struct Output {
        var didSelectViewShadow = PublishRelay<Bool>()
        var didRankingButtonTapped = PublishRelay<Bool>()
        var didHotButtonTapped = PublishRelay<Bool>()
        var isRankingViewEmpty = PublishRelay<Bool>()
        var isHotDanceViewEmpty = PublishRelay<Bool>()
        var didPlayButtonTapped = PublishRelay<Void>()
        var didCancelButtonTapped = PublishRelay<Void>()
        var didStartLoadData = PublishRelay<Void>()
        var didLoadData = PublishRelay<Void>()
    }
    
    var createdAtDate: Date?
    private func didCanPlayGame(staminaInfo: Stamina) -> Bool{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // 주어진 문자열의 형식 지정
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // UTC로 지정
        self.createdAtDate = dateFormatter.date(from: staminaInfo.staminaLatestUpdate)!
        
        let now = Date()
        let utcMillis = now.timeIntervalSince1970 * 1000.0
        let nowUtcDate = Date(timeIntervalSince1970: utcMillis / 1000.0)
        
        /** 시간 차 */
        let diff = nowUtcDate.timeIntervalSince(self.createdAtDate!)
        let addedStamina = diff / 600
        var totalStamina: Int = 0
        
        let minValue = min(5, Int(staminaInfo.stamina + addedStamina))
        if staminaInfo.stamina >= 5 {
            totalStamina = Int(staminaInfo.stamina)
        } else {
            totalStamina = minValue
        }
        print(totalStamina, "토탈")
        if totalStamina >= 1 {
            return true
        } else {
            return false
        }
    }
    
    private func getEnergyData(disposeBag: DisposeBag) {
        self.startLottieRelay.accept(())
        self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in (self?.userRepository.getUserStamina())! }
            .withUnretained(self)
            .subscribe(onNext: {(_, result) in
                print(result, "result")
                if result.data.stamina.onFree {
                    self.isEnergyEnoughRelay.accept(true)
                } else {
                    self.isEnergyEnoughRelay.accept(self.didCanPlayGame(staminaInfo: result.data.stamina))
                }
                self.removeLottieRelay.accept(())
            })
            .disposed(by: disposeBag)
    }
    
    private func getRankedDanceData(input: Input, disposeBag: DisposeBag) {
        self.startLottieRelay.accept(())
        print(self.danceId)
        self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in (self!.danceRepository?.getDanceList(danceId: self!.danceId, page: self!.rankPageNum))! }
            .subscribe(onNext: { [weak self] result in
                if !result.items.isEmpty {
                    self!.rankPageNum += 1
                }
                if !self!.rankResult.isEmpty {
                    self!.rankResult[0].items.append(contentsOf: result.items)
                } else {
                    self!.rankResult.append(contentsOf: [result])
                }
                
                if self!.rankHeaderData.isEmpty {
                    self!.setRankHeaderData()
                }
                self!.rankResultRelay.accept(self!.rankResult)
                self!.removeLottieRelay.accept(())
            })
            .disposed(by: disposeBag)
    }
    
    private func getHotDancesData(disposeBag: DisposeBag) {
        self.startLottieRelay.accept(())
        self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in self!.videoRepository.getTypeVideo(type: GetTypeVideoType.dance,
                                                                             targetId: self!.danceId,
                                                                             page: self!.hotDancePageNum) }
            .subscribe(onNext: { [weak self] result in
                if !result.items.isEmpty {
                    self?.hotDancePageNum += 1
                }
                if !self!.hotDanceResult.isEmpty {
                    self!.hotDanceResult[0].items.append(contentsOf: result.items)
                } else {
                    self!.hotDanceResult.append(contentsOf: [result])
                }
                self!.hotResultRelay.accept(self!.hotDanceResult)
                self!.removeLottieRelay.accept(())
            })
            .disposed(by: disposeBag)
    }
    
    
    private func setRankHeaderData() {
        if self.rankResult[0].items.count > 3 {
            let result: [DanceRankList] = rankResult[0].items
            
            self.rankHeaderData = [result[0],
                                   result[1],
                                   result[2]]
            for index in 0 ... 2 {
                self.rankResult[0].items.remove(at: 0)
            }
            DispatchQueue.main.async {
                self.input?.tableView.reloadData()
            }
        }
    }
    
    private func getInfoDanceData(input: Input,
                                  disposeBag: DisposeBag){
        self.startLottieRelay.accept(())
        self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in (self?.danceRepository?.getDanceInfo(danceId: self!.danceId))!}
            .subscribe(onNext: { [weak self] result in
                input.playAlertView.setData(imagePath: result.data.coverURL,
                                            musicName: result.data.title,
                                            artistName: result.data.artist)
                self!.playDanceData = .init(danceID: self!.danceId,
                                            artist: result.data.artist,
                                            title: result.data.title,
                                            musicURL: result.data.musicURL,
                                            coverURL: result.data.coverURL,
                                            alreadyLiked: false)
                DispatchQueue.main.async {
                    input.danceInfoView.progressBar.musicPlayer?.play()
                    input.danceInfoView.progressBar.musicPlayButton.isSelected.toggle()
                }
                self!.removeLottieRelay.accept(())
            })
            .disposed(by: disposeBag)
    }
    
    private func patchLikeDance(input: Input,
                                state: Int,
                                disposebag: DisposeBag) {
        self.startLottieRelay.accept(())
        self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap { (vm, _) in (vm.danceRepository?.patchLikeDane(danceId: vm.danceId,
                                                                     state: state))!}
            .withUnretained(self)
            .subscribe(onNext: { (vm, result) in
                print(result.data.state)
                vm.removeLottieRelay.accept(())
            })
            .disposed(by: disposebag)
    }
}
 
extension DanceViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ScreenUtils.setWidth(value: 80)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.rankHeaderData.count > 2 {
            return ScreenUtils.setWidth(value: 280)
        } else {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.rankHeaderData.count > 2 {
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: DanceRankingHeaderView.identifier) as? DanceRankingHeaderView else {return UITableViewHeaderFooterView()}
            headerView.setData(profilePath: [rankHeaderData[0].profileURL ?? "",
                                             rankHeaderData[1].profileURL ?? "",
                                             rankHeaderData[2].profileURL ?? ""],
                               userName: [rankHeaderData[0].identifierName,
                                          rankHeaderData[1].identifierName,
                                          rankHeaderData[2].identifierName],
                               userScore: [rankHeaderData[0].score,
                                           rankHeaderData[1].score,
                                           rankHeaderData[2].score],
                               isBlocked: [rankHeaderData[0].isBlock,
                                           rankHeaderData[1].isBlock,
                                           rankHeaderData[2].isBlock])
            return headerView
        } else {
            return nil
        }
    }
}
