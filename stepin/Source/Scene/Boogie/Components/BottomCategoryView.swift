import UIKit
import SnapKit
import Then
import RxSwift
import RxDataSources

class BottomCategoryView: UIView {
    var disposeBag = DisposeBag()
    var viewModel = BottomCategoryViewModel()
    
    init() {
        super.init(frame: .zero)
        self.setLayout()
        self.setCollectionViewLayout()
        self.bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func bindViewModel() {
        self.viewModel.transform(from: .init(collectionView: self.collectionView),
                                 disposeBag: disposeBag)
    }
    
    private func setLayout() {
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    private func setCollectionViewLayout() {
        self.collectionView.register(BottomCategoryCVC.self, forCellWithReuseIdentifier: BottomCategoryCVC.identifier)
        var layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: ScreenUtils.setWidth(value: 16), bottom: 0, right: 0)
        layout.minimumLineSpacing = ScreenUtils.setWidth(value: 20)
        layout.minimumInteritemSpacing = ScreenUtils.setWidth(value: 20)
        layout.estimatedItemSize = .init(width: ScreenUtils.setWidth(value: 40), height: ScreenUtils.setWidth(value: 30))
        self.collectionView.setCollectionViewLayout(layout, animated: false)
    }
    
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        $0.setCollectionViewLayout(layout, animated: false)
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.backgroundColor = .clear
        $0.bounces = true
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.contentInsetAdjustmentBehavior = .never
    }
}
