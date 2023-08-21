import Foundation
import RxCocoa
import RxSwift
import FSCalendar
import RealmSwift
import RxDataSources

final class PlaySearchViewModel: NSObject {
    var coordinator : PlaySearchCoordinator?
    var danceRepository: DanceRepository?
    var authRepository = AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    var disposeBag: DisposeBag?
    
    internal var searchViewState: SearchViewState = .searchMain
    private var input: Input?
    private var targetText: String = ""
    
    //datasource
    //first loading view
    private var hotDanceDataSource: RxTableViewSectionedReloadDataSource<PlayDanceTableViewDataSection>?
    private var hotDanceData: [PlayDanceTableViewDataSection] = []
    private var hotDanceRelay = PublishRelay<[PlayDanceTableViewDataSection]>()
    
    //relation search
    private var autoCompletedatasource: RxTableViewSectionedReloadDataSource<SearchDanceListCollectionViewDataSection>?
    private var autoCompleteData: [SearchDanceListCollectionViewDataSection] = []
    private var autoCompleteRelay = PublishRelay<[SearchDanceListCollectionViewDataSection]>()
    private var autoCompletePageNum: Int = 1
    
    init(coordinator: PlaySearchCoordinator,
         danceRepository: DanceRepository) {
        self.coordinator = coordinator
        self.danceRepository = danceRepository
    }
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let textFieldDidEditing: Observable<String>
        let textField: UITextField
        let backButtonTapped: Observable<Void>
        let searchButtonTapped: Observable<Void>
        let defaultSearchTableView: UITableView
        let autoCompleteTableView: UITableView
    }
    
    struct Output {
        var defaultSearchCollectionViewHidden = PublishRelay<Bool>()
        var autoCompleteCollectionViewHidden = PublishRelay<Bool>()
        var didSearchButtonTapped = PublishRelay<Void>()
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        self.input = input
        self.disposeBag = disposeBag
        
        self.hotDanceDataSource = RxTableViewSectionedReloadDataSource<PlayDanceTableViewDataSection>(
            configureCell: { [weak self] dataSource, tableView, indexPath, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: PlayDefaultSearchTVC.identifier, for: indexPath) as? PlayDefaultSearchTVC else {return UITableViewCell()}
                cell.setData(title: dataSource[indexPath.section].items[indexPath.row].title)
                return cell
            })
        
        self.autoCompletedatasource = RxTableViewSectionedReloadDataSource<SearchDanceListCollectionViewDataSection>(
            configureCell: { [weak self] dataSource, tableView, indexPath, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: PlayDanceTableViewCell.reuseIdentifier, for: indexPath) as? PlayDanceTableViewCell else {return UITableViewCell()}
                cell.bindData(imagePath: dataSource[indexPath.section].items[indexPath.row].coverURL,
                              musicTitle: dataSource[indexPath.section].items[indexPath.row].title,
                              artist: dataSource[indexPath.section].items[indexPath.row].artist,
                              isLiked: false)
                
//                cell.didLikeButtonTapCompletion = { state in
//                    self?.didLikeDance(danceId: dataSource[indexPath.section].items[indexPath.row].danceID,
//                                       state: state,
//                                       disposeBag: disposeBag)
//                }
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
                self?.autoCompleteData = []
                self?.autoCompletePageNum = 1
                self?.getSearchDanceData(keyWord: self!.targetText, disposeBag: disposeBag)
                output.autoCompleteCollectionViewHidden.accept(true)
            })
            .disposed(by: disposeBag)
        
        input.textFieldDidEditing
            .throttle(.milliseconds(500), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] text in
                if text.count >= 1 {
                    self?.autoCompletePageNum = 1
                    self?.targetText = text
                    self?.getSearchDanceData(keyWord: text, disposeBag: disposeBag)
                    output.autoCompleteCollectionViewHidden.accept(true)
                } else {
                    self?.autoCompleteData = []
                    self!.autoCompletePageNum = 1
                    self?.autoCompleteRelay.accept(self!.autoCompleteData)
                    output.defaultSearchCollectionViewHidden.accept(true)
                }
            })
            .disposed(by: disposeBag)
        
        self.hotDanceRelay
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: input.defaultSearchTableView.rx.items(dataSource: hotDanceDataSource!))
            .disposed(by: disposeBag)
        
        self.autoCompleteRelay
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: input.autoCompleteTableView.rx.items(dataSource: autoCompletedatasource!))
            .disposed(by: disposeBag)
        
        input.autoCompleteTableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        input.defaultSearchTableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        return output
    }
    
    
    private func getHotDanceData(disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in (self?.danceRepository?.getPlayHotDanceList(page: 1))! }
            .subscribe(onNext: { [weak self] result in
                self?.searchViewState = .searchMain
                self?.hotDanceData = [result]
                self?.hotDanceRelay.accept(self!.hotDanceData)
            })
            .disposed(by: disposeBag)
    }
    
    
    private func getSearchDanceData(keyWord: String, disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in (self?.danceRepository?.getSearchDanceList(keyword: keyWord,
                                                                                   page: self!.autoCompletePageNum))! }
            .subscribe(onNext: { [weak self] result in
                self?.autoCompleteData = []
                if !result.items.isEmpty {
                    self?.autoCompletePageNum += 1
                }
                if !self!.autoCompleteData.isEmpty {
                    self!.autoCompleteData[0].items.append(contentsOf: result.items)
                } else {
                    self!.autoCompleteData.append(contentsOf: [result])
                }
                self!.autoCompleteRelay.accept(self!.autoCompleteData)
            })
            .disposed(by: disposeBag)
    }
    
    private func didLikeDance(danceId: String, state: Int, disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .observe(on: MainScheduler.asyncInstance)
            .flatMap { [weak self] _ in (self?.danceRepository?.patchLikeDance(danceId: danceId, state: state))! }
            .subscribe(onNext: { [weak self] result in
                print(state)
            })
            .disposed(by: disposeBag)
    }
}
extension PlaySearchViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 1 {
            self.targetText = self.hotDanceData[indexPath.section].items[indexPath.row].title
            self.input?.textField.text = self.targetText
            self.input?.defaultSearchTableView.isHidden = true
            self.input?.autoCompleteTableView.isHidden = false
            self.getSearchDanceData(keyWord: self.targetText, disposeBag: self.disposeBag!)
        } else {
            self.coordinator?.pushToDanceView(danceId: self.autoCompleteData[indexPath.section].items[indexPath.row].danceID)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView.tag == 1 {
            return ScreenUtils.setWidth(value: 65)
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: PlayDefaultSearchHeaderView.identifier) as? PlayDefaultSearchHeaderView else {return UITableViewHeaderFooterView()}
        return view
    }
}
