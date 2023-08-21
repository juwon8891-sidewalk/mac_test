import UIKit
import SDSKit
import Then
import SnapKit
import Kingfisher

class ProfileImageVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLayoutConfig()
    }
    
    internal func setProfileImage(imagePath: String) {
        if imagePath == "" {
            self.profileImageView.image = SDSIcon.icDefaultProfile
        } else {
            guard let url = URL(string: imagePath) else {return}
            self.profileImageView.kf.setImage(with: url)
        }
    }
    
    private func setLayoutConfig() {
        self.view.backgroundColor = .stepinBlack100
        self.view.addSubviews([profileImageView, dismissButton])
        profileImageView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        profileImageView.contentMode = .scaleAspectFit
        dismissButton.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(ScreenUtils.setWidth(value: 8))
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 18))
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 24))
        }
        dismissButton.addTarget(self, action: #selector(didDismissButtondidTapped), for: .touchUpInside)
    }
    
    @objc private func didDismissButtondidTapped() {
        self.dismiss(animated: true)
        
    }
    
    private var profileImageView = UIImageView()
    private var dismissButton = UIButton().then {
        $0.setBackgroundImage(ImageLiterals.icWhiteX, for: .normal)
    }
    
}
