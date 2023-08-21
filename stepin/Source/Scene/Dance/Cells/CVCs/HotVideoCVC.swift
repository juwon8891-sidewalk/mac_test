import UIKit

class HotVideoCVC: UICollectionViewCell {
    static let identifier: String = "HotVideoCVC"
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    internal func setData(thumbnailPath: String,
                          viewCount: Int) {
        guard let url = URL(string: thumbnailPath) else {return}
        self.thumbnailImageView.kf.setImage(with: url)
//        self.viewCountButton.setTitle(String(viewCount), for: .normal)
        setLayout()
    }
    
    private func setLayout() {
        self.addSubviews([thumbnailImageView, viewCountButton])
        thumbnailImageView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        thumbnailImageView.layer.cornerRadius = ScreenUtils.setWidth(value: 4)
        thumbnailImageView.clipsToBounds = true
        viewCountButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 8))
            $0.bottom.equalToSuperview().inset(ScreenUtils.setWidth(value: 8))
            $0.height.equalTo(ScreenUtils.setWidth(value: 15))
        }
        viewCountButton.isHidden = true
    }
    
    private var thumbnailImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    private var viewCountButton = UIButton().then {
        $0.setImage(ImageLiterals.icPlay, for: .normal)
        $0.setTitle("", for: .normal)
        $0.setTitleColor(.stepinWhite100, for: .normal)
        $0.titleLabel?.font = .suitExtraBoldFont(ofSize: 12)
    }
}
