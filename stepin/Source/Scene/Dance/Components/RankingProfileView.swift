import UIKit
import SDSKit
import SnapKit
import MarqueeLabel
import Then

enum RankingProfileType {
    case first
    case second
    case third
}

class RankingProfileView: UIView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(type: RankingProfileType) {
        super.init(frame: .zero)
        setLayout(type: type)
    }
    
    internal func setData(profilePath: String,
                          userName: String,
                          userScore: String,
                          rank: String,
                          isBlocked: Bool) {
        if profilePath == "" {
            self.profileImageView.image = SDSIcon.icDefaultProfile
        } else {
            guard let url = URL(string: profilePath) else {return}
            self.profileImageView.kf.setImage(with: url)
        }
        self.userNameLabel.text = userName
        self.userScoreLabel.text = "\(userScore) p"
        self.setRankLabel(rank: rank)
        
        DispatchQueue.main.async {
            if isBlocked {
                self.blockedLabel.isHidden = false
                self.userNameLabel.alpha = 0.4
                self.userScoreLabel.alpha = 0.4
                self.overlayView.isHidden = false
            } else {
                self.blockedLabel.isHidden = true
                self.overlayView.isHidden = true
            }
        }
    }
    
    private func setLayout(type: RankingProfileType) {
        profileImageBackgroundView.addSubview(profileImageView)
        profileImageView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        self.addSubviews([profileImageBackgroundView, rankNumberLabel, userNameLabel, userScoreLabel, rankingImageView, blockedLabel])
        switch type {
        case .first:
            rankingImageView.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.centerX.equalToSuperview()
                $0.width.equalTo(ScreenUtils.setWidth(value: 85))
                $0.height.equalTo(ScreenUtils.setWidth(value: 70))
            }
            profileImageBackgroundView.snp.makeConstraints {
                $0.top.equalTo(rankingImageView.snp.bottom).inset(ScreenUtils.setWidth(value: 10))
                $0.centerX.equalToSuperview()
                $0.width.height.equalTo(ScreenUtils.setWidth(value: 110))
            }
            rankNumberLabel.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.centerY.equalTo(profileImageView.snp.bottom).offset(-10)
                $0.height.equalTo(70.adjusted)
            }
            rankingImageView.image = SDSIcon.icCrown
            profileImageBackgroundView.layer.cornerRadius = ScreenUtils.setWidth(value: 55)
            profileImageBackgroundView.layer.borderWidth = 4
            profileImageView.layer.cornerRadius = ScreenUtils.setWidth(value: 55)
            profileImageView.layer.borderWidth = 4
        case .second:
            rankingImageView.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.centerX.equalToSuperview()
                $0.width.equalTo(ScreenUtils.setWidth(value: 51))
                $0.height.equalTo(ScreenUtils.setWidth(value: 55))
            }
            profileImageBackgroundView.snp.makeConstraints {
                $0.top.equalTo(rankingImageView.snp.bottom).inset(ScreenUtils.setWidth(value: 10))
                $0.centerX.equalToSuperview()
                $0.width.height.equalTo(ScreenUtils.setWidth(value: 72))
            }
            rankNumberLabel.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.centerY.equalTo(profileImageView.snp.bottom)
                $0.height.equalTo(47.adjusted)
            }
            rankingImageView.image = ImageLiterals.icSilverMedal
            profileImageBackgroundView.layer.cornerRadius = ScreenUtils.setWidth(value: 36)
            profileImageBackgroundView.layer.borderWidth = 2
            profileImageView.layer.cornerRadius = ScreenUtils.setWidth(value: 36)
            profileImageView.layer.borderWidth = 2
        case .third:
            rankingImageView.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.centerX.equalToSuperview()
                $0.width.equalTo(ScreenUtils.setWidth(value: 41))
                $0.height.equalTo(ScreenUtils.setWidth(value: 55))
            }
            profileImageBackgroundView.snp.makeConstraints {
                $0.top.equalTo(rankingImageView.snp.bottom).inset(ScreenUtils.setWidth(value: 10))
                $0.centerX.equalToSuperview()
                $0.width.height.equalTo(ScreenUtils.setWidth(value: 72))
            }
            rankNumberLabel.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.centerY.equalTo(profileImageView.snp.bottom)
                $0.height.equalTo(47.adjusted)
            }
            rankingImageView.image = ImageLiterals.icBronzeMedal
            profileImageBackgroundView.layer.cornerRadius = ScreenUtils.setWidth(value: 36)
            profileImageBackgroundView.layer.borderWidth = 2
            profileImageView.layer.cornerRadius = ScreenUtils.setWidth(value: 36)
            profileImageView.layer.borderWidth = 2
        }
        userNameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(16.adjusted)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(70.adjusted)
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
        }
        userScoreLabel.snp.makeConstraints {
            $0.top.equalTo(userNameLabel.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
        }
        profileImageView.layer.borderColor = UIColor.stepinWhite100.cgColor
        profileImageView.clipsToBounds = true
        
        profileImageView.addSubview(overlayView)
        overlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        overlayView.isHidden = true
        self.setGradient()
        rankNumberLabel.drawShadow(color: .PrimaryBlackHeavy,
                                   opacity: 0.7,
                                   offset: .zero,
                                   radius: 5)
        
        blockedLabel.snp.makeConstraints {
            $0.centerX.centerY.equalTo(self.profileImageView)
        }
        blockedLabel.isHidden = true
    }
    
    private func setGradient() {
        profileImageBackgroundView.layer.borderColor = UIColor.stepinWhite100.cgColor
        profileImageBackgroundView.layer.shadowColor = UIColor.stepinWhite100.cgColor
        profileImageBackgroundView.layer.shadowOpacity = 0.4
        profileImageBackgroundView.layer.shadowRadius = ScreenUtils.setWidth(value: 10)
        profileImageBackgroundView.clipsToBounds = false
    }
    
    private func setRankLabel(rank: String) {
        let ordinalRank = ordinalString(for: Int(rank) ?? 0)
        if rank != "1" {
            self.rankNumberLabel.font = .ShrikhandRegular(ofSize: 32)
            self.rankNumberLabel.attributedText = ordinalRank.setAttributeString(range: .init(location: 1, length: ordinalRank.count - 1),
                                                                                  font: SDSFont.shirkhandTitle.font.withSize(12),
                                                                                  textColor: .PrimaryWhiteNormal)
        } else {
            self.rankNumberLabel.font = .ShrikhandRegular(ofSize: 48)
            self.rankNumberLabel.attributedText = ordinalRank.setAttributeString(range: .init(location: 1, length: ordinalRank.count - 1),
                                                                                 font: SDSFont.shirkhandTitle.font.withSize(20),
                                                                                 textColor: .PrimaryWhiteNormal)
        }
        
    }
    func ordinalString(for number: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal
        numberFormatter.locale = .init(identifier: "en")
        guard let ordinalString = numberFormatter.string(from: NSNumber(value: number)) else {
            return "\(number)"
        }
        return ordinalString
    }
    
    private var rankingImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    private var profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    private var profileImageBackgroundView = UIView().then {
        $0.backgroundColor = .stepinWhite100
    }
    private var rankNumberLabel = UILabel().then {
        $0.font = .ShrikhandRegular(ofSize: 48)
        $0.textColor = .PrimaryWhiteNormal
        $0.textAlignment = .center
    }
    private var userNameLabel = MarqueeLabel().then {
        $0.trailingBuffer = 30
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
        $0.textAlignment = .center
    }
    private var userScoreLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
        $0.textAlignment = .center
    }
    private var blockedLabel = UILabel().then {
        $0.text = "dance_view_block_text".localized()
        $0.font = SDSFont.caption2.font
        $0.textColor = .PrimaryWhiteNormal
    }
    private let overlayView = UIView().then {
        $0.backgroundColor = .PrimaryBlackNormal.withAlphaComponent(0.4)
    }
}
