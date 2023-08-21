import Foundation
import RxCocoa
import RxSwift
import RealmSwift
import RxDataSources

enum SearchViewState {
    case searchMain
    case searching
}

final class SearchViewModel: NSObject {
    var coordinator : SearchViewCoordinator?
    var videoRepository: VideoRepository?
    var danceRepository: DanceRepository?
    var hashTagRepository: HashTagRepository?
    var authRepository = AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    
    internal var searchViewState: SearchViewState = .searchMain
    private var input: Input?
    private var targetText: String = ""
    
    //datasource
    //first loading view
    private var hotDanceDataSource: RxCollectionViewSectionedReloadDataSource<SearchDanceListCollectionViewDataSection>?
    private var hotDanceData: [SearchDanceListCollectionViewDataSection] = []
    private var hotDanceRelay = PublishRelay<[SearchDanceListCollectionViewDataSection]>()
    
    //relation search
    private var autoCompletedatasource: RxCollectionViewSectionedReloadDataSource<AutoCompleteCollectionViewDataSection>?
    private var autoCompleteData: [AutoCompleteCollectionViewDataSection] = []
    private var autoCompleteRelay = PublishRelay<[AutoCompleteCollectionViewDataSection]>()
    
    init(coordinator: SearchViewCoordinator,
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
        let textFieldDidEditing: Observable<String>
        let backButtonTapped: Observable<Void>
        let searchButtonTapped: Observable<Void>
        let defaultSearchCollectionView: DefaultSearchView
        let autoCompleteCollectionView: DefaultSearchView
    }
    
    struct Output {
        var topCategoryViewHidden = PublishRelay<Bool>()
        var defaultSearchCollectionViewHidden = PublishRelay<Bool>()
        var autoCompleteCollectionViewHidden = PublishRelay<Bool>()
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        self.input = input
        
        self.hotDanceDataSource = RxCollectionViewSectionedReloadDataSource<SearchDanceListCollectionViewDataSection>(
            configureCell: { dataSource, collectionView, indexPath, item in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchDefaultTitleLabelCVC.identifier, for: indexPath) as? SearchDefaultTitleLabelCVC else { return UICollectionViewCell() }
                cell.setData(title: dataSource[indexPath.section].items[indexPath.row].title)
                return cell
            }, configureSupplementaryView: { (dataSource, collectionView, kind, indexPath) in
                switch kind {
                case UICollectionView.elementKindSectionHeader:
                    guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                       withReuseIdentifier: SearchDefaultHeaderView.identifier,
                                                                                       for: indexPath) as? SearchDefaultHeaderView else {return UICollectionReusableView() }
                    return header
                default:
                    return UICollectionReusableView()
//                    assert(false, "Un expected element kind")
                }
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
                self!.getHotDanceData(disposeBag: disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.backButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.pop()
            })
            .disposed(by: disposeBag)
        
        input.searchButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.pushToSearchDetail(keyword: self!.targetText)
            })
            .disposed(by: disposeBag)
        
        input.textFieldDidEditing
            .subscribe(onNext: { [weak self] text in
                if text.count >= 1 {
                    self?.targetText = text
                    self?.getAutoCompleteData(keyWord: text, disposeBag: disposeBag)
                    output.autoCompleteCollectionViewHidden.accept(true)
                } else {
                    self?.autoCompleteData = []
                    self?.autoCompleteRelay.accept(self!.autoCompleteData)
                    output.defaultSearchCollectionViewHidden.accept(true)
                }
            })
            .disposed(by: disposeBag)
        
        self.hotDanceRelay
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: input.defaultSearchCollectionView.collectionView.rx.items(dataSource: hotDanceDataSource!))
            .disposed(by: disposeBag)
        
        self.autoCompleteRelay
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: input.autoCompleteCollectionView.collectionView.rx.items(dataSource: autoCompletedatasource!))
            .disposed(by: disposeBag)
        
        input.autoCompleteCollectionView.collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        input.defaultSearchCollectionView.collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        return output
    }
    
    func setCollectionViewLayout(input: Input) {
        var layout = UICollectionViewFlowLayout()
        
        switch searchViewState {
        case .searchMain:
            DispatchQueue.main.async {
                layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width,
                                                    height: ScreenUtils.setWidth(value: 65))
                layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
                layout.itemSize = CGSize(width: UIScreen.main.bounds.width,
                                         height: ScreenUtils.setWidth(value: 20))
                layout.minimumLineSpacing = ScreenUtils.setWidth(value: ScreenUtils.setWidth(value: 40))
                layout.minimumInteritemSpacing = ScreenUtils.setWidth(value: ScreenUtils.setWidth(value: 20))
                input.defaultSearchCollectionView.collectionView.setCollectionViewLayout(layout, animated: false)
            }
        case .searching:
            DispatchQueue.main.async {
                layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
                layout.itemSize = CGSize(width: UIScreen.main.bounds.width,
                                         height: ScreenUtils.setWidth(value: 20))
                layout.minimumLineSpacing = ScreenUtils.setWidth(value: ScreenUtils.setWidth(value: 40))
                layout.minimumInteritemSpacing = ScreenUtils.setWidth(value: ScreenUtils.setWidth(value: 20))
                input.autoCompleteCollectionView.collectionView.setCollectionViewLayout(layout, animated: false)
            }
        }
    }
    
    func getHotDanceData(disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in (self?.danceRepository?.getHotDanceList(page: 1))! }
            .subscribe(onNext: { [weak self] result in
                self?.searchViewState = .searchMain
                self?.setCollectionViewLayout(input: self!.input!)
                self?.hotDanceData = [result]
                self?.hotDanceRelay.accept(self!.hotDanceData)
            })
            .disposed(by: disposeBag)
    }
    
    func getAutoCompleteData(keyWord: String, disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in (self?.danceRepository?.getAutoCompleted(keyword: keyWord))! }
            .subscribe(onNext: { [weak self] result in
                self?.searchViewState = .searching
                self?.setCollectionViewLayout(input: self!.input!)
                self?.autoCompleteData = [result]
                self?.autoCompleteRelay.accept(self!.autoCompleteData)
            })
            .disposed(by: disposeBag)
    }
    
}
extension SearchViewModel: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.input?.autoCompleteCollectionView.collectionView {
            self.coordinator?.pushToSearchDetail(keyword: self.autoCompleteData[indexPath.section].items[indexPath.row].title)
        } else {
            self.coordinator?.pushToSearchDetail(keyword: self.hotDanceData[indexPath.section].items[indexPath.row].title)
        }
    }
}
