import UIKit

class HomeNavigationBar: UIView {
    
    init() {
        super.init(frame: .zero)
        setLayout()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setLayout() {
        self.addSubviews([signupbutton, energyBar, notiButton, searchButton])
        energyBar.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.centerY.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 23))
        }
        searchButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 48))
        }
        notiButton.snp.makeConstraints {
            $0.trailing.equalTo(searchButton.snp.leading)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 48))
        }
        signupbutton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.centerY.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 23))
        }
        
        if !UserDefaults.standard.bool(forKey: UserDefaultKey.LoginStatus) {
            self.energyBar.isHidden = true
            self.signupbutton.isHidden = false
        } else {
            self.signupbutton.isHidden = true
        }
    }
    
    internal var energyBar = EnergyBar()
    internal var notiButton = UIButton().then {
        $0.setBackgroundImage(ImageLiterals.icNotiOn, for: .normal)
    }
    internal var searchButton = UIButton().then {
        $0.setBackgroundImage(ImageLiterals.icSearch, for: .normal)
    }
    internal var signupbutton = SignupButton()
}
