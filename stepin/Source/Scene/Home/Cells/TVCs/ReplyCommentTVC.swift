import UIKit
import SDSKit
import SkeletonView

class ReplyCommentTVC: UITableViewCell {
    static let identifier: String = "ReplyCommentTVC"
    private var comment: String = ""
    var likeButtonTapped: ((Int) -> Void)?
    var profileImageViewTapped: (() -> Void)?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addTargetButton()
    }
    

    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.dayAgoLabel.text = ""
        self.userNameLabel.text = ""
        self.commentLabel.text = ""
//        self.likeCountLabel.text = ""
        self.likeButton.isSelected = false
    }
    
    internal func setData(profilePath: String,
                          stepinId: String,
                          comment: String,
                          createdAt: String,
                          likeCount: Int,
                          isLiked: Bool) {
        self.comment = comment
        if profilePath == "" {
            self.profileImageView.image = SDSIcon.icDefaultProfile
        } else {
            guard let url = URL(string: profilePath) else {return}
            self.profileImageView.kf.setImage(with: url)
        }
        self.userNameLabel.text = stepinId
        self.commentLabel.text = comment
        self.dayAgoLabel.text = String(Date().convertTimeStamp(date: Date().convertStringToTimeStamp(date: createdAt)))
        if likeCount == 0 {
            self.likeCountLabel.isHidden = true
        } else {
            self.likeCountLabel.text = transformNumberOfLikes(likecount: likeCount)
            self.likeCountLabel.isHidden = false
        }
        
        self.likeButton.isSelected = isLiked
        setLayout()
        self.profileImageTouchEvent()

    }
    // 좋아요 및 댓글등 숫자개념, ex) 1000 -> 1k 같이 바꾸는 로직
    private func transformNumberOfLikes(likecount: Int) -> String {
        switch likecount {
        case 1 ..< 1000:
            return String(likecount)
        default:
            return String(likecount / 1000) + "K"
        }
    }
    private func addTargetButton() {
        self.likeButton.addTarget(self,
                                  action: #selector(didLikeButtonTapped),
                                  for: .touchUpInside)
    }
    private func profileImageTouchEvent() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(_:)))
        self.profileImageView.isUserInteractionEnabled = true
        self.profileImageView.addGestureRecognizer(tapGesture)
    }
    @objc func imageViewTapped(_ sender: UITapGestureRecognizer) {
        guard let completion = profileImageViewTapped else {return}
        completion()
    }
    
    @objc private func didLikeButtonTapped() {
        guard let completion = likeButtonTapped else {return}
        completion(likeButton.isSelected ? -1: 1)
        self.likeButton.isSelected = !self.likeButton.isSelected
    }
    
    private func setLayout() {
        self.backgroundColor = .stepinBlack100
        self.contentView.addSubviews([profileImageView, userNameLabel, likeCountLabel, commentLabel, dayAgoLabel, likeButton])
        profileImageView.snp.remakeConstraints {
            $0.top.equalToSuperview().offset(ScreenUtils.setWidth(value: 20))
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 56))
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 24))
        }
        profileImageView.layer.cornerRadius = ScreenUtils.setWidth(value: 12)
        profileImageView.clipsToBounds = true
        
        let userTitleWidth = userNameLabel.text?.size(withAttributes: [NSAttributedString.Key.font: userNameLabel.font as Any]).width ?? 0.0
        
        userNameLabel.snp.remakeConstraints {
            $0.top.equalTo(profileImageView.snp.top)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(ScreenUtils.setWidth(value: 12))
            $0.height.equalTo(ScreenUtils.setWidth(value: 15))
            $0.width.equalTo(ScreenUtils.setWidth(value: userTitleWidth))
        }
        
        
        let dayAgoTitleWidth = dayAgoLabel.text?.size(withAttributes: [NSAttributedString.Key.font: dayAgoLabel.font as Any]).width ?? 0.0
        
        dayAgoLabel.snp.remakeConstraints {
            $0.top.equalTo(userNameLabel.snp.top)
            $0.leading.equalTo(userNameLabel.snp.trailing).offset(ScreenUtils.setWidth(value: 4))
            $0.height.equalTo(ScreenUtils.setWidth(value: 15))
            $0.width.equalTo(ScreenUtils.setWidth(value: dayAgoTitleWidth))
        }
        
        likeCountLabel.snp.remakeConstraints {
            $0.centerY.equalTo(commentLabel)
            $0.trailing.equalTo(likeButton.snp.leading).inset(ScreenUtils.setWidth(value: -8))
        }
        
        likeButton.snp.remakeConstraints {
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 18))
            $0.centerY.equalTo(commentLabel)
            $0.width.equalTo(ScreenUtils.setWidth(value: 24))
            $0.height.equalTo(ScreenUtils.setWidth(value: 24))
        }


        commentLabel.snp.remakeConstraints {
            $0.bottom.equalToSuperview().inset(ScreenUtils.setWidth(value: 20))
            $0.leading.equalTo(userNameLabel)
            $0.trailing.equalTo(likeCountLabel.snp.leading).inset(ScreenUtils.setWidth(value: -20))
            $0.top.equalTo(userNameLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 4))
        }

        self.selectionStyle = .none
    }
    
     func skeletonAnimationPlay() {
        [profileImageView, userNameLabel, commentLabel, dayAgoLabel, likeCountLabel, likeButton].forEach {
            $0.isSkeletonable = true
            $0.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .stepinGray))
        }
    }
    
    private func comentLabelHeight(comment: String) -> CGFloat {
        return CGFloat(15 * (max(comment.count / 23, 1)))
    }
    
    private var profileImageView = UIImageView()
    private var userNameLabel = UILabel().then {
        $0.font = .suitExtraBoldFont(ofSize: 12)
        $0.textColor = .stepinWhite100
        $0.sizeThatFits($0.frame.size)
    }
    private var commentLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 12)
        $0.textAlignment = .left
        $0.numberOfLines = 0
        $0.textColor = .stepinWhite100
        $0.text = " "
    }
    private var dayAgoLabel = UILabel().then {
        $0.font = .suitLightFont(ofSize: 12)
        $0.textColor = .stepinWhite40
        $0.numberOfLines = 0
        $0.text = "\t"
    }
    private var likeCountLabel = UILabel().then {
        $0.font = .suitLightFont(ofSize: 12)
        $0.textColor = .stepinWhite100
        $0.textAlignment = .right
    }
    private var likeButton = UIButton().then {
        $0.setImage(SDSIcon.icHeartUnfill, for: .normal)
        $0.setImage(SDSIcon.icHeartFill, for: .selected)
    }

}
