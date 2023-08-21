import UIKit
import SnapKit
import Then
import Kingfisher

class SelectedMyVideoCVC: UICollectionViewCell {
    static let identifier: String = "SelectedMyVideoCVC"
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.setLayout()
    }
    
    internal func bindCellData(imagePath: String,
                               isChecked: Bool) {
        guard let url = URL(string: imagePath) else {return}
        self.thumbnailImageView.kf.setImage(with: url)
        self.selectButton.isSelected = isChecked
    }
    
    internal func didCellSelected(isSelected: Bool) {
        self.selectButton.isSelected = isSelected
    }
    
    private func setLayout() {
        self.addSubviews([thumbnailImageView, selectButton])
        thumbnailImageView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        selectButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 8))
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 16))
        }
    }
    
    private let thumbnailImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }
    private let selectButton = UIButton().then {
        $0.backgroundColor = .clear
        $0.setImage(ImageLiterals.icUnselect, for: .normal)
        $0.setImage(ImageLiterals.icNormalSelected, for: .selected)
    }
}
