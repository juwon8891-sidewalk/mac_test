import UIKit
import SDSKit
import SnapKit
import Then

class RankingTVC: UITableViewCell {
    static let identifier: String = "RankingTVC"

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.rankingNumLabel.text = ""
        self.profileImageView.image = nil
        self.userNameLabel.text = ""
        self.userScoreLabel.text = ""
    }
    
    internal func setData(profilePath: String,
                          userName: String,
                          score: String,
                          ranking: Int,
                          isBlocked: Bool) {
        if profilePath == "" {
            self.profileImageView.image = SDSIcon.icDefaultProfile
        } else {
            guard let url = URL(string: profilePath) else {return}
            self.profileImageView.kf.setImage(with: url)
        }
        self.userNameLabel.text = userName
        self.userScoreLabel.text = score + " p"
        self.rankingNumLabel.text = String(ranking)
        self.setLayout(isBlocking: isBlocked)
    }
    
    
    private func setLayout(isBlocking: Bool) {
        self.backgroundColor = .stepinWhite10
        self.addSubviews([rankingNumLabel, profileImageView, userNameLabel, userScoreLabel])
        rankingNumLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 20))
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
        }
        profileImageView.snp.makeConstraints {
            $0.centerY.equalTo(rankingNumLabel)
            $0.leading.equalTo(rankingNumLabel.snp.trailing).offset(ScreenUtils.setWidth(value: 24))
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 40))
        }
        profileImageView.layer.cornerRadius = ScreenUtils.setWidth(value: 20)
        profileImageView.clipsToBounds = true
        userNameLabel.snp.makeConstraints {
            $0.centerY.equalTo(rankingNumLabel)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(ScreenUtils.setWidth(value: 12))
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
        }
        userScoreLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 20))
            $0.centerY.equalTo(rankingNumLabel)
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
        }
        
        if isBlocking {
            self.profileImageView.alpha = 0.4
            self.rankingNumLabel.alpha = 0.4
            self.userNameLabel.alpha = 0.4
            self.userScoreLabel.alpha = 0.4
        } else {
            self.profileImageView.alpha = 1
            self.rankingNumLabel.alpha = 1
            self.userNameLabel.alpha = 1
            self.userScoreLabel.alpha = 1
        }
    }
    
    private var rankingNumLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
    }
    private var profileImageView = UIImageView()
    private var userNameLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
    }
    private var userScoreLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
    }

}
