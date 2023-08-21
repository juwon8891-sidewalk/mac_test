import UIKit
import SDSKit
import Then
import SnapKit
import Kingfisher

class ProfileInfoView: UIView {
    var moreTappedCompletion: ((Bool) -> Void)?
    var profileCompletion: (() -> Void)?
    
    private var resultString: String = ""
    private var isCanTapped: Bool = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    init() {
        super.init(frame: .zero)
    }
    internal func setRefreshView() {
        self.contentTextView.text = ""
        self.contentTextView.snp.removeConstraints()
        self.profileImageView.snp.removeConstraints()
        self.userNameLabel.snp.removeConstraints()
        self.moreButton.snp.removeConstraints()
    }
    
    internal func setData(imagePath: String,
                          name: String,
                          hashTags: [Hashtag],
                          content: String) {
        if imagePath == "" {
            self.profileImageView.image = SDSIcon.icDefaultProfile
        } else {
            guard let url = URL(string: imagePath) else {return}
            self.profileImageView.kf.setImage(with: url)
        }
        self.userNameLabel.text = name
        
        setLayout()
        setContentViewText(hashTag: hashTags, content: content)
        addTargetButton()
    }
    
    private func addTargetButton() {
        self.moreButton.addTarget(self,
                                  action: #selector(didMoreButtonTapped),
                                  for: .touchUpInside)
        self.contentTextView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                         action: #selector(didTextViewTapped)))
    }
    @objc private func didTextViewTapped() {
        if self.contentTextView.numberOfLine() > 1 && self.moreButton.isHidden {
            self.contentTextView.isScrollEnabled = false
            self.moreButton.isHidden = false
            contentTextView.snp.remakeConstraints {
                $0.top.equalTo(self.profileImageView.snp.bottom).offset(8.adjusted)
                $0.leading.equalTo(self.profileImageView.snp.leading)
                $0.height.equalTo(15.adjusted)
                $0.trailing.equalTo(moreButton.snp.leading)
            }
            guard let completion = moreTappedCompletion else {return}
            completion(false)
        }
    }
    
    @objc private func didMoreButtonTapped() {
        if self.contentTextView.numberOfLine() > 1 {
            self.contentTextView.isScrollEnabled = true
            self.moreButton.isHidden = true
            
            UIView.animate(withDuration: 0.5, delay: 0) { [weak self] in
                guard let strongSelf = self else {return}
                strongSelf.contentTextView.snp.remakeConstraints {
                    $0.top.equalTo(strongSelf.profileImageView.snp.bottom).offset(8.adjusted)
                    $0.leading.equalTo(strongSelf.profileImageView.snp.leading)
//                    $0.bottom.equalToSuperview()
                    $0.trailing.equalToSuperview()
                }
                strongSelf.layoutIfNeeded()
            }
            guard let completion = self.moreTappedCompletion else {return}
            completion(true)
        }
    }
    
    private func setContentViewText(hashTag: [Hashtag], content: String){
        var hashTagString: String = ""
        var contentString: String = content
        var resultString: String = ""
        
        //hashTag String 생성
        for tag in hashTag {
            hashTagString += "#\(tag.keyword)"
        }
        
        //hashTag 없을때
        //바로 그냥 띄워줌
        if hashTagString.count == 0 {
            resultString = content
            self.contentTextView.attributedText = NSAttributedString(resultString.setAttributeString(textColor: .PrimaryWhiteNormal,
                                                                                                     font: SDSFont.caption2.font))
        }
        else if hashTagString.count > 0 {
            let newContentString = "\n\n\(contentString)"
            let attributedHashTagString = NSMutableAttributedString(hashTagString.setAttributeString(textColor: .PrimaryWhiteNormal,
                                                                                                     font: SDSFont.caption1.font))
            let attributedContentString = NSAttributedString(newContentString.setAttributeString(textColor: .PrimaryWhiteNormal,
                                                                                                 font: SDSFont.caption2.font))
            attributedHashTagString.append(attributedContentString)
            self.contentTextView.attributedText = attributedHashTagString
        }
        
        print(self.contentTextView.numberOfLine(), "텍스트 줄 수 ")
        if self.contentTextView.numberOfLine() > 1 {
            DispatchQueue.main.async {
                self.moreButton.isHidden = false
            }
        }
        
    }
    
    private func setLayout() {
        self.addSubviews([profileImageView, userNameLabel, contentTextView, moreButton])
        
        self.profileImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.width.height.equalTo(40.adjusted)
        }
        profileImageView.layer.cornerRadius = 20.adjusted
        profileImageView.clipsToBounds = true
        
        self.userNameLabel.snp.makeConstraints {
            $0.centerY.equalTo(profileImageView)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(12.adjusted)
        }
        contentTextView.snp.makeConstraints {
            $0.top.equalTo(self.profileImageView.snp.bottom).offset(8.adjusted)
            $0.leading.equalTo(self.profileImageView.snp.leading)
            $0.height.equalTo(15.adjusted)
        }
        
        moreButton.snp.makeConstraints {
            $0.leading.equalTo(contentTextView.snp.trailing)
            $0.top.equalTo(contentTextView.snp.top)
            $0.trailing.equalToSuperview()
            $0.width.equalTo(50.adjusted)
            $0.height.equalTo(15.adjusted)
        }
        moreButton.isHidden = true
        
    }
    @objc private func didProfileImageTapped() {
        guard let completion = profileCompletion else {return}
        completion()
    }
    
    internal lazy var profileImageView = UIImageView().then {
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                       action: #selector(didProfileImageTapped)))
        $0.isUserInteractionEnabled = true
    }
    var userNameLabel = UILabel().then {
        $0.font = SDSFont.body.font
        $0.textColor = .PrimaryWhiteNormal
    }
    var contentTextView = UITextView().then {
        $0.backgroundColor = .clear
        $0.isEditable = false
        $0.isScrollEnabled = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.textAlignment = .left
        $0.textContainerInset = .zero
        $0.font = SDSFont.caption2.font
        $0.textContainer.lineBreakMode = .byTruncatingTail
        $0.textContainer.heightTracksTextView = true
        $0.textColor = .PrimaryWhiteNormal
    }
    private var moreButton = UIButton().then {
        $0.setTitle("profile_view_more_text".localized(), for: .normal)
        $0.titleLabel?.font = SDSFont.caption1.font
        $0.setTitleColor( .PrimaryWhiteNormal, for: .normal)
    }
}
