import UIKit
import SDSKit
import SnapKit
import Then
import MarqueeLabel
import RxSwift
import RxRelay


class SelectGameAlertView: UIView {
    internal var danceData: PlayDance?
    let isChallengeMode = BehaviorRelay<Bool>(value: true)

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: .zero)
        self.setLayout()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        backGroundBlurView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func didChallengeButtonTapped() {
        self.challengeButton.titleLabel?.font = SDSFont.h1.font
        self.practiceButton.titleLabel?.font = SDSFont.h2.font
        self.challengeButton.isSelected = true
        self.practiceButton.isSelected = false
        isChallengeMode.accept(true)
    }
    
    @objc private func didPracticeButtonTapped() {
        self.challengeButton.titleLabel?.font = SDSFont.h2.font
        self.practiceButton.titleLabel?.font = SDSFont.h1.font
        self.practiceButton.isSelected = true
        self.challengeButton.isSelected = false
        isChallengeMode.accept(false)
    }
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.alpha = 0
        } completion: { _ in
            self.isHidden = true
        }
    }
    
    internal func setData(danceData: PlayDance) {
        self.danceData = danceData
        guard let url = URL(string: self.danceData?.coverURL ?? "") else {return}
        self.profileImageView.kf.setImage(with: url)
        self.musicNameLabel.text = self.danceData?.title ?? ""
        self.artistNameLabel.text = self.danceData?.artist ?? ""
    }
    
    internal func setData(imagePath: String,
                          musicName: String,
                          artistName: String) {
        DispatchQueue.main.async {
            guard let url = URL(string: imagePath) else {return}
            self.profileImageView.kf.setImage(with: url)
            self.musicNameLabel.text = musicName
            self.artistNameLabel.text = artistName
        }
    }
    
    private func setLayout() {
        self.addSubviews([backGroundBlurView, contentView])
        backGroundBlurView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.equalTo(272.adjusted)
            $0.height.equalTo(282.adjusted)
        }

        contentView.addSubviews([profileImageView, musicNameLabel, artistNameLabel ,descriptionLabel, challengeButton, practiceButton, cancelButton, okButton])
        

        profileImageView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top).offset(24.adjusted)
            $0.width.equalTo(40.adjusted)
            $0.height.equalTo(40.adjusted)
            $0.leading.equalTo(contentView.snp.leading).offset(38.5.adjusted)
        }
        
        profileImageView.layer.cornerRadius = 20.adjusted
        profileImageView.clipsToBounds = true

        musicNameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.top)
            $0.width.equalTo(143.adjusted)
            $0.height.equalTo(20.adjusted)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(12.adjusted)
        }
        artistNameLabel.snp.makeConstraints {
            $0.leading.equalTo(musicNameLabel.snp.leading)
            $0.width.equalTo(musicNameLabel)
            $0.height.equalTo(15.adjusted)
            $0.top.equalTo(musicNameLabel.snp.bottom).offset(4.adjusted)
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(artistNameLabel.snp.bottom).offset(16.5.adjusted)
            $0.leading.trailing.equalToSuperview()
        }
        
        challengeButton.snp.makeConstraints {
            $0.centerX.equalTo(contentView.snp.centerX)
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(24.adjusted)
            $0.height.equalTo(25.adjusted)
        }
        self.challengeButton.isSelected = true
        practiceButton.snp.makeConstraints {
            $0.leading.equalTo(self.challengeButton.snp.leading)
            $0.height.equalTo(25.adjusted)
            $0.top.equalTo(challengeButton.snp.bottom).offset(20.adjusted)
        }
        
        
        okButton.snp.makeConstraints {
            $0.bottom.equalTo(contentView.snp.bottom).inset(16.adjusted)
            $0.trailing.equalTo(contentView.snp.trailing).inset(16.adjusted)
            $0.width.equalTo(112.adjusted)
            $0.height.equalTo(48.adjusted)
        }
        cancelButton.snp.makeConstraints {
            $0.bottom.equalTo(contentView.snp.bottom).inset(16.adjusted)
            $0.leading.equalTo(contentView.snp.leading).offset(16.adjusted)
            $0.trailing.equalTo(cancelButton.snp.leading).offset(16.adjusted)
            $0.width.height.equalTo(okButton)
        }
    }
    private var backGroundBlurView = UIView().then {
        $0.backgroundColor = .black
        $0.alpha = 0.7
    }
    private var contentView = UIView().then {
        $0.backgroundColor = .PrimaryBlackNormal
        $0.layer.cornerRadius = 30.adjusted
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.PrimaryWhiteAlternative.cgColor
        $0.clipsToBounds = true
    }
    private var profileImageView = UIImageView()
    private var musicNameLabel = MarqueeLabel().then {
        $0.trailingBuffer = 30
        $0.font = SDSFont.body.font
        $0.textColor = .PrimaryWhiteNormal
    }
    private var artistNameLabel = MarqueeLabel().then {
        $0.trailingBuffer = 30
        $0.font = SDSFont.caption2.font
        $0.textColor = .PrimaryWhiteNormal
    }
    private var descriptionLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = SDSFont.body.font
        $0.textColor = .PrimaryWhiteNormal
        $0.numberOfLines = 0
        $0.text = "play_game_alert_description_text".localized()
    }
    
    private lazy var challengeButton = UIButton().then {
        $0.tintColor = .clear
        var config = UIButton.Configuration.plain()
        config.imagePadding = 10
        config.background.backgroundColor = .clear
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
           var outgoing = incoming
            outgoing.font = SDSFont.h1.font
           return outgoing
        }
        $0.configuration = config
        $0.contentHorizontalAlignment = .left
        $0.setImage(SDSIcon.icRadioDeselect, for: .normal)
        $0.setImage(SDSIcon.icRadioSelect, for: .selected)
        $0.setTitle("play_game_alert_challenge_button_title".localized(), for: .normal)
        $0.setTitleColor(.PrimaryWhiteAlternative, for: .normal)
        $0.setTitleColor(.PrimaryWhiteNormal, for: .selected)
        $0.titleLabel?.font = SDSFont.h1.font
        $0.addTarget(self, action: #selector(didChallengeButtonTapped), for: .touchUpInside)
    
        
    }
    private lazy var practiceButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.imagePadding = 10
        config.background.backgroundColor = .clear
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
           var outgoing = incoming
            outgoing.font = SDSFont.h1.font
           return outgoing
        }
        $0.configuration = config
        $0.contentHorizontalAlignment = .left
        $0.setImage(SDSIcon.icRadioDeselect, for: .normal)
        $0.setImage(SDSIcon.icRadioSelect, for: .selected)
        $0.setTitle("play_game_alert_practice_button_title".localized(), for: .normal)
        $0.setTitleColor(.PrimaryWhiteAlternative, for: .normal)
        $0.setTitleColor(.PrimaryWhiteNormal, for: .selected)
        $0.addTarget(self, action: #selector(didPracticeButtonTapped), for: .touchUpInside)
    }
    internal let cancelButton = SDSSmallButton(type: .line).then {
        $0.setTitle("play_game_alert_cancel_button_title".localized(), for: .normal)
    }
    internal let okButton = SDSSmallButton(type: .alternative).then {
        $0.setTitle("play_game_alert_ok_button_title".localized(), for: .normal)
    }

}
