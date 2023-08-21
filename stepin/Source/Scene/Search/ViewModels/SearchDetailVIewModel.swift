import Foundation
import RxCocoa
import RxSwift
import FSCalendar
import RealmSwift
import RxDataSources

final class SearchDetailViewModel: NSObject {
    var coordinator : SearchDetailCoordinator?
    var videoRepository: VideoRepository?
    var danceRepository: DanceRepository?
    var hashTagRepository: HashTagRepository?
    var userRepository = UserRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    var authRepository = AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    
    internal var searchViewState: SearchViewState = .searchMain
    private var input: Input?
    private var output: Output?
    private var disposeBag: DisposeBag?
    private var targetText: String = ""
    private var selectedHashTag: String = ""
    
    //datasource
    //hotVideo
    private var hotDanceDataSource: RxCollectionViewSectionedReloadDataSource<SearchHotVideoCollectionViewDataSection>?
    private var hotDanceData: [SearchHotVideoCollectionViewDataSection] = []
    private var hotDanceRelay = PublishRelay<[SearchHotVideoCollectionViewDataSection]>()
    private var hotPageNum = 1
    
    //account search
    private var accountdatasource: RxCollectionViewSectionedReloadDataSource<SearchUserCollectionViewDataSection>?
    private var accountData: [SearchUserCollectionViewDataSection] = []
    private var accountRelay = PublishRelay<[SearchUserCollectionViewDataSection]>()
    private var accountPageNum = 1
    
    //dance search
    private var dancedatasource: RxCollectionViewSectionedReloadDataSource<SearchDanceListCollectionViewDataSection>?
    private var danceData: [SearchDanceListCollectionViewDataSection] = []
    private var danceRelay = PublishRelay<[SearchDanceListCollectionViewDataSection]>()
    private var dancePageNum = 1
    
    //hashTagSearch
    private var hashTagdatasource: RxCollectionViewSectionedReloadDataSource<SearchHashTagCollectionViewDataSection>?
    private var hashTagData: [SearchHashTagCollectionViewDataSection] = []
    private var hashTagRelay = PublishRelay<[SearchHashTagCollectionViewDataSection]>()
    private var hashtagPageNum = 1
    
    //autoComplete
    private var autoCompletedatasource: RxCollectionViewSectionedReloadDataSource<AutoCompleteCollectionViewDataSection>?
    private var autoCompleteData: [AutoCompleteCollectionViewDataSection] = []
    private var autoCompleteRelay = PublishRelay<[AutoCompleteCollectionViewDataSection]>()
    
    init(coordinator: SearchDetailCoordinator,
         videoRepository: VideoRepository,
         danceRepository: DanceRepository,
         hashTagRepository: HashTagRepository) {
        self.coordinator = coordinator
        self.videoRepository = videoRepository
        self.danceRepository = danceRepository
        self.hashTagRepository = hashTagRepository
    }
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let textField: UITextField
        let backButtonTapped: Observable<Void>
        let searchButtonTapped: Observable<Void>
        let topCategoryView: SearchViewTopCategoryView
        let hotVideoCollectionView: DefaultSearchView
        let accountCollectionView: DefaultSearchView
        let danceCollectionView: DefaultSearchView
        let hashTagCollectionView: DefaultSearchView
        let autoCompleteCollectionView: DefaultSearchView
    }
    
    struct Output {
        var hotVideoCollectionBringToSubView = PublishRelay<Bool>()
        var accountCollectionViewBringToSubView = PublishRelay<Bool>()
        var danceCollectionViewBringToSubView = PublishRelay<Bool>()
        var hashtagCollectionViewBringToSubView = PublishRelay<Bool>()
        var autoCompleteViewIshidden = PublishRelay<Bool>()
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        self.output = output
        self.input = input
        self.disposeBag = disposeBag
        
        self.hotDanceDataSource = RxCollectionViewSectionedReloadDataSource<SearchHotVideoCollectionViewDataSection>(
            configureCell: { dataSource, collectionView, indexPath, item in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoPreviewCVC.identifier, for: indexPath) as? VideoPreviewCVC else { return UICollectionViewCell() }
                cell.setImage(path: dataSource[indexPath.section].items[indexPath.row].thumbnailURL ?? "")
                return cell
            })
        
        self.accountdatasource = RxCollectionViewSectionedReloadDataSource<SearchUserCollectionViewDataSection>(
            configureCell: { dataSource, collectionView, indexPath, item in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AccountCVC.identifier, for: indexPath) as? AccountCVC else { return UICollectionViewCell() }
                cell.setData(profilePath: dataSource[indexPath.section].items[indexPath.row].profileURL ?? "",
                             userName: dataSource[indexPath.section].items[indexPath.row].identifierName)
                return cell
            })
        
        self.dancedatasource = RxCollectionViewSectionedReloadDataSource<SearchDanceListCollectionViewDataSection>(
            configureCell: { dataSource, collectionView, indexPath, item in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchDanceCVC.identifier, for: indexPath) as? SearchDanceCVC else { return UICollectionViewCell() }
                cell.setData(musicImagePath: dataSource[indexPath.section].items[indexPath.row].coverURL,
                             musicTitleText: dataSource[indexPath.section].items[indexPath.row].title,
                             musicianName: dataSource[indexPath.section].items[indexPath.row].artist)
                return cell
            })
        
        self.hashTagdatasource = RxCollectionViewSectionedReloadDataSource<SearchHashTagCollectionViewDataSection>(
            configureCell: { dataSource, collectionView, indexPath, item in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchHashTagCVC.identifier, for: indexPath) as? SearchHashTagCVC else { return UICollectionViewCell() }
                print(dataSource[indexPath.section].items[indexPath.row].keyword)
                cell.setData(hashTag: dataSource[indexPath.section].items[indexPath.row].keyword)
                return cell
            })
        
        self.autoCompletedatasource = RxCollectionViewSectionedReloadDataSource<AutoCompleteCollectionViewDataSection>(
            configureCell: { dataSource, collectionView, indexPath, item in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchDefaultTitleLabelCVC.identifier, for: indexPath) as? SearchDefaultTitleLabelCVC else { return UICollectionViewCell() }
                cell.setData(title: dataSource[indexPath.section].items[indexPath.row].title)
                cell.changeTextColor(targetText: self.targetText)
                return cell
            })
        
        input.viewWillAppear
            .subscribe(onNext: { [weak self] in
                self!.getHotVideoData(input: input, disposeBag: disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.searchButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.didReloadSearchResult(input: input, disposeBag: disposeBag)
                output.autoCompleteViewIshidden.accept(true)
            })
            .disposed(by: disposeBag)
        
        input.autoCompleteCollectionView.collectionView.rx.itemSelected.asObservable()
            .subscribe(onNext: { [weak self] indexPath in
                output.autoCompleteViewIshidden.accept(true)
            })
            .disposed(by: disposeBag)
        
        input.textField.rx.text.orEmpty.asObservable()
            .subscribe(onNext: { [weak self] text in
                if text.count >= 1 {
                    self?.targetText = text
                    self?.getAutoCompleteData(keyWord: text, disposeBag: disposeBag)
                    output.autoCompleteViewIshidden.accept(false)
                } else {
                    self?.autoCompleteData = []
                    self?.autoCompleteRelay.accept(self!.autoCompleteData)
                    output.autoCompleteViewIshidden.accept(true)
                }
            })
            .disposed(by: disposeBag)
        
        input.backButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.pop()
            })
            .disposed(by: disposeBag)
        
        input.topCategoryView.hotButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.getHotVideoData(input: input, disposeBag: disposeBag)
                output.hotVideoCollectionBringToSubView.accept(true)
            })
            .disposed(by: disposeBag)
        
        input.topCategoryView.accountButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.getAccountData(input: input, disposeBag: disposeBag)
                output.accountCollectionViewBringToSubView.accept(true)
            })
            .disposed(by: disposeBag)
        
        input.topCategoryView.danceButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.getDanceData(input: input, disposeBag: disposeBag)
                output.danceCollectionViewBringToSubView.accept(true)
            })
            .disposed(by: disposeBag)
        
        input.topCategoryView.hashtagButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.getHashTagData(input: input, disposeBag: disposeBag)
                output.hashtagCollectionViewBringToSubView.accept(true)
            })
            .disposed(by: disposeBag)
        
        input.hotVideoCollectionView.collectionView.rx.contentOffset.asObservable()
            .skip(1)
            .throttle(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] offset in
                if offset.y > input.hotVideoCollectionView.collectionView.contentSize.height - input.hotVideoCollectionView.collectionView.frame.height {
                    self?.getHotVideoData(input: input, disposeBag: disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        input.accountCollectionView.collectionView.rx.contentOffset.asObservable()
            .skip(1)
            .throttle(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] offset in
                if offset.y > input.accountCollectionView.collectionView.contentSize.height - input.accountCollectionView.collectionView.frame.height {
                    self?.getAccountData(input: input, disposeBag: disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        input.danceCollectionView.collectionView.rx.contentOffset.asObservable()
            .skip(1)
            .throttle(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] offset in
                if offset.y > input.danceCollectionView.collectionView.contentSize.height - input.danceCollectionView.collectionView.frame.height {
                    self?.getDanceData(input: input, disposeBag: disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        input.danceCollectionView.collectionView.rx.contentOffset.asObservable()
            .skip(1)
            .throttle(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] offset in
                if offset.y > input.danceCollectionView.collectionView.contentSize.height - input.danceCollectionView.collectionView.frame.height {
                    self?.getDanceData(input: input, disposeBag: disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        input.hashTagCollectionView.collectionView.rx.contentOffset.asObservable()
            .skip(1)
            .throttle(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] offset in
                if offset.y > input.hashTagCollectionView.collectionView.contentSize.height - input.hashTagCollectionView.collectionView.frame.height {
                    self?.getHashTagData(input: input, disposeBag: disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        self.hotDanceRelay
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: input.hotVideoCollectionView.collectionView.rx.items(dataSource: hotDanceDataSource!))
            .disposed(by: disposeBag)
        
        input.hotVideoCollectionView.collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        self.accountRelay
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: input.accountCollectionView.collectionView.rx.items(dataSource: accountdatasource!))
            .disposed(by: disposeBag)
        
        input.accountCollectionView.collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        self.danceRelay
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: input.danceCollectionView.collectionView.rx.items(dataSource: dancedatasource!))
            .disposed(by: disposeBag)
        
        input.danceCollectionView.collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        self.hashTagRelay
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: input.hashTagCollectionView.collectionView.rx.items(dataSource: hashTagdatasource!))
            .disposed(by: disposeBag)
        
        input.hashTagCollectionView.collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)

        self.autoCompleteRelay
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: input.autoCompleteCollectionView.collectionView.rx.items(dataSource: autoCompletedatasource!))
            .disposed(by: disposeBag)
        
        input.autoCompleteCollectionView.collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        return output
    }
    
    private func didReloadSearchResult(input: Input, disposeBag: DisposeBag) {
        self.hotDanceData = []
        self.hotPageNum = 1
        self.accountData = []
        self.accountPageNum = 1
        self.danceData = []
        self.dancePageNum = 1
        self.hashTagData = []
        self.hashtagPageNum = 1
        self.getHotVideoData(input: input, disposeBag: disposeBag)
        self.getAccountData(input: input, disposeBag: disposeBag)
        self.getDanceData(input: input, disposeBag: disposeBag)
        self.getHashTagData(input: input, disposeBag: disposeBag)
    }
    
    func getHotVideoData(input: Input, disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in (self?.videoRepository?.getSearchHotVideo(keyword: input.textField.text ?? "",
                                                                                  page: self!.hotPageNum))! }
            .subscribe(onNext: { [weak self] result in
                if !result.items.isEmpty {
                    self?.hotPageNum += 1
                }
                if !self!.hotDanceData.isEmpty {
                    self!.hotDanceData[0].items.append(contentsOf: result.items)
                } else {
                    self!.hotDanceData.append(contentsOf: [result])
                }
                self!.hotDanceRelay.accept(self!.hotDanceData)
            })
            .disposed(by: disposeBag)
    }
    
    func getAccountData(input: Input, disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in (self?.userRepository.getSearchUserData(name: input.textField.text ?? "",
                                                                                page: self!.accountPageNum))! }
            .subscribe(onNext: { [weak self] result in
                if !result.items.isEmpty {
                    self?.accountPageNum += 1
                }
                if !self!.accountData.isEmpty {
                    self!.accountData[0].items.append(contentsOf: result.items)
                } else {
                    self!.accountData.append(contentsOf: [result])
                }
                self!.accountRelay.accept(self!.accountData)
            })
            .disposed(by: disposeBag)
    }
    
    func getDanceData(input: Input, disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in (self?.danceRepository?.getSearchDanceList(keyword: input.textField.text ?? "",
                                                                                   page: self!.dancePageNum))! }
            .subscribe(onNext: { [weak self] result in
                if !result.items.isEmpty {
                    self?.dancePageNum += 1
                }
                if !self!.danceData.isEmpty {
                    self!.danceData[0].items.append(contentsOf: result.items)
                } else {
                    self!.danceData.append(contentsOf: [result])
                }
                self!.danceRelay.accept(self!.danceData)
            })
            .disposed(by: disposeBag)
    }
    
    func getHashTagData(input: Input, disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in (self?.hashTagRepository?.getSearchHashTag(page: self!.hashtagPageNum,
                                                                                   keyword: input.textField.text ?? ""))! }
            .subscribe(onNext: { [weak self] result in
                if !result.items.isEmpty {
                    self?.hashtagPageNum += 1
                }
                if !self!.hashTagData.isEmpty {
                    self!.hashTagData[0].items.append(contentsOf: result.items)
                } else {
                    self!.hashTagData.append(contentsOf: [result])
                }
                self!.hashTagRelay.accept(self!.hashTagData)
            })
            .disposed(by: disposeBag)
    }
    
    func getAutoCompleteData(keyWord: String, disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in (self?.danceRepository?.getAutoCompleted(keyword: keyWord))! }
            .subscribe(onNext: { [weak self] result in
                self?.searchViewState = .searching
                self?.autoCompleteData = [result]
                self?.autoCompleteRelay.accept(self!.autoCompleteData)
            })
            .disposed(by: disposeBag)
    }
}

extension SearchDetailViewModel: UICollectionViewDelegate {
    func changeVideoData() -> [NormalVideoCollectionViewDataSection] {
        var normalVideoData: [NormalVideoCollectionViewDataSection] = [.init(items: [])]
        normalVideoData[0].items = hotDanceData[0].items
        return normalVideoData
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case input?.autoCompleteCollectionView.collectionView:
            self.didReloadSearchResult(input: self.input!, disposeBag: self.disposeBag!)
        case input?.hotVideoCollectionView.collectionView:
            //videoView
            self.coordinator?.pushToVideoView(videoData: self.changeVideoData(),
                                              pageNum: self.hotPageNum,
                                              cellVideoType: .searchHot,
                                              indexPath: indexPath)
            break
        case input?.accountCollectionView.collectionView:
            //mypage이동
            if accountData[0].items[indexPath.row].userID == UserDefaults.standard.string(forKey: UserDefaultKey.userId) {
                coordinator?.pushToMyProfileView()
            } else {
                coordinator?.pushToOtherProfileView(userId: accountData[0].items[indexPath.row].userID)
            }
            break
        case input?.danceCollectionView.collectionView:
            self.coordinator?.pushToDanceView(danceId: self.danceData[indexPath.section].items[indexPath.row].danceID)
        case input?.hashTagCollectionView.collectionView:
            self.coordinator?.pushToHashTagResult(hashTagId: self.hashTagData[indexPath.section].items[indexPath.row].id,
                                                  hashTagTitle: self.hashTagData[indexPath.section].items[indexPath.row].keyword)
        default:
            break
        }
    }
}
