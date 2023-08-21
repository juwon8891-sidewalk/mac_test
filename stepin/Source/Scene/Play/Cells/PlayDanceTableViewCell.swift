import UIKit
import SDSKit
import Kingfisher
import MarqueeLabel

final class PlayDanceTableViewCell: UITableViewCell {
    var heartButtonTapCompletion: ((Int) -> Void)?
    var playButtonTapCompletion: (() -> Void)?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        musicImageView.image = nil
        musicNameLabel.text = ""
        artistNameLabel.text = ""
    }
    
    func bindData(imagePath: String,
                  musicTitle: String,
                  artist: String,
                  isLiked: Bool) {
        if let url = URL(string: imagePath) {
            musicImageView.kf.setImage(with: url)
        }
        musicNameLabel.text = musicTitle
        artistNameLabel.text = artist
        heartButton.isSelected = isLiked
    }
    
    private func setLayout() {
        self.selectionStyle = .none
        self.contentView.addSubviews([musicImageView, musicNameLabel, artistNameLabel, heartButton, playButton])
        self.musicImageView.snp.makeConstraints {
            $0.bottom.top.equalToSuperview().inset(20.adjusted).priority(.high)
            $0.leading.equalToSuperview().offset(17.adjusted)
            $0.height.width.equalTo(40.adjusted)
        }
        musicImageView.layer.cornerRadius = 20.adjusted
        musicImageView.clipsToBounds = true
        
        playButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(17.adjusted)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(40.adjusted)
        }
        var playButtonConfig = UIButton.Configuration.plain()
        playButtonConfig.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        playButton.configuration = playButtonConfig
        
        heartButton.snp.makeConstraints {
            $0.trailing.equalTo(playButton.snp.leading).inset(-20.adjusted)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(40.adjusted)
        }
        var heartButtonConfig = UIButton.Configuration.plain()
        heartButtonConfig.background.backgroundColor = .clear
        heartButtonConfig.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        heartButton.configuration = heartButtonConfig
        
        musicNameLabel.snp.makeConstraints {
            $0.top.equalTo(musicImageView.snp.top).offset(3.adjusted)
            $0.trailing.equalTo(heartButton.snp.leading).inset(-20)
            $0.leading.equalTo(musicImageView.snp.trailing).offset(12.adjusted)
        }
        artistNameLabel.snp.makeConstraints {
            $0.bottom.equalTo(musicImageView.snp.bottom).inset(3.adjusted)
            $0.leading.equalTo(musicNameLabel.snp.leading)
            $0.trailing.equalTo(heartButton.snp.leading).inset(-20)
        }
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
    }
    
    @objc private func heartButtonTap() {
        guard let completion = heartButtonTapCompletion else { return }
        completion(self.heartButton.isSelected ? -1: 1)
        heartButton.isSelected.toggle()
    }
    
    @objc private func playButtonTap() {
        guard let completion = playButtonTapCompletion else { return }
        completion()
    }
    
    private let musicImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    private let musicNameLabel = MarqueeLabel().then {
        $0.trailingBuffer = 30
        $0.font = SDSFont.body.font
        $0.textColor = .PrimaryWhiteNormal
        $0.textAlignment = .left
    }
    private let artistNameLabel = MarqueeLabel().then {
        $0.trailingBuffer = 30
        $0.font = SDSFont.caption2.font
        $0.textColor = .PrimaryWhiteNormal
        $0.textAlignment = .left
    }
    private lazy var heartButton = UIButton().then {
        $0.addTarget(self,
                     action: #selector(heartButtonTap),
                     for: .touchUpInside)
        $0.setImage(SDSIcon.icHeartUnfill, for: .normal)
        $0.setImage(SDSIcon.icHeartFill, for: .selected)
    }
    private lazy var playButton = UIButton().then {
        $0.addTarget(self,
                     action: #selector(playButtonTap),
                     for: .touchUpInside)
        $0.setImage(SDSIcon.icGamePlay, for: .normal)
    }
    
}
