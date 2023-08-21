import UIKit
import SDSKit
import Then
import SnapKit

class EditDanceScoreInfoHeaderView: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    init() {
        super.init(frame: .zero)
        setLayout()
        setProfileData()
    }
    private func setProfileData() {
        if (UserDefaults.standard.string(forKey: UserDefaultKey.profileUrl) ?? "") == "" {
            self.profileImageView.image = SDSIcon.icDefaultProfile
        } else {
            guard let url = URL(string: UserDefaults.standard.string(forKey: UserDefaultKey.profileUrl) ?? "") else {return}
            self.profileImageView.kf.setImage(with: url)
        }
        self.userNameLabel.text = UserDefaults.standard.string(forKey: UserDefaultKey.name)
    }
    
    internal func setScoreStatesetScoreState(scoreState: String) {
        self.scoreStateLabel.text = scoreState
    }
    internal func setScore(score: Float) {
        DispatchQueue.main.async {
            self.scorePercentLabel.text = "\(score) %"
        }
    }
    
    private func setLayout() {
        self.backgroundColor = .stepinBlack100
        self.addSubview(contentBackgroundView)
        contentBackgroundView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        contentBackgroundView.addSubviews([profileImageView, userNameLabel, scoreStateLabel, scorePercentLabel])
        self.profileImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 30))
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 40))
        }
        profileImageView.layer.cornerRadius = ScreenUtils.setWidth(value: 18)
        profileImageView.clipsToBounds = true
        
        self.userNameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(ScreenUtils.setWidth(value: 11))
            $0.centerY.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
        }
        
        self.scorePercentLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 30))
            $0.centerY.equalTo(profileImageView)
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
        }
        self.scoreStateLabel.snp.makeConstraints {
            $0.trailing.equalTo(scorePercentLabel.snp.leading).offset(ScreenUtils.setWidth(value: -20))
            $0.centerY.equalTo(profileImageView)
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
        }
    }
    private var contentBackgroundView = UIView().then {
        $0.backgroundColor = .stepinWhite20
    }
    private var profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    private var userNameLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
    }
    private var scoreStateLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
    }
    private var scorePercentLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
    }
}
