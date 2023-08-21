import Foundation
import RxSwift
import RxRelay
import RxDataSources

final class TopCategoryViewModel: NSObject {
    let tokenUtil = TokenUtils()
    
    var hashTagRepository: HashTagRepository?
    var authRepository = AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    var dataSource: RxCollectionViewSectionedReloadDataSource<BoogieTagCollectionViewDataSection>?
    var pageNum: Int = 1
    var boogieResult: [BoogieTagCollectionViewDataSection] = []
    
    private var resultRelay = PublishRelay<[BoogieTagCollectionViewDataSection]>()
    private var isFirstLoad = true
    
    init(hashtagRepository: HashTagRepository) {
        self.hashTagRepository = hashtagRepository
    }
    
    internal func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        var output = Output()
        dataSource = RxCollectionViewSectionedReloadDataSource<BoogieTagCollectionViewDataSection>(
            configureCell: {  [weak self] dataSource, collectionView, indexPath, item in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopCategoryCVC.identifier, for: indexPath) as? TopCategoryCVC else {return UICollectionViewCell() }
                cell.setCellConfig(title: dataSource[indexPath.section].items[indexPath.row].artist)
                
                if self!.isFirstLoad && indexPath.row == 0 {
                    cell.didSelectCell()
                }
                
                return cell
            })
        
        input.collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        self.getBoogieTag(input: input, disposeBag: disposeBag)
        
        self.resultRelay
            .bind(to: input.collectionView.rx.items(dataSource: self.dataSource!))
            .disposed(by: disposeBag)
        
        return output
    }
    
    struct Input {
        let collectionView: UICollectionView
    }
    struct Output {
    
    }
    
    
    private func getBoogieTag(input: Input, disposeBag: DisposeBag) {
         self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in (self!.hashTagRepository?.getBoogieHashTag())! }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                //NowTap추가 위함
                self!.boogieResult.append(contentsOf: [result])
                self?.boogieResult[0].items.insert(contentsOf: [.init(artistID: "", artist: "Now", childBoogieTag: [])], at: 0)
                self!.resultRelay.accept(self!.boogieResult)
            })
            .disposed(by: disposeBag)
    }
    
}
 
//상단 선택시
extension TopCategoryViewModel: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: [0, 0]) as? TopCategoryCVC {
            if indexPath.row != 0 && self.isFirstLoad {
                cell.didDeSelecteCell()
                self.isFirstLoad = false
            }
        }
        
        if let cell = collectionView.cellForItem(at: indexPath) as? TopCategoryCVC {
            cell.didSelectCell()
            //하단 탭 선택시
            NotificationCenter.default.post(name: NSNotification.Name("child_boogie_tag"),
                                            object: self.boogieResult[indexPath.section].items[indexPath.row].childBoogieTag,
                                            userInfo: nil)
            
            //상단 탭 선택시
            NotificationCenter.default.post(name: NSNotification.Name("selected_boogie_data"),
                                            object: self.boogieResult[indexPath.section].items[indexPath.row],
                                            userInfo: nil)
            //    NotificationCenter.default.addObserver(
            //        self,
            //        selector: #selector(didTappCommentButtonTapped(_:)),
            //        name: NSNotification.Name("SSF_CommentTapped"),
            //        object: nil
            //    )
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print(indexPath)
        if let cell = collectionView.cellForItem(at: indexPath) as? TopCategoryCVC {
            cell.didDeSelecteCell()
        }
    }
}
