import UIKit
import SDSKit
import SnapKit
import Then
import MarqueeLabel
import Kingfisher

final class ResultHeaderView: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    init() {
        super.init(frame: .zero)
        self.setLayout()
    }
    
    private func setLayout() {
        self.addSubviews([musicImageView, artistLabel, musicTitleLabel, scoreStateLabel, scoreLabel, bottomGradientView])
        musicImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
//            $0.bottom.equalTo(self.bottomGradientView.snp.top).inset(-20)
            $0.leading.equalToSuperview()
            $0.width.height.equalTo(40.adjusted)
        }
        musicImageView.clipsToBounds = true
        musicImageView.layer.cornerRadius = 20.adjusted
        
        musicTitleLabel.snp.makeConstraints {
            $0.top.equalTo(musicImageView.snp.top).offset(3.adjusted)
            $0.leading.equalTo(musicImageView.snp.trailing).offset(12.adjusted)
            $0.width.equalTo(120)
        }
        artistLabel.snp.makeConstraints {
            $0.top.equalTo(musicTitleLabel.snp.bottom)
            $0.leading.equalTo(musicTitleLabel.snp.leading)
            $0.width.equalTo(120)
        }
        scoreStateLabel.snp.makeConstraints {
            $0.centerY.equalTo(musicImageView)
            $0.trailing.equalTo(self.scoreLabel.snp.leading).inset(-19)
        }
        scoreLabel.snp.makeConstraints {
            $0.centerY.equalTo(musicImageView)
            $0.trailing.equalToSuperview()
        }
        bottomGradientView.snp.makeConstraints {
            $0.top.equalTo(musicImageView.snp.bottom).offset(20)
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    func bindMusicInfoData(musicImagePath: String,
                           musicTitle: String,
                           artist: String) {
        if let url = URL(string: musicImagePath) {
            self.musicImageView.kf.setImage(with: url)
        }
        self.musicTitleLabel.text = musicTitle
        self.artistLabel.text = artist
    }
    
    func setScoreLabelShadow(state: String,
                             score: String,
                             color: UIColor) {
        self.scoreStateLabel.setTextWithShadow(state,
                                               color: color,
                                               radius: 5)
        self.scoreLabel.setTextWithShadow(score,
                                          color: color,
                                          radius: 5)
    }
    
    private let musicImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    private let musicTitleLabel = MarqueeLabel().then {
        $0.trailingBuffer = 20
        $0.font = SDSFont.body2.font
        $0.textColor = .PrimaryWhiteNormal
    }
    private let artistLabel = MarqueeLabel().then {
        $0.font = SDSFont.caption2.font
        $0.textColor = .PrimaryWhiteNormal
    }
    private let scoreStateLabel = UILabel().then {
        $0.font = SDSFont.body.font
        $0.textColor = .PrimaryWhiteNormal
    }
    private let scoreLabel = UILabel().then {
        $0.font = SDSFont.body.font
        $0.textColor = .PrimaryWhiteNormal
    }
    private let bottomGradientView = UIView().then {
        $0.addGradient(size: .init(width: UIScreen.main.bounds.width - 32,
                                   height: 1),
                       colors: [UIColor.clear.cgColor,
                                UIColor.PrimaryWhiteAlternative.cgColor,
                                UIColor.clear.cgColor],
                       startPoint: .centerLeft,
                       endPoint: .centerRight)
    }
}
