import Foundation
import UIKit
import SDSKit
import Then
import SnapKit

class SuperShortFormMagnifyView: UIView {
    private var videoId: String = ""
    private var userId: String = ""
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: .zero)
        self.setLayout()
    }
    
    func bindData(data: Video) {
        self.navigationBar.setTitle(title: data.title)
        self.interactionView.bindData(commentCnt: data.commentCount,
                                      isCommentEnabled: data.allowComment,
                                      likeCnt: data.likeCount,
                                      isLiked: data.alreadyLiked)
        self.smallStepinButton.setData(imagePath: data.coverURL,
                                       danceId: data.danceID)
        self.profileInfoView.setData(imagePath: data.profileURL ?? "",
                                     name: data.identifierName,
                                     hashTags: data.hashtag,
                                     content: data.content)
        if data.openScore {
            self.scoreView.isHidden = false
            let percentValue = Double(Double(data.score)! / 100)
            let doubleValue = Double(data.score)!
            
            let strValue = String(format: "%.02f", doubleValue)
            self.scoreView.progressAnimation(duration: 0.8,
                                             value: percentValue)
            self.scoreView.setPercent(value: Double(strValue)!)
        } else {
            self.scoreView.isHidden = true
        }
        self.videoId = data.videoID
        self.userId = data.userID
    }
    
    private func setLayout() {
        self.addSubviews([topGradientView, bottomGradientView, navigationBar, interactionView, profileInfoView, smallStepinButton, scoreView])
        
        guard let window = UIWindow.key else {return}
        
        topGradientView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(80.adjusted)
        }
        
        bottomGradientView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(144.adjusted)
        }
        
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60.adjusted)
        }
        
        scoreView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(6.adjusted)
            $0.leading.equalToSuperview().offset(16)
            $0.width.height.equalTo(72.adjusted)
        }
        scoreView.clipsToBounds = true
        scoreView.layer.cornerRadius = 36.adjusted
        
        profileInfoView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(window.safeAreaInsets.bottom + 78)
            $0.leading.equalToSuperview().offset(16.adjusted)
            $0.width.equalTo(148.adjusted)
            $0.height.equalTo(63.adjusted)
        }
        
        smallStepinButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(window.safeAreaInsets.bottom + 78)
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(34.adjusted)
            $0.width.equalTo(102)
        }
        
        interactionView.snp.makeConstraints {
            $0.bottom.equalTo(smallStepinButton.snp.top).inset(-66.adjusted)
            $0.trailing.equalToSuperview().inset(16)
            $0.width.equalTo(48.adjusted)
        }
        setInteractionViewCompletion()
    }
    
    private func setInteractionViewCompletion() {
        self.interactionView.commentCompletion = { [weak self] in
            guard let strongSelf = self else {return}
            NotificationCenter.default.post(name: .homeCommentTapped,
                                            object: strongSelf.videoId,
                                            userInfo: nil)
        }
        self.interactionView.likeButtonCompletion = { [weak self] state in
            guard let strongSelf = self else {return}
            let likeState: Int = state == true ? -1: 1
            var likeCount: Int = 0
            
            if likeState == -1 {
                likeCount = strongSelf.interactionView.likeCount - 1
                strongSelf.interactionView.likeCount = likeCount
            } else {
                likeCount = strongSelf.interactionView.likeCount + 1
                strongSelf.interactionView.likeCount = likeCount
            }
            
            strongSelf.interactionView.setLikeCount(count: strongSelf.interactionView.roundCount(value: likeCount))
            NotificationCenter.default.post(name: .homeLikeTapped,
                                            object: [strongSelf.videoId, String(likeState)],
                                            userInfo: nil)
        }
        
        self.interactionView.moreButtonCompletion = { [weak self] in
            guard let strongSelf = self else {return}
            NotificationCenter.default.post(name: .homeMoreTapped,
                                            object: [strongSelf.videoId, strongSelf.userId],
                                            userInfo: nil)
        }
    }
    
    let topGradientView = UIView().then {
        $0.addGradient(size: .init(width: UIScreen.main.bounds.width,
                                   height: 80.adjusted),
                       colors: [UIColor.PrimaryBlackNormal.withAlphaComponent(0.5).cgColor,
                                UIColor.clear.cgColor],
                       startPoint: .topCenter,
                       endPoint: .bottomCenter)
    }
    let navigationBar = SDSNavigationBar().then {
        $0.rightButton.setImage(SDSIcon.icSearch, for: .normal)
    }
    let interactionView = FeedView()
    let profileInfoView = ProfileInfoView()
    let smallStepinButton = SuperShortFormSlider(size: .init(width: 100.adjusted,
                                                                 height: 32.adjusted))
    let scoreView = ScoreView(frame: .init(origin: .zero, size: CGSize(width: 72.adjusted,
                                                                       height: 72.adjusted)))
    
    let bottomGradientView = UIView().then {
        $0.addGradient(size: .init(width: UIScreen.main.bounds.width,
                                   height: 144.adjusted),
                       colors: [UIColor.PrimaryBlackNormal.withAlphaComponent(0.5).cgColor,
                                UIColor.clear.cgColor],
                       startPoint: .bottomCenter,
                       endPoint: .topCenter)
    }
  
}
