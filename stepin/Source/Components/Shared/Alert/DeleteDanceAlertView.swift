import UIKit
import SDSKit
import Foundation
import SnapKit
import Then
import Kingfisher

class DeleteDanceAlertView: BaseOKAlertView {

    override init() {
        super.init()
        setDeleteUserAlertLayout()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    
    private func setDeleteUserAlertLayout() {
        self.addSubviews([profileImageView, deleteLabel, descriptionLabel])
        alertContentView.snp.remakeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.equalTo(ScreenUtils.setWidth(value: 272))
            $0.height.equalTo(ScreenUtils.setWidth(value: 245))
        }
        profileImageView.snp.makeConstraints {
            $0.centerX.equalTo(alertContentView)
            $0.top.equalTo(alertContentView.snp.top).offset(ScreenUtils.setWidth(value: 24))
            $0.width.equalTo(ScreenUtils.setWidth(value: 24))
        }
        deleteLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(ScreenUtils.setWidth(value: 8))
            $0.width.equalTo(ScreenUtils.setWidth(value: 153))
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(descriptionLabel.snp.top).inset(ScreenUtils.setWidth(value: -16))
        }
        descriptionLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(alertContentView).inset(ScreenUtils.setWidth(value: 16))
            $0.bottom.equalTo(okButton.snp.top).inset(ScreenUtils.setWidth(value: -24))
        }
    }
    
    func setDeleteLabel(title: String) {
        if title == "1" {
            deleteLabel.text = "history_view_delete_button_title".localized() + " dance"
        } else {
            deleteLabel.text = "history_view_delete_button_title".localized() + " \(title) dances"
        }
    }
    
    private var profileImageView = UIImageView().then {
        $0.image = SDSIcon.icDelete
    }
    
    private var deleteLabel = UILabel().then {
        $0.font = .suitExtraBoldFont(ofSize: 20)
        $0.textColor = .stepinYellow
        $0.textAlignment = .center
        $0.text = "history_view_delete_button_title".localized()
    }
    private var descriptionLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
        $0.text = "history_view_delete_description".localized()
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
}
