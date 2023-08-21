import UIKit
import SnapKit
import Then
import SDSKit

class VideoDeleteBottomBar: UIView {
    
    var cancelButtonTapCompletion: ( () -> Void)?
    var deleteButtonTapCompletion: ( () -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setLayout() {
        self.backgroundColor = .PrimaryBlackNormal
        self.addSubviews([cancelButton, deleteButton])
        cancelButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16.adjusted)
            $0.height.equalTo(48)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(160.adjusted)
        }
        deleteButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(48)
            $0.width.equalTo(160.adjusted)
            $0.centerY.equalToSuperview()
        }
    }

    lazy var cancelButton = SDSSmallButton(type: .line).then {
        $0.setTitle("alert_report_cancel".localized(), for: .normal)
        $0.setTitleColor(.PrimaryWhiteNormal, for: .normal)
        $0.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
    }
    
    lazy var deleteButton = SDSSmallButton(type: .alternative).then {
        $0.setTitle("history_view_delete_button_title".localized(), for: .normal)
        $0.setTitleColor(.PrimaryWhiteDisabled, for: .normal)
        $0.addTarget(self, action: #selector(deleteButtonDidTap), for: .touchUpInside)
    }
    
    @objc func deleteButtonDidTap() {
        guard let completion = deleteButtonTapCompletion else {return}
        completion()
    }
    @objc func cancelButtonDidTap() {
        guard let completion = cancelButtonTapCompletion else {return}
        completion()
    }
}
