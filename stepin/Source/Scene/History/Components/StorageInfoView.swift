import UIKit
import SDSKit
import SnapKit
import Then


class StorageInfoView: UIView {
    var deleteButtonTapCompletion: (() -> Void)?
    var selectAllButtonTapCompletion: ((Bool) -> Void)?
    
    init() {
        super.init(frame: .zero)
        setLayout()
        getTotalStorageSize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    @objc private func didDeleteButtonTap() {
        guard let completion = deleteButtonTapCompletion else {return}
        completion()
    }
    
    @objc private func didSelectAllButtonTap() {
        self.selectAllButton.isSelected.toggle()
    }
    
    private func getTotalStorageSize() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let attributes = try? fileManager.attributesOfFileSystem(forPath: documentsURL.path)
        let totalSize = (attributes?[.systemSize] as? Int64 ?? 0) / Int64(truncating: NSDecimalNumber(decimal: pow(10, 9)))
        let freeSize = (attributes?[.systemFreeSize] as? Int64 ?? 0) / Int64(truncating: NSDecimalNumber(decimal: pow(10, 9)))

        //10억 10^-9
        self.storageLabel.text = "\(totalSize - freeSize)/\(totalSize)GB"
        self.rightStorageLabel.text = "\(freeSize)GB"
        
        if freeSize <= 5 {
            self.rightStorageLabel.textColor = .SystemRed
            self.storageProgressBar.progressTintColor = .SystemRed
        }
        
        self.storageProgressBar.progress = Float(totalSize - freeSize) / Float(totalSize)
    }
    
    private func setLayout() {
        self.backgroundColor = .stepinBlack100
        self.addSubviews([storageLabel, storageProgressBar, rightStorageLabel, deleteButton, selectAllButton])
        storageLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.height.equalTo(ScreenUtils.setWidth(value: 15))
        }
        storageProgressBar.snp.makeConstraints {
            $0.leading.equalTo(storageLabel.snp.trailing).offset(ScreenUtils.setWidth(value: 8))
            $0.centerY.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 6))
            $0.width.equalTo(ScreenUtils.setWidth(value: 116))
        }
        rightStorageLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(storageProgressBar.snp.trailing).offset(ScreenUtils.setWidth(value: 8))
            $0.height.equalTo(ScreenUtils.setWidth(value: 15))
        }
        deleteButton.snp.makeConstraints {
            $0.centerY.equalTo(storageLabel)
            $0.trailing.equalToSuperview()
            $0.width.height.equalTo(48.adjusted)
        }

        selectAllButton.snp.makeConstraints {
            $0.centerY.equalTo(storageLabel)
            $0.trailing.equalToSuperview().inset(16.adjusted)
            $0.width.equalTo(76.adjusted)
            $0.height.equalTo(16)
        }
        selectAllButton.isHidden = true
        
    }
    
    private var storageLabel = UILabel().then {
        $0.font = .suitRegularFont(ofSize: 12)
        $0.textColor = .stepinWhite100
    }
    private var storageProgressBar = UIProgressView(progressViewStyle: .default).then {
        $0.trackTintColor = .stepinWhite40
        $0.progressTintColor = .stepinWhite100
    }
    private var rightStorageLabel = UILabel().then {
        $0.font = .suitRegularFont(ofSize: 12)
        $0.textColor = .stepinWhite40
    }
    
    var deleteButton = UIButton().then {
        $0.setImage(ImageLiterals.icDelete, for: .normal)
    }
    var selectAllButton = UIButton().then {
        $0.setTitle("history_view_select_all_button_title".localized(), for: .normal)
        $0.titleLabel?.font = SDSFont.caption2.font
        $0.setTitleColor(.PrimaryWhiteNormal, for: .normal)
        $0.setImage(SDSIcon.icRadioDeselect, for: .normal)
        $0.setImage(SDSIcon.icRadioCheck, for: .selected)
        $0.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 8)
        $0.isSelected = false
    }

}
