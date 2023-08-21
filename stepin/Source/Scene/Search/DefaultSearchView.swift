import UIKit
import Then
import SnapKit

class DefaultSearchView: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: .zero)
        self.setLayout()
        self.setCollectionView()
    }
    
    private func setLayout() {
        self.backgroundColor = .stepinBlack100
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    private func setCollectionView() {
        self.collectionView.register(SearchDefaultHeaderView.self,
                                     forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SearchDefaultHeaderView.identifier)
        self.collectionView.register(HashTagResultHeaderView.self,
                                     forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HashTagResultHeaderView.identifier)
        self.collectionView.register(SearchDefaultTitleLabelCVC.self, forCellWithReuseIdentifier: SearchDefaultTitleLabelCVC.identifier)
        
        self.collectionView.register(AccountCVC.self, forCellWithReuseIdentifier: AccountCVC.identifier)
        self.collectionView.register(SearchDanceCVC.self, forCellWithReuseIdentifier: SearchDanceCVC.identifier)
        self.collectionView.register(VideoPreviewCVC.self, forCellWithReuseIdentifier: VideoPreviewCVC.identifier)
        self.collectionView.register(SearchHashTagCVC.self, forCellWithReuseIdentifier: SearchHashTagCVC.identifier)
    }
    
    internal var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        $0.setCollectionViewLayout(layout, animated: false)
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.backgroundColor = .stepinBlack100
        $0.bounces = true
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.alwaysBounceVertical = true
        $0.contentInsetAdjustmentBehavior = .never
    }
}
