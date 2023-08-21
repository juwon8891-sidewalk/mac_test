import UIKit
import SDSKit
import SnapKit
import Then
import RxSwift
import RxCocoa
//버튼 디폴트 색상 수정
//셀렉트 될때가 블락이되는건지를 확인
//pull to update 구현


class BlockUserTVC: UITableViewCell {
    var blockButtonCompletion: ((Int, Bool) -> Void)?
    static let identifier: String = "BlockUserTVC"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.profileImageView.image = nil
        self.userNameLabel.text = nil
    }

    private func didButtonTapped() {
        if self.blockButton.isSelected {
            blockButton.backgroundColor = .stepinWhite40
            blockButton.layer.borderWidth = 0
        } else {
            blockButton.backgroundColor = .stepinBlack100
            blockButton.layer.borderColor = UIColor.stepinWhite100.cgColor
            blockButton.layer.borderWidth = 1
        }
    }
    
    internal func setData(profilePath: String,
                          stepinId: String,
                          isBlocked: Bool,
                          tag: Int) {
        self.tag = tag
        if profilePath == "" {
            self.profileImageView.image = SDSIcon.icDefaultProfile
        } else {
            guard let url = URL(string: profilePath) else {return}
            self.profileImageView.kf.setImage(with: url)
        }
        
        self.userNameLabel.text = stepinId
        self.blockButton.isSelected = isBlocked
        self.setLayout()
        self.didButtonTapped()
    }

    private func setLayout() {
        self.selectionStyle = .none
        self.backgroundColor = .stepinBlack100
        self.contentView.addSubviews([profileImageView, userNameLabel, blockButton])
        profileImageView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(ScreenUtils.setWidth(value: 10))
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 40))
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
        }
        profileImageView.layer.cornerRadius = ScreenUtils.setWidth(value: 40) / 2
        profileImageView.clipsToBounds = true
        
        userNameLabel.snp.makeConstraints {
            $0.centerY.equalTo(profileImageView)
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
            $0.leading.equalTo(profileImageView.snp.trailing).offset(ScreenUtils.setWidth(value: 12))
        }
        
        blockButton.snp.makeConstraints {
            $0.centerY.equalTo(profileImageView)
            $0.height.equalTo(ScreenUtils.setWidth(value: 30))
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.width.equalTo(ScreenUtils.setWidth(value: 72))
        }
        blockButton.layer.cornerRadius = ScreenUtils.setWidth(value: 15)
        self.blockButton.addTarget(self, action: #selector(didBlockButtonTapped), for: .touchUpInside)
    }
    
    @objc private func didBlockButtonTapped() {
        guard let completion = blockButtonCompletion else {return}
        completion(self.tag, blockButton.isSelected)
    }
    
    private var profileImageView = UIImageView()
    private var userNameLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
    }
    private var blockButton = UIButton().then {
        $0.backgroundColor = .stepinWhite40
        $0.titleLabel?.font = .suitRegularFont(ofSize: 12)
        $0.setTitle("manageblock_unblock_button_title".localized(), for: .selected)
        $0.setTitleColor(.stepinWhite100, for: .selected)
        $0.setTitle("manageblock_release_button_title".localized(), for: .normal)
        $0.setTitleColor(.stepinWhite100, for: .normal)
    }
}
