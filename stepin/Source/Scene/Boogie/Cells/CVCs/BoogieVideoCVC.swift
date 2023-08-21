import UIKit
import RxSwift

class BoogieVideoCVC: UICollectionViewCell {
    static let identifier: String = "BoogieVideoCVC"
    private var userId: String = ""
    private var cooridnator: BoogieCoordinator?
    var videoHandler: VideoPlayHandler?
    var isPlaying: Bool = false

    var startTime: Float?
    var endTime: Float?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.progressBar = nil
        self.profileInfoView.setRefreshView()
    }
    
    internal func setCellVideoData(videoPath: String,
                                   profilePath: String,
                                   userName: String,
                                   userId: String,
                                   hashTags: [Hashtag],
                                   content: String,
                                   likeCount: Int,
                                   isLiked: Bool,
                                   commentCount: Int,
                                   isCommentEnabled: Bool,
                                   isOpenScore: Bool,
                                   score: String,
                                   coordinator: BoogieCoordinator) {
        self.cooridnator = coordinator
        self.userId = userId
        self.videoHandler = VideoPlayHandler(videoView: self.videoView)
        self.videoHandler?.delegate = self
        
        DispatchQueue.main.async {
            self.profileInfoView.setRefreshView()
            self.profileInfoView.setData(imagePath: profilePath,
                                         name: userName,
                                         hashTags: hashTags,
                                         content: content)
            self.interactionStackView.bindData(commentCnt: commentCount,
                                               isCommentEnabled: isCommentEnabled,
                                               likeCnt: likeCount,
                                               isLiked: isLiked)
            self.setLayout()
        }
        DispatchQueue.main.async {
            guard let url = URL(string: videoPath) else {return}
            self.videoView.initVideo(videoPath: url)
        }
        didTapMoreButton()
        didProfileImageTapped()
        showScoreAnimation(isOpenScore: isOpenScore, 
                           score: score)
    }
    
    private func showScoreAnimation(isOpenScore: Bool,
                                    score: String) {
        //스코어 보여주기
        DispatchQueue.main.async {
            if isOpenScore && (score != "") {
                self.scoreView.isHidden = false
                let percentValue = Double(Double(score)! / 100)
                let doubleValue = Double(score)!
                
                let strValue = String(format: "%.02f", doubleValue)
                self.scoreView.progressAnimation(duration: 0.8,
                                                 value: percentValue)
                self.scoreView.setPercent(value: Double(strValue)!)
            } else {
                self.scoreView.isHidden = true
            }

        }
    }
    
    private func didTapMoreButton() {
        self.profileInfoView.moreTappedCompletion = { state in
            if state {
                UIView.animate(withDuration: 0.2, delay: 0) {
                    self.bottomGradientView.alpha = 0
                }
                
                UIView.animate(withDuration: 0.5, delay: 0) {
                    self.bottomGradientView.frame = .init(origin: .zero,
                                                          size: CGSize(width: UIScreen.main.bounds.width,
                                                                       height: ScreenUtils.setWidth(value: 204)))
                    
                    self.bottomGradientView.addGradient(to: self.bottomGradientView,
                                                   colors: [UIColor.stepinBlack100.cgColor, UIColor.clear.cgColor], startPoint: .bottomCenter, endPoint: .topCenter)
                    self.profileInfoView.snp.remakeConstraints {
                        $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
                        $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(ScreenUtils.setWidth(value: 80))
                        $0.width.equalTo(ScreenUtils.setWidth(value: 242))
                        $0.height.equalTo(ScreenUtils.setWidth(value: 142))
                    }
                    self.layoutIfNeeded()
                } completion: { _ in
                    self.bottomGradientView.snp.remakeConstraints {
                        $0.bottom.leading.trailing.equalToSuperview()
                        $0.height.equalTo(ScreenUtils.setWidth(value: 204))
                    }
                    UIView.animate(withDuration: 0.2) {
                        self.bottomGradientView.alpha = 1
                    }
                }
            } else {
                UIView.animate(withDuration: 0.2, delay: 0) {
                    self.bottomGradientView.alpha = 0
                }
                
                UIView.animate(withDuration: 0.5, delay: 0) {
                    self.bottomGradientView.frame = .init(origin: .zero,
                                                          size: CGSize(width: UIScreen.main.bounds.width,
                                                                       height: ScreenUtils.setWidth(value: 144)))
                    self.bottomGradientView.addGradient(to: self.bottomGradientView,
                                                   colors: [UIColor.stepinBlack100.cgColor, UIColor.clear.cgColor], startPoint: .bottomCenter, endPoint: .topCenter)
                    self.profileInfoView.snp.remakeConstraints {
                        $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
                        $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(ScreenUtils.setWidth(value: 80))
                        $0.width.equalTo(ScreenUtils.setWidth(value: 242))
                        $0.height.equalTo(ScreenUtils.setWidth(value: 67))
                    }
                    self.layoutIfNeeded()
                } completion: { _ in
                    self.bottomGradientView.snp.remakeConstraints {
                        $0.bottom.leading.trailing.equalToSuperview()
                        $0.height.equalTo(ScreenUtils.setWidth(value: 144))
                    }
                    UIView.animate(withDuration: 0.2) {
                        self.bottomGradientView.alpha = 1
                    }
                }
            }
        }
    }
    
    private func didProfileImageTapped() {
        self.profileInfoView.profileCompletion = { [weak self] in
            guard let self else {return}
            DispatchQueue.main.async {
                if UserDefaults.standard.bool(forKey: UserDefaultKey.LoginStatus) {
                    self.cooridnator?.pushToProfileView(userId: self.userId)
                } else {
                    self.cooridnator?.pushToLogin()
                }
            }
        }
    }
    
    internal func playVideo() {
        self.videoHandler?.playVideo()
        self.isPlaying = true
    }
    internal func stopVideo() {
        self.videoHandler?.pauseVideo()
        self.isPlaying = false
    }
    
    internal func removeVideo() {
        self.videoView.pauseVideo()
        self.isPlaying = false
    }
    
    private func setLayout() {
        if self.progressBar != nil {
            self.progressBar?.removeFromSuperview()
            self.progressBar = CustomProgressBar(size: .init(width: UIScreen.main.bounds.width,
                                                             height: 2))
        } else {
            self.progressBar = CustomProgressBar(size: .init(width: UIScreen.main.bounds.width,
                                                             height: 2))
        }
        self.addSubviews([videoView, bottomGradientView, interactionStackView, profileInfoView, progressBar!, scoreView])
        
        videoView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        interactionStackView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(ScreenUtils.setHeight(value: 329))
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.width.equalTo(ScreenUtils.setWidth(value: 50))
        }
        
        profileInfoView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(ScreenUtils.setWidth(value: 80))
            $0.width.equalTo(ScreenUtils.setWidth(value: 242))
            $0.height.equalTo(ScreenUtils.setWidth(value: 67))
        }
        
        progressBar!.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(2)
        }
        bottomGradientView.addGradient(to: bottomGradientView,
                                       colors: [UIColor.stepinBlack100.cgColor, UIColor.clear.cgColor], startPoint: .bottomCenter, endPoint: .topCenter)
        bottomGradientView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 144))
        }
        scoreView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(ScreenUtils.setWidth(value: 80))
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 72))
        }
        scoreView.isHidden = true
    }
    
    private let videoView = BaseVideoView(frame: .init(origin: .zero, size: .init(width: UIScreen.main.bounds.width,
                                                                              height: UIScreen.main.bounds.height - 94)))
    internal let interactionStackView = FeedView()
    private let profileInfoView = ProfileInfoView()
    private var progressBar: CustomProgressBar?
    private var bottomGradientView = UIView(frame: .init(origin: .zero,
                                                         size: CGSize(width: UIScreen.main.bounds.width,
                                                                      height: ScreenUtils.setWidth(value: 144))))
    internal let scoreView = ScoreView(frame: .init(origin: .zero, size: CGSize(width: ScreenUtils.setWidth(value: 72),
                                                                                height: ScreenUtils.setWidth(value: 72))))
    
}
extension BoogieVideoCVC: VideoHandlerDelegate {
    func getCurrentVideo(data: Video) {}
    
    func getCurrentPlayTime(time: Float, totalPlayTime: Float) {
        self.progressBar?.setValue(time / totalPlayTime)
        print(time, totalPlayTime)
        if time >= totalPlayTime - 0.5 {
            self.videoHandler?.pauseVideo()
            self.videoHandler?.setTimeToVideo(time: 0) { [weak self] _ in
                guard let strongSelf = self else {return}
                strongSelf.videoHandler?.playVideo()
            }
        }
    }
}
