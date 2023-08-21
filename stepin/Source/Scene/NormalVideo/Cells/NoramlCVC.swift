import UIKit
import SnapKit
import Then

class NormalCVC: UICollectionViewCell {
    static let identifier: String = "NormalCVC"
    var videoHandler: VideoPlayHandler?
    private var coordinator: NormalViewCoordinator?
    private var userId: String = ""
    var isPlaying: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
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
                                   musicTitle: String,
                                   isCommentEnabled: Bool,
                                   isOpenScore: Bool,
                                   score: String,
                                   coordinaotr: NormalViewCoordinator) {
        self.coordinator = coordinaotr
        self.userId = userId
        self.videoHandler = VideoPlayHandler(videoView: self.videoView)
        self.videoHandler?.delegate = self
        
        self.musicTitleLabel.text = "   \(musicTitle)   "
        self.profileInfoView.setRefreshView()
        self.profileInfoView.setData(imagePath: profilePath,
                                     name: userName,
                                     hashTags: hashTags,
                                     content: content)
        self.interactionStackView.bindData(commentCnt: commentCount,
                                           isCommentEnabled: isCommentEnabled,
                                           likeCnt: likeCount,
                                           isLiked: isLiked)
        
        DispatchQueue.main.async {
            self.setLayout()
            guard let url = URL(string: videoPath) else {return}
            self.videoView.initVideo(videoPath: url)
        }
        didTapMoreButton()
        didProfileImageTapped()
        showScoreAnimation(isOpenScore: isOpenScore, score: score)
    }
    
    private func showScoreAnimation(isOpenScore: Bool,
                                    score: String) {
        //스코어 보여주기
        DispatchQueue.main.async {
            if isOpenScore && (score != "") {
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
    
    private func didProfileImageTapped() {
        self.profileInfoView.profileCompletion = {
            if UserDefaults.standard.bool(forKey: UserDefaultKey.LoginStatus) {
                self.coordinator?.pushToProfileView(userId: self.userId)
            } else {
                self.coordinator?.pushToLogin()
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
    
    internal func playVideo() {
        self.videoHandler?.playVideo()
        self.isPlaying = true
    }
    internal func stopVideo() {
        self.videoHandler?.pauseVideo()
        self.isPlaying = false
    }
    internal func removeVideo() {
        self.videoHandler?.pauseVideo()
        self.isPlaying = false
    }
    
    private func setLayout() {
        self.contentView.addSubviews([videoView, bottomGradientView, interactionStackView, profileInfoView, musicTitleLabel, scoreView])
        
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
        
        bottomGradientView.addGradient(to: bottomGradientView,
                                       colors: [UIColor.stepinBlack100.cgColor, UIColor.clear.cgColor], startPoint: .bottomCenter, endPoint: .topCenter)
        bottomGradientView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 144))
        }
        musicTitleLabel.snp.makeConstraints {
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(ScreenUtils.setWidth(value: 20))
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.height.equalTo(ScreenUtils.setWidth(value: 30))
        }
        
        scoreView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(ScreenUtils.setWidth(value: 80))
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 72))
        }
        
        musicTitleLabel.layer.cornerRadius = ScreenUtils.setWidth(value: 15)
        musicTitleLabel.clipsToBounds = true
    }
    
    private let videoView = BaseVideoView(frame: .init(origin: .zero, size: .init(width: UIScreen.main.bounds.width,
                                                                              height: UIScreen.main.bounds.height)))
    internal let interactionStackView = FeedView()
    private let profileInfoView = ProfileInfoView()
    private var bottomGradientView = UIView(frame: .init(origin: .zero,
                                                         size: CGSize(width: UIScreen.main.bounds.width,
                                                                      height: ScreenUtils.setWidth(value: 144))))
    private var musicTitleLabel = UILabel().then {
        $0.backgroundColor = .stepinWhite100
        $0.font = .suitRegularFont(ofSize: 14)
        $0.textColor = .stepinBlack100
    }
    internal let scoreView = ScoreView(frame: .init(origin: .zero, size: CGSize(width: ScreenUtils.setWidth(value: 72),
                                                                                height: ScreenUtils.setWidth(value: 72))))
}
extension NormalCVC: VideoHandlerDelegate {
    func getCurrentVideo(data: Video) {}
    
    func getCurrentPlayTime(time: Float, totalPlayTime: Float) {
        if time >= totalPlayTime - 0.5 {
            self.videoHandler?.pauseVideo()
            self.videoHandler?.setTimeToVideo(time: 0) { [weak self] _ in
                guard let strongSelf = self else {return}
                strongSelf.videoHandler?.playVideo()
            }
        }
    }
}
