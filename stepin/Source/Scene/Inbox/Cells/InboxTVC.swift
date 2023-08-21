import UIKit
import SDSKit
import SnapKit
import Then
import Kingfisher

class InboxTVC: UITableViewCell {
    static let identifier: String = "InboxTVC"
    var profileImageTapCompletion: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.descriptionLabel.text = ""
        self.profileImageView.image = nil
        self.timeStampLabel.text = ""
        self.followButton.removeFromSuperview()
        self.energyButton.removeFromSuperview()
    }
    
    internal func setData(userNickName: String,
                          description: String,
                          profilePath: String,
                          followed: Bool,
                          energy: Int,
                          musicName: String,
                          rank: Int,
                          type: String,
                          createdAt: String) {
        if profilePath == "" {
            self.profileImageView.image = SDSIcon.icDefaultProfile
        } else {
            guard let url = URL(string: profilePath) else {return}
            self.profileImageView.kf.setImage(with: url)
        }
        self.setOriginLayout()
        self.setInboxCellLayout(type: type,
                                followed: followed,
                                energy: energy)
        self.getInboxString(type: type,
                            userName: userNickName,
                            musicName: musicName,
                            rank: rank,
                            content: description)
        self.setTimeStampLabel(createdAt: createdAt)
    }
    private func setTimeStampLabel(createdAt: String) {
        let todayDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let createDate = dateFormatter.date(from: createdAt)
        self.timeStampLabel.text = todayDate.convertTimeStamp(date: Int(createDate?.timeIntervalSince1970 ?? 0))
    }
    
    private func setInboxCellLayout(type: String,
                                    followed: Bool,
                                    energy: Int) {
        switch type {
        case InboxType.achievement, InboxType.superShortForm:
            self.setEnergyButtonLayout()
            self.energyButton.setTitle("  \(energy)", for: .normal)
        case InboxType.followType:
            self.setFollowButtonLayout()
            self.followButton.isSelected = followed
            if followed {
                self.followButton.backgroundColor = .stepinWhite100
            } else {
                self.followButton.backgroundColor = .stepinBlack100
            }
        default:
            break
        }
    }
    
    private func getInboxString(type: String,
                                userName: String = "",
                                musicName: String = "",
                                rank: Int = 0,
                                content: String = "") {
        var defaultString = ""
        switch type {
        case InboxType.followType:
            defaultString = "\(userName) " + "inbox_follow_description".localized()
        case InboxType.commentType:
            defaultString = "\(userName) " + "inbox_comment_description".localized()
        case InboxType.replyType:
            defaultString = "\(userName) " + "inbox_reply_description".localized()
        case InboxType.likeVideo:
            defaultString = "\(userName) " + "inbox_like_description".localized()
        case InboxType.likeComment:
            defaultString = "\(userName) " + "inbox_like_comment_description".localized()
        case InboxType.rankIn:
            if rank == 1 {
                defaultString = "\(userName) " + "your \(musicName)" + "inbox_rank_in_first_description".localized()
            }
            else if rank == 2 {
                defaultString = "\(userName) " + "your \(musicName)" + "inbox_rank_in_second_description".localized()
            } else {
                defaultString = "\(userName) " + "your \(musicName)" + "inbox_rank_in_third_description".localized()
            }
        case InboxType.rankOut:
            if rank == 2 {
                defaultString = "\(userName) " + "your \(musicName)" + "inbox_rank_out_second_description".localized()
            } else {
                defaultString = "\(userName) " + "your \(musicName)" + "inbox_rank_out_third_description".localized()
            }
        case InboxType.superShortForm:
            defaultString = content
        case InboxType.achievement:
            defaultString = content
            //바로 주는거
            break
        default:
            defaultString = content
            break
        }
        if userName.count > 0 {
            print(userName, defaultString)
            let attributedString = defaultString.setAttributeString(range: .init(location: 0, length: userName.count),
                                                                font: .suitExtraBoldFont(ofSize: 12),
                                                                textColor: .stepinWhite100)
            self.descriptionLabel.attributedText = attributedString
        }
    }
    
    @objc private func didProfileImageViewTapped() {
        guard let completion = profileImageTapCompletion else {return}
        completion()
    }
    
    private func setFollowButtonLayout() {
        self.contentView.addSubview(self.followButton)
        followButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.height.equalTo(ScreenUtils.setWidth(value: 30))
            $0.width.equalTo(ScreenUtils.setWidth(value: 114))
            $0.centerY.equalToSuperview()
        }
    }
    
    private func setEnergyButtonLayout() {
        self.contentView.addSubview(self.energyButton)
        energyButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.height.equalTo(ScreenUtils.setWidth(value: 30))
            $0.width.equalTo(ScreenUtils.setWidth(value: 114))
            $0.centerY.equalToSuperview()
        }
    }
    
    private func setOriginLayout() {
        self.backgroundColor = .stepinBlack100
        self.contentView.addSubviews([profileImageView, descriptionLabel, timeStampLabel])
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(ScreenUtils.setWidth(value: 20))
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 36))
        }
        profileImageView.layer.cornerRadius = ScreenUtils.setWidth(value: 18)
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        descriptionLabel.snp.makeConstraints {
            $0.leading.equalTo(self.profileImageView.snp.trailing).offset(12)
            $0.top.equalTo(profileImageView.snp.top)
            $0.width.equalTo(ScreenUtils.setWidth(value: 156))
        }
        timeStampLabel.snp.makeConstraints {
            $0.top.equalTo(self.descriptionLabel.snp.bottom)
            $0.leading.equalTo(self.descriptionLabel.snp.leading)
            $0.bottom.equalToSuperview().inset(ScreenUtils.setWidth(value: 20))
        }
    }
    
    private lazy var profileImageView = UIImageView().then {
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                       action: #selector(didProfileImageViewTapped)))
    }
    private let descriptionLabel = UILabel().then {
        $0.font = .suitRegularFont(ofSize: 12)
        $0.textColor = .stepinWhite100
        $0.numberOfLines = 0
    }
    private let timeStampLabel = UILabel().then {
        $0.font = .suitRegularFont(ofSize: 12)
        $0.textColor = .stepinWhite40
    }
    private lazy var energyButton = UIButton().then {
        $0.setImage(ImageLiterals.icEnergy, for: .normal)
        $0.setTitle("", for: .normal)
        $0.titleLabel?.font = .suitExtraBoldFont(ofSize: 12)
        $0.setTitleColor(.stepinWhite100, for: .normal)
        $0.layer.borderColor = UIColor.stepinWhite100.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 15
    }
    private lazy var followButton = UIButton().then {
        $0.setTitle("inbox_follow_button_title".localized(), for: .normal)
        $0.setTitle("inbox_following_button_title".localized(), for: .selected)
        $0.setTitleColor(.stepinWhite100, for: .normal)
        $0.setTitleColor(.stepinBlack100, for: .selected)
        $0.titleLabel?.font = .suitExtraBoldFont(ofSize: 12)
        $0.layer.borderColor = UIColor.stepinWhite100.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 15
    }

}
