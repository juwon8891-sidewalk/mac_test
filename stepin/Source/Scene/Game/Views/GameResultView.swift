import UIKit
import SDSKit
import SnapKit
import Then

final class GameResultView: UIView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: .zero)
        self.setLayout()
    }
    
    func bindRankData(rank: String) {
        if rank.count == 3 {
            self.rankCountLabel.attributedText = rank.setAttributeString(range: .init(location: 1, length: rank.count - 1),
                                                                         font: SDSFont.shirkhandTitle.font.withSize(12),
                                                                         textColor: .PrimaryWhiteNormal)
        } else {
            self.rankCountLabel.attributedText = rank.setAttributeString(range: .init(location: 2, length: rank.count - 1),
                                                                         font: SDSFont.shirkhandTitle.font.withSize(12),
                                                                         textColor: .PrimaryWhiteNormal)
        }
    }
    
    func bindData(scoreData: [String],
                  score: String) {
        let perfectCount = Float((scoreData.filter { $0 == "Perfect"}).count)
        let greatCount = Float((scoreData.filter { $0 == "Great"}).count)
        let goodCount = Float((scoreData.filter { $0 == "Good"}).count)
        let badCount = Float((scoreData.filter { $0 == "Bad"}).count)
        
        self.perfectInfoView.bindText(scoreState: "Perfect",
                                      scorePercent: " \(Int((perfectCount / Float(scoreData.count)) * 100)) %")
        self.greatInfoView.bindText(scoreState: "Great",
                                    scorePercent: " \(Int((greatCount / Float(scoreData.count)) * 100)) %")
        self.goodInfoView.bindText(scoreState: "Good",
                                   scorePercent: " \(Int((goodCount / Float(scoreData.count)) * 100)) %")
        self.badInfoView.bindText(scoreState: "Bad",
                                  scorePercent: " \(Int((badCount / Float(scoreData.count)) * 100)) %")
        self.setDefaultData()
    }
    
    func setDefaultData() {
        self.navigationBar.setTitle(title: Date().toString(dateFormat: "yyyy.MM.dd"))
        self.gameEndTimeLabel.text = Date().toString(dateFormat: "HH:mm")
        self.userNameLabel.text = UserDefaults.identifierName
        if UserDefaults.profileUrl == "profileUrl" {
            self.profileImageView.image = SDSIcon.icDefaultProfile
        } else {
            if let url = URL(string: UserDefaults.profileUrl) {
                self.profileImageView.kf.setImage(with: url)
            }
        }
    }
     
    private func setLayout() {
        self.addSubviews([backgroundImageView, navigationBar, gameEndTimeLabel, profileImageView, userNameLabel, scoreHeaderView, stackView, continueButton, rankCountImageView, changeRankView])
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60.adjusted)
        }
        navigationBar.backButton.isHidden = true
        gameEndTimeLabel.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(20.adjusted)
            $0.centerX.equalToSuperview()
        }
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(gameEndTimeLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(110.adjusted)
        }
        profileImageView.layer.cornerRadius = 55.adjusted
        profileImageView.clipsToBounds = true
        
        userNameLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(profileImageView.snp.bottom).offset(20.adjusted)
        }
        scoreHeaderView.snp.makeConstraints {
            $0.top.equalTo(userNameLabel.snp.bottom).offset(40.adjusted)
            $0.leading.trailing.equalToSuperview().inset(30.adjusted)
        }
        stackView.snp.makeConstraints {
            $0.top.equalTo(scoreHeaderView.snp.bottom).offset(20.adjusted)
            $0.leading.trailing.equalToSuperview().inset(30.adjusted)
        }
        stackView.addArrangeSubViews([perfectInfoView, greatInfoView, goodInfoView, badInfoView])
        continueButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(20.adjusted)
            $0.leading.trailing.equalToSuperview().inset(88.adjusted)
            $0.height.equalTo(48.adjusted)
        }
        
        rankCountImageView.snp.makeConstraints {
            $0.centerY.equalTo(self.profileImageView)
            $0.trailing.equalTo(profileImageView.snp.leading).inset(-20.adjusted)
            $0.width.equalTo(70.adjusted)
            $0.height.equalTo(72.adjusted)
        }
        rankCountImageView.addSubview(rankCountLabel)
        rankCountLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
        changeRankView.snp.makeConstraints {
            $0.centerY.equalTo(profileImageView)
            $0.leading.equalTo(self.profileImageView.snp.trailing).offset(20.adjusted)
        }
    }
    
    
    let backgroundImageView = UIImageView(image: ImageLiterals.gameResultBackground).then {
        $0.contentMode = .scaleToFill
    }
    
    let navigationBar = SDSNavigationBar().then {
        $0.rightButton.setTitle("play_game_done_button_title".localized() + "  ", for: .normal)
        $0.rightButton.setTitleColor(.PrimaryWhiteNormal, for: .normal)
        $0.rightButton.titleLabel?.font = SDSFont.body.font
    }
    let gameEndTimeLabel = UILabel().then {
        $0.font = SDSFont.body2.font
        $0.textColor = .PrimaryWhiteNormal
        $0.textAlignment = .center
    }
    let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.borderColor = UIColor.PrimaryWhiteNormal.cgColor
        $0.layer.borderWidth = 4
    }
    let userNameLabel = UILabel().then {
        $0.font = SDSFont.h1.font
        $0.textColor = .PrimaryWhiteNormal
        $0.textAlignment = .center
    }
    let scoreHeaderView = ResultHeaderView()
    let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 40
        $0.distribution = .equalSpacing
    }
    let perfectInfoView = ScoreInfoView()
    let greatInfoView = ScoreInfoView()
    let goodInfoView = ScoreInfoView()
    let badInfoView = ScoreInfoView()
    let continueButton = SDSLargeButton(type: .line).then {
        $0.buttonState = .line
        $0.backgroundColor = .PrimaryBlackNormal
        $0.layer.borderColor = UIColor.PrimaryWhiteNormal.cgColor
        $0.setTitleColor(.PrimaryWhiteNormal, for: .normal)
        $0.setTitle("play_game_continue_button_title".localized(), for: .normal)
    }
    let rankCountImageView = UIImageView(image: ImageLiterals.rankBackground)
    let rankCountLabel = UILabel().then {
        $0.font = SDSFont.shirkhandTitle.font.withSize(30)
        $0.textColor = .PrimaryWhiteNormal
        $0.textAlignment = .center
    }
    let changeRankView = ChangeRankView()
    
}
