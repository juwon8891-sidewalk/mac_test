import UIKit
import Kingfisher

class VideoPreviewCVC: UICollectionViewCell {
    static let identifier: String = "VideoPreviewCVC"
    
    init() {
        super.init(frame: .zero)
        setlayout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setlayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func setImage(path: String) {
        guard let url = URL(string: path) else {return}
        previewImageview.kf.setImage(with: url)
    }
    private func setlayout() {
        self.addSubview(previewImageview)
        previewImageview.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        previewImageview.layer.cornerRadius = ScreenUtils.setWidth(value: 4)
        previewImageview.clipsToBounds = true
    }
    
    private var previewImageview = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
}
