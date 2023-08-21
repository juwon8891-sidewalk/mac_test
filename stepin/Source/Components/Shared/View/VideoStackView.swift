import UIKit
import Then
import SnapKit

class VideoStackView: UIStackView {
    var commentCompletion: (() -> Void)?
    var likeButtonCompletion: ((Bool) -> Void)?
    var moreButtonCompletion: (() -> Void)?
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: .zero)
        setViewConfig()
        addTargetToButton()
    }
    
    private func addTargetToButton() {
        self.commentsButton.addTarget(self, action: #selector(didCommentButtonTapped), for: .touchUpInside)
        self.heartButton.addTarget(self, action: #selector(didLikeButtonTapped), for: .touchUpInside)
        self.moreButton.addTarget(self, action: #selector(didMoreButtonTapped), for: .touchUpInside)
    }
    

    @objc private func didCommentButtonTapped() {
        guard let completion = self.commentCompletion else {return}
        completion()
    }
    
    @objc private func didLikeButtonTapped() {
        guard let completion = self.likeButtonCompletion else {return}
        completion(self.heartButton.isSelected)
        changeHeartButton()
        print(heartButton.isSelected)
    }
    
    @objc private func didMoreButtonTapped() {
        guard let completion = self.moreButtonCompletion else {return}
        completion()
    }
    
    internal func setButtonData(likeCnt: Int,
                                commentsCnt: Int,
                                isLiked: Bool,
                                isCommentEnabled: Bool) {
        if !isCommentEnabled {
            self.commentsButton.isHidden = true
        }
        self.setHeartButtonText(text: roundCount(value: likeCnt))
        self.setCommentButtonText(text: roundCount(value: commentsCnt))
        self.heartButton.isSelected = isLiked
        changeHeartButton()
    }
    
    internal func updateButtonData(likeCnt: Int,
                                      commentsCnt: Int) {
        self.setHeartButtonText(text: roundCount(value: likeCnt))
        self.setCommentButtonText(text: roundCount(value: commentsCnt))
    }
    
    private func roundCount(value: Int) -> String{
        if value >= 1000 {
            let returnValue = Int(value / 1000)
            return String(returnValue)
        } else {
            return String(value)
        }
    }
    
    private func setViewConfig() {
        self.axis = .vertical
        self.spacing = 0
        self.distribution = .equalSpacing
        self.setHeartButtonConfig()
        self.setCommentButtonConfig()
        self.addArrangeSubViews([heartButton, commentsButton, moreButton])
        heartButton.titleLabel?.textAlignment = .center
        commentsButton.titleLabel?.textAlignment = .center
    }
    
    private func changeHeartButton() {
        var config = self.heartButton.configuration
        if self.heartButton.isSelected {
            config?.image = ImageLiterals.icFillHeart
        } else {
            config?.image = ImageLiterals.icGrayUnfillHeart
        }
        self.heartButton.configuration = config
    }
    
    private func setHeartButtonConfig() {
        var config = UIButton.Configuration.plain()
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = .clear
        config.imagePadding = ScreenUtils.setWidth(value: 3)
        config.image = ImageLiterals.icGrayUnfillHeart
        config.imagePlacement = .top
        config.titleAlignment = .center
        heartButton.configuration = config
    }
    
    private func setHeartButtonText(text: String) {
        var config = heartButton.configuration
        config?.attributedTitle = text.setAttributeString(textColor: .stepinWhite100, font: .suitRegularFont(ofSize: 12))
        self.heartButton.configuration = config
    }
    
    private func setCommentButtonConfig() {
        var config = UIButton.Configuration.plain()
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = .clear
        config.image = ImageLiterals.icComments
        config.imagePlacement = .top
        config.titleAlignment = .center
        commentsButton.configuration = config
    }
    
    private func setCommentButtonText(text: String) {
        var config = commentsButton.configuration
        config?.attributedTitle = text.setAttributeString(textColor: .stepinWhite100, font: .suitRegularFont(ofSize: 12))
        self.commentsButton.configuration = config
    }

    internal var heartButton = UIButton()
    private var commentsButton = UIButton()
    private var moreButton = UIButton().then {
        $0.setImage(ImageLiterals.icMore, for: .normal)
    }
    
    
}
