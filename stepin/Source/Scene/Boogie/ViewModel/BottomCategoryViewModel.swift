import Foundation
import RxSwift
import RxRelay
import RxDataSources


final class BottomCategoryViewModel: NSObject {
    var dataSource: RxCollectionViewSectionedReloadDataSource<BoogieBottomTagCollectionViewDataSection>?
    var pageNum: Int = 1
    var childBoogieResult: [BoogieBottomTagCollectionViewDataSection] = [.init(items: [])]
    
    private var resultRelay = PublishRelay<[BoogieBottomTagCollectionViewDataSection]>()
    private var isFirstLoad = true
    
    internal func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        var output = Output()
        dataSource = RxCollectionViewSectionedReloadDataSource<BoogieBottomTagCollectionViewDataSection>(
            configureCell: {  [weak self] dataSource, collectionView, indexPath, item in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BottomCategoryCVC.identifier, for: indexPath) as? BottomCategoryCVC else {return UICollectionViewCell() }
                cell.setCellConfig(title: dataSource[indexPath.section].items[indexPath.row].music)
                
                if self!.isFirstLoad && indexPath.row == 0 {
                    cell.didSelectCell()
                }
                
                return cell
            })
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(setBottomCategoryData(_:)),
            name: NSNotification.Name("child_boogie_tag"),
            object: nil
        )
        
        input.collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
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
    
    @objc private func setBottomCategoryData(_ sender: NSNotification) {
        //bottom을 새롭게 로딩하는 경우이기 때문에, 무조껀적으로 첫번째 셀이 선택되도록 해줌
        self.isFirstLoad = true
        self.childBoogieResult = [.init(items: [])]
        let data = sender.object as! [ChildBoogieTag]
        self.childBoogieResult[0].items.append(contentsOf: data)
        self.resultRelay.accept(self.childBoogieResult)
    }
}
 
extension BottomCategoryViewModel: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.childBoogieResult[indexPath.section].items[indexPath.row].musicID != "" {
            if let cell = collectionView.cellForItem(at: [0, 0]) as? BottomCategoryCVC {
                if indexPath.row != 0 && self.isFirstLoad {
                    cell.didDeSelecteCell()
                    self.isFirstLoad = false
                }
            }
            
            if let cell = collectionView.cellForItem(at: indexPath) as? BottomCategoryCVC {
                cell.didSelectCell()
                NotificationCenter.default.post(name: NSNotification.Name("boogie_data_bottom_musicID"),
                                                object: self.childBoogieResult[indexPath.section].items[indexPath.row].musicID,
                                                userInfo: nil)
                
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print(indexPath)
        if let cell = collectionView.cellForItem(at: indexPath) as? BottomCategoryCVC {
            cell.didDeSelecteCell()
        }
    }
}
