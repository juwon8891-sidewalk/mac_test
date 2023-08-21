import UIKit
import SDSKit
import SnapKit
import Then

class SSRDefaultView: UIView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: .zero)
        self.setLayout()
    }
    
    internal func setData(profilePath: String,
                          userName: String) {
        DispatchQueue.main.async {
            if profilePath == ""{
                self.profileImageView.image = SDSIcon.icDefaultProfile
            } else {
                guard let profileUrl = URL(string: profilePath) else {return}
                self.profileImageView.kf.setImage(with: profileUrl)
            }
            self.stepinIdLabel.text = userName
        }
        
    }
    
    private func setLayout() {
        self.addSubviews([profileImageView, stepinIdLabel])
        profileImageView.snp.makeConstraints {
            $0.bottom.leading.equalToSuperview().inset(ScreenUtils.setWidth(value: 12))
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 40))
        }
        self.profileImageView.layer.cornerRadius = ScreenUtils.setWidth(value: 20)
        self.profileImageView.clipsToBounds = true
        
        stepinIdLabel.snp.makeConstraints {
            $0.centerY.equalTo(profileImageView)
            $0.leading.equalTo(profileImageView.snp.trailing).inset(ScreenUtils.setWidth(value: -12))
            $0.height.equalTo(ScreenUtils.setWidth(value: 17))
        }
    }
    
    private var profileImageView = UIImageView()
    private var stepinIdLabel = UILabel().then {
        $0.font = .suitRegularFont(ofSize: 16)
        $0.textColor = .stepinWhite100
    }
}
