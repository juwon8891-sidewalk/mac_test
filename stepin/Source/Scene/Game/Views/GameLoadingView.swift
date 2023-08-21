import Foundation
import UIKit
import SDSKit
import SnapKit
import Then

class GameLoadingView: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    init() {
        super.init(frame: .zero)
        self.setLayout()
    }
    
    func bindData(imagePath: String,
                  title: String,
                  artist: String,
                  gameStateLabel: String = "play_game_loading_challenge_game_title".localized()) {
        self.titleLabel.text = gameStateLabel
        self.musicTitleLabel.text = title
        self.artistLabel.text = artist
        guard let url = URL(string: imagePath) else {return}
        self.coverImageView.kf.setImage(with: url)
    }
    
    private func setLayout() {
        self.layer.zPosition = 99
        self.addSubviews([backgroundImageView, energyStackView, titleLabel, coverImageView, musicTitleLabel, artistLabel])
        backgroundImageView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        energyStackView.addArrangeSubViews([energyImageView, energyCountLabel])
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(100.adjusted)
            $0.leading.trailing.equalToSuperview()
        }
        energyStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8.adjusted)
            $0.centerX.equalToSuperview()
        }
        energyImageView.snp.makeConstraints {
            $0.width.height.equalTo(24.adjusted)
        }
        coverImageView.snp.makeConstraints {
            $0.top.equalTo(energyStackView.snp.bottom).offset(20.adjusted)
            $0.width.height.equalTo(260.adjusted)
            $0.centerX.equalToSuperview()
        }
        coverImageView.clipsToBounds = true
        
        musicTitleLabel.snp.makeConstraints {
            $0.top.equalTo(coverImageView.snp.bottom).offset(20.adjusted)
            $0.centerX.equalToSuperview()
        }
        artistLabel.snp.makeConstraints {
            $0.top.equalTo(musicTitleLabel.snp.bottom)
            $0.leading.equalTo(musicTitleLabel.snp.leading)
        }
    }
    
    private let backgroundImageView = UIImageView(image: ImageLiterals.gameLoadingBackground)
    private let titleLabel = UILabel().then {
        $0.font = SDSFont.h1.font
        $0.textColor = .PrimaryWhiteNormal
        $0.textAlignment = .center
    }
    private let energyImageView = UIImageView(image: SDSIcon.icEnergy)
    private let energyCountLabel = UILabel().then {
        $0.text = "-1"
        $0.font = SDSFont.h1.font
        $0.textColor = .PrimaryWhiteNormal
    }
    private let energyStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.spacing = 4
    }
    private let coverImageView = UIImageView().then {
        $0.layer.cornerRadius = 30.adjusted
        $0.layer.borderColor = UIColor.PrimaryWhiteNormal.cgColor
        $0.layer.borderWidth = 2
        $0.contentMode = .scaleAspectFill
    }
    private let musicTitleLabel = UILabel().then {
        $0.font = SDSFont.body.font
        $0.textColor = .PrimaryWhiteNormal
        $0.textAlignment = .left
    }
    private let artistLabel = UILabel().then {
        $0.font = SDSFont.caption2.font
        $0.textColor = .PrimaryWhiteNormal
        $0.textAlignment = .left
    }
    
}
