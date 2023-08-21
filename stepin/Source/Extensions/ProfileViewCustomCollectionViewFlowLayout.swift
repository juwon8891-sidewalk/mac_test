import UIKit

class ProfileViewCustomCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    private func setCellSize() {
        self.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 490.adjustedH)
        self.minimumLineSpacing = 3
        self.minimumInteritemSpacing = 3
        let width: CGFloat = (UIScreen.main.bounds.width - (14)) / 3
        self.itemSize = CGSize(width: width , height: 150.adjusted)
    }
    override init() {
        super.init()
        self.sectionFootersPinToVisibleBounds = true
        setCellSize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sectionFootersPinToVisibleBounds = true
        setCellSize()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        for attribute in attributes {
            adjustAttributesIfNeeded(attribute)
        }
        return attributes
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath) else { return nil }
        adjustAttributesIfNeeded(attributes)
        return attributes
    }
    
    func adjustAttributesIfNeeded(_ attributes: UICollectionViewLayoutAttributes) {
        switch attributes.representedElementKind {
        case UICollectionView.elementKindSectionHeader?:
            adjustHeaderAttributesIfNeeded(attributes)
        case UICollectionView.elementKindSectionFooter?:
            adjustFooterAttributesIfNeeded(attributes)
        default:
            break
        }
    }
    
    private func adjustHeaderAttributesIfNeeded(_ attributes: UICollectionViewLayoutAttributes) {
        guard let collectionView = collectionView else { return }
        guard attributes.indexPath.section == 0 else { return }
        

        let fixedHeight = 490.adjustedH - 130.adjustedH - getSafeAreaTop()
        
        if collectionView.contentOffset.y > fixedHeight {
            self.sectionHeadersPinToVisibleBounds = true
            attributes.frame.origin.y = collectionView.contentOffset.y - fixedHeight
        }
        else {
            self.sectionHeadersPinToVisibleBounds = false
            attributes.frame.origin.y = .zero
        }
    }
    
    private func adjustFooterAttributesIfNeeded(_ attributes: UICollectionViewLayoutAttributes) {
        guard let collectionView = collectionView else { return }
        guard attributes.indexPath.section == collectionView.numberOfSections - 1 else { return }
        
        if collectionView.contentOffset.y + collectionView.bounds.size.height > collectionView.contentSize.height {
            attributes.frame.origin.y = collectionView.contentOffset.y + collectionView.bounds.size.height - attributes.frame.size.height
        }
    }
    
    func getSafeAreaTop() -> CGFloat {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        return (keyWindow?.safeAreaInsets.top)!
    }
}
