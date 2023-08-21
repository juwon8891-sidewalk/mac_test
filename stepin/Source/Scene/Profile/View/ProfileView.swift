import Foundation
import UIKit
import SDSKit
import SnapKit
import Then

class ProfileView: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: .zero)
        self.setLayout()
        self.setCollectionViewlayout()
    }
    
    private func setLayout() {
        self.addSubviews([collectionView, titleNavigationBar, blockLabel])
        titleNavigationBar.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60.adjusted)
        }
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        blockLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(530.adjustedH)
        }
        blockLabel.isHidden = true
    }
    
    func setBlockLabelText(userName: String) {
        self.blockLabel.text = "block_view_block_description".localized() + "\(userName)."
    }
    
    private func setCollectionViewlayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = .init(top: 0, left: 5, bottom: 0, right: 5)
        self.collectionView.setCollectionViewLayout(flowLayout, animated: false)
    }
    
    let titleNavigationBar = TitleNavigationView()
    let collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.backgroundColor = .PrimaryBlackNormal
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
        $0.contentInsetAdjustmentBehavior = .never
    }
    let blockLabel = UILabel().then {
        $0.font = SDSFont.body.font
        $0.textColor = .PrimaryWhiteNormal
    }
    
}
