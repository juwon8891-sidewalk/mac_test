import UIKit
import SnapKit
import Then


class SearchDanceCVC: UICollectionViewCell {
    static let identifier: String = "SearchDanceCVC"

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.musicCoverImageView.image = nil
        self.musicTitleLabel.text = ""
        self.musicianNameLabel.text = ""
    }
    
    internal func setData(musicImagePath: String, musicTitleText: String, musicianName: String) {
        guard let url = URL(string: musicImagePath) else {return}
        musicCoverImageView.kf.setImage(with: url)
        self.musicTitleLabel.text = musicTitleText
        self.musicianNameLabel.text = musicianName
        self.setLayout()
    }
    
    private func setLayout() {
        self.addSubviews([musicCoverImageView, musicTitleLabel, musicianNameLabel])
        musicCoverImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 40))
        }
        musicCoverImageView.layer.cornerRadius = ScreenUtils.setWidth(value: 20)
        musicCoverImageView.clipsToBounds = true
        musicTitleLabel.snp.makeConstraints {
            $0.top.equalTo(musicCoverImageView.snp.top)
            $0.leading.equalTo(musicCoverImageView.snp.trailing).offset(ScreenUtils.setWidth(value: 12))
            $0.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
        }
        musicianNameLabel.snp.makeConstraints {
            $0.bottom.equalTo(musicCoverImageView.snp.bottom)
            $0.leading.equalTo(musicCoverImageView.snp.trailing).offset(ScreenUtils.setWidth(value: 12))
            $0.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 17))
        }
    }
    
    private var musicCoverImageView = UIImageView()
    private var musicTitleLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
    }
    private var musicianNameLabel = UILabel().then {
        $0.font = .suitRegularFont(ofSize: 14)
        $0.textColor = .stepinWhite100
    }
}
