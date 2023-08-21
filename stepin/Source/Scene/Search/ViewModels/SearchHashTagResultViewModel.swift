import Foundation
import RxCocoa
import RxSwift
import RealmSwift
import RxDataSources

final class SearchHashTagResultViewModel: NSObject {
    var coordinator : SearchHashTagResultCoordinator?
    var videoRepository: VideoRepository?
    var authRepository = AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    
    //hashTagResultSearch
    private var hashTagResultdatasource: RxCollectionViewSectionedReloadDataSource<HotCollectionViewDataSection>?
    private var hashTagResultData: [HotCollectionViewDataSection] = []
    private var hashTagResultRelay = PublishRelay<[HotCollectionViewDataSection]>()
    private var hashTagResultPageNum = 1
    
    internal var hashTagId: String = ""
    internal var hashTitle: String = ""
    
    init(coordinator: SearchHashTagResultCoordinator,
         videoRepository: VideoRepository) {
        self.coordinator = coordinator
        self.videoRepository = videoRepository
    }
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let backButtonTapped: Observable<Void>
        let hashTagResultCollectionView: DefaultSearchView
    }
    
    struct Output {
        var navigationTitle = PublishRelay<String>()
        var isHashTagResultEmpty = PublishRelay<Bool>()
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        self.hashTagResultdatasource = RxCollectionViewSectionedReloadDataSource<HotCollectionViewDataSection>(
            configureCell: { dataSource, collectionView, indexPath, item in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoPreviewCVC.identifier, for: indexPath) as? VideoPreviewCVC else { return UICollectionViewCell() }
                cell.setImage(path: dataSource[indexPath.section].items[indexPath.row].thumbnailURL ?? "")
                return cell
            })
        
        input.viewWillAppear
            .subscribe(onNext: { [weak self] in
                self?.hashTagResultData = []
                self?.hashTagResultPageNum = 1
                self!.getHashTagResultVideo(keyWord: self!.hashTagId, disposeBag: disposeBag)
                output.navigationTitle.accept(self!.hashTitle)
            })
            .disposed(by: disposeBag)
        
        input.backButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.pop()
            })
            .disposed(by: disposeBag)
        
        
        input.hashTagResultCollectionView.collectionView.rx.contentOffset.asObservable()
            .skip(1)
            .throttle(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] offset in
                if offset.y > input.hashTagResultCollectionView.collectionView.contentSize.height - input.hashTagResultCollectionView.collectionView.frame.height {
                    print(offset.y)
                    print(input.hashTagResultCollectionView.collectionView.contentSize.height - input.hashTagResultCollectionView.collectionView.frame.height)
                    self!.getHashTagResultVideo(keyWord: self!.hashTagId, disposeBag: disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        self.hashTagResultRelay
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: input.hashTagResultCollectionView.collectionView.rx.items(dataSource: hashTagResultdatasource!))
            .disposed(by: disposeBag)
        
        input.hashTagResultCollectionView.collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        return output
    }
    
    
    func getHashTagResultVideo(keyWord: String, disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in (self?.videoRepository?.getTypeVideo(type: GetTypeVideoType.hashtag, targetId: keyWord, page: self!.hashTagResultPageNum))! }
            .subscribe(onNext: { [weak self] result in
                if !result.items.isEmpty {
                    self?.hashTagResultPageNum += 1
                }
                if !self!.hashTagResultData.isEmpty {
                    self!.hashTagResultData[0].items.append(contentsOf: result.items)
                } else {
                    self!.hashTagResultData.append(contentsOf: [result])
                }
                self!.hashTagResultRelay.accept(self!.hashTagResultData)
            })
            .disposed(by: disposeBag)
    }
}

extension SearchHashTagResultViewModel: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var videoData: [NormalVideoCollectionViewDataSection] = [.init(items: [])]
        videoData[0].items = self.hashTagResultData[0].items
        self.coordinator?.pushToVideoView(videoData: videoData,
                                          pageNum: self.hashTagResultPageNum,
                                          type: .searchHashTag,
                                          indexPath: indexPath)
    }
}
