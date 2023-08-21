import UIKit

class SelectImageAlertView: BottomAlert {
    var profileCompletion: (() -> Void)?
    var backgroundCompletion: (() -> Void)?
    
    override init(size: CGSize) {
        super.init(size: size)
        setAlertLayout()
        viewConfig()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func viewConfig() {
        alertTitleLabel.text = "edit_mypage_bottom_alert_title".localized()
        profileImageSelect.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileSettingTapped)))
        backgroundVideoSelect.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundVideoTapped)))
    }
    
    
    @objc private func profileSettingTapped() {
        guard let completion = profileCompletion else {return}
        completion()
    }
    
    @objc private func backgroundVideoTapped() {
        guard let completion = backgroundCompletion else {return}
        completion()
    }
    
    private func setAlertLayout() {
        super.setLayout()
        self.contentView.addSubviews([profileImageSelect, backgroundVideoSelect])
        profileImageSelect.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 60))
        }
        backgroundVideoSelect.snp.makeConstraints {
            $0.top.equalTo(profileImageSelect.snp.bottom)
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 60))
        }
        self.contentView.snp.remakeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.alertTitleLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 20))
            $0.bottom.equalTo(self.cancelButton.snp.top)
        }
    }
    
    internal var profileImageSelect = BottomAlertCell(title: "edit_mypage_bottom_alert_profilepicture_title".localized())
    internal var backgroundVideoSelect = BottomAlertCell(title: "edit_mypage_bottom_alert_backgroundpicture_title".localized())
}
