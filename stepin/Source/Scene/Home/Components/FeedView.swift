import Foundation
import UIKit
import SDSKit
import SnapKit

public class FeedView: UIView {
    var commentCompletion: (() -> Void)?
    var likeButtonCompletion: ((Bool) -> Void)?
    var moreButtonCompletion: (() -> Void)?
    
    var likeCount: Int = 0
    var commentCount: Int = 0
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public init() {
        super.init(frame: .zero)
        self.setLayout()
        self.addTargetToButton()
    }
    
    func bindData(commentCnt: Int,
                  isCommentEnabled: Bool,
                  likeCnt: Int,
                  isLiked: Bool) {
        self.likeCount = likeCnt
        self.commentCount = commentCnt
        if !isCommentEnabled {
            self.commentButton.isHidden = true
            self.commentCountLabel.isHidden = true
        }
        if commentCnt == 0 {
            commentCountLabel.isHidden = true
        }
        if likeCnt == 0 {
            likeCountLabel.isHidden = true
        }
        self.setCommentCount(count: roundCount(value: self.commentCount))
        self.setLikeCount(count: roundCount(value: self.likeCount))
        self.likeButton.isSelected = isLiked
        
    }
    
    func roundCount(value: Int) -> String{
        if value >= 1000 {
            let returnValue = Int(value / 1000)
            return String(returnValue)
        } else {
            return String(value)
        }
    }
    
    internal func updateButtonData(likeCnt: Int,
                                   commentsCnt: Int) {
        self.likeCountLabel.text = roundCount(value: likeCnt)
        self.commentCountLabel.text = roundCount(value: commentsCnt)
    }
    
    private func setLayout() {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.layer.cornerRadius = 25.adjusted
        blurView.clipsToBounds = true
        
        self.addSubview(blurView)
        blurView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        self.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(8.adjusted)
        }
        
        let viewArr = [likeButton, likeCountLabel, commentButton, commentCountLabel, meatBallButton]
        
        viewArr.forEach {
            self.stackView.addArrangedSubview($0)
        }
    }
    
    public func setCommentCount(count: String) {
        self.commentCountLabel.text = count
    }
    
    public func setLikeCount(count: String) {
        self.likeCountLabel.text = count
    }
    
    public func isCommentHidden() {
        self.commentButton.isHidden = true
        self.commentCountLabel.isHidden = true
    }
    
    public func commentButtonSelectedToggle() {
        self.commentButton.isSelected.toggle()
    }
    
    public func likeButtonSelectedToggle() {
        self.likeButton.isSelected.toggle()
    }
    
    
    private func addTargetToButton() {
        self.commentButton.addTarget(self,
                                      action: #selector(didCommentButtonTapped),
                                      for: .touchUpInside)
        self.likeButton.addTarget(self,
                                   action: #selector(didLikeButtonTapped),
                                   for: .touchUpInside)
        self.meatBallButton.addTarget(self,
                                  action: #selector(didMoreButtonTapped),
                                  for: .touchUpInside)
    }
    

    @objc private func didCommentButtonTapped() {
        guard let completion = self.commentCompletion else {return}
        completion()
    }
    
    @objc private func didLikeButtonTapped() {
        guard let completion = self.likeButtonCompletion else {return}
        completion(self.likeButton.isSelected)
        likeButtonSelectedToggle()
    }
    
    @objc private func didMoreButtonTapped() {
        guard let completion = self.moreButtonCompletion else {return}
        completion()
    }
    
    private let stackView: UIStackView = {
        var stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    public let likeButton: UIButton = {
        var button = UIButton()
        button.setImage(SDSIcon.icFloatingLikeDefault, for: .normal)
        button.setImage(SDSIcon.icFloatingLikeActive, for: .selected)
        return button
    }()
    
    private let likeCountLabel: UILabel = {
        var label = UILabel()
        label.font = SDSFont.caption2.font
        label.textColor = .PrimaryWhiteNormal
        label.textAlignment = .center
        return label
    }()
    
    public let commentButton: UIButton = {
        var button = UIButton()
        button.setImage(SDSIcon.icFloatingCommentsDefault, for: .normal)
        button.setImage(SDSIcon.icFloatingCommentsActive, for: .selected)
        return button
    }()
    
    private let commentCountLabel: UILabel = {
        var label = UILabel()
        label.font = SDSFont.caption2.font
        label.textColor = .PrimaryWhiteNormal
        label.textAlignment = .center
        return label
    }()
    
    public let meatBallButton: UIButton = {
        var button = UIButton()
        button.setImage(SDSIcon.icFloatingMeatballsDefault, for: .normal)
        return button
    }()
    
}
