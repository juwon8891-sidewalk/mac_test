import UIKit
import SDSKit
import SnapKit
import Then
import Kingfisher

final class SuperShortFormCVC: UICollectionViewCell {
    var videoHandler: VideoPlayHandler?
    private var section: [Section] = []
    
    private var duration: Float = 0
    private var danceId: String = ""
    var isCellSelected: Bool = false
    
    var backButtonCompletion: (() -> Void)?
    var rightButtonCompletion: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setLayout()
        self.setTargetButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        DispatchQueue.main.async {
            self.reduceView.profileImageView.image = nil
            self.reduceView.userNameLabel.text = ""
            self.magnifyView.profileInfoView.profileImageView.image = nil
            self.magnifyView.profileInfoView.contentTextView.text = ""
            self.magnifyView.profileInfoView.userNameLabel.text = ""
            self.magnifyView.navigationBar.setTitle(title: "")
            self.magnifyView.smallStepinButton.layer.removeAllAnimations()
            self.magnifyView.scoreView.isHidden = true
            self.videoView.frame = .init(origin: .zero,
                                         size: .init(width: self.isCellSelected ? UIScreen.main.bounds.width : 274.adjusted,
                                                     height: self.isCellSelected ? UIScreen.main.bounds.height : 441.adjustedH))
            self.videoView.playerLayer.frame = self.videoView.bounds
            self.seekBar.setRemoveDivideView()
        }
    }
    
    func bindData(data: SuperShortform, isCellSelected: Bool) {
        self.section = data.section
        if let url = URL(string: data.videoUrl) {
            self.isCellSelected = isCellSelected
            self.videoView.initVideo(videoPath: url)
            self.videoHandler = VideoPlayHandler(seekTimeList: data.section,
                                                 videoView: self.videoView,
                                                 videoData: data)
            self.videoHandler?.delegate = self
            self.setViewComponentHidden(state: isCellSelected)
            DispatchQueue.main.async {
                self.seekBar.setRemoveProgress()
                self.seekBar.setVideoTime(sections: data.section,
                                          videoCount: data.section.count,
                                          duration: Float(data.totalTime))
                self.magnifyView.smallStepinButton.setSliderAnimation()
            }
        }
        self.didTapMoreButton()
    }
    
    private func didTapMoreButton() {
        self.magnifyView.profileInfoView.moreTappedCompletion = { [weak self] state in
            guard let strongSelf = self else {return}
            if state {
                UIView.animate(withDuration: 0.2, delay: 0) { [weak self] in
                    guard let strongSelf = self else {return}
                    strongSelf.magnifyView.bottomGradientView.alpha = 0
                }
                
                UIView.animate(withDuration: 0.5, delay: 0) { [weak self] in
                    guard let strongSelf = self else {return}
                    strongSelf.magnifyView.bottomGradientView.frame = .init(origin: .zero,
                                                          size: CGSize(width: UIScreen.main.bounds.width,
                                                                       height: 204.adjusted))
                    
                    strongSelf.magnifyView.bottomGradientView.addGradient(to: strongSelf.magnifyView.bottomGradientView,
                                                   colors: [UIColor.PrimaryBlackNormal.withAlphaComponent(0.5).cgColor, UIColor.clear.cgColor], startPoint: .bottomCenter, endPoint: .topCenter)
                    strongSelf.magnifyView.profileInfoView.snp.remakeConstraints {
                        $0.leading.equalToSuperview().offset(16.adjusted)
                        $0.bottom.equalTo(strongSelf.safeAreaLayoutGuide).inset(50.adjusted)
                        $0.width.equalTo(242.adjusted)
                        $0.height.equalTo(142.adjusted)
                    }
                    strongSelf.layoutIfNeeded()
                } completion: { [weak self] _ in
                    guard let strongSelf = self else {return}
                    strongSelf.magnifyView.bottomGradientView.snp.remakeConstraints {
                        $0.bottom.leading.trailing.equalToSuperview()
                        $0.height.equalTo(204.adjusted)
                    }
                    UIView.animate(withDuration: 0.2) { [weak self] in
                        guard let strongSelf = self else {return}
                        strongSelf.magnifyView.bottomGradientView.alpha = 1
                    }
                }
            } else {
                UIView.animate(withDuration: 0.2, delay: 0) { [weak self] in
                    guard let strongSelf = self else {return}
                    strongSelf.magnifyView.bottomGradientView.alpha = 0
                }
                
                UIView.animate(withDuration: 0.5, delay: 0) { [weak self] in
                    guard let strongSelf = self else {return}
                    strongSelf.magnifyView.bottomGradientView.frame = .init(origin: .zero,
                                                          size: CGSize(width: UIScreen.main.bounds.width,
                                                                       height: 144.adjusted))
                    strongSelf.magnifyView.bottomGradientView.addGradient(to: strongSelf.magnifyView.bottomGradientView,
                                                   colors: [UIColor.PrimaryBlackNormal.withAlphaComponent(0.5).cgColor, UIColor.clear.cgColor], startPoint: .bottomCenter, endPoint: .topCenter)
                    strongSelf.magnifyView.profileInfoView.snp.remakeConstraints {
                        $0.leading.equalToSuperview().offset(16.adjusted)
                        $0.bottom.equalTo(strongSelf.safeAreaLayoutGuide).inset(50.adjusted)
                        $0.width.equalTo(242.adjusted)
                        $0.height.equalTo(67.adjusted)
                    }
                    strongSelf.layoutIfNeeded()
                } completion: { [weak self] _ in
                    guard let strongSelf = self else {return}
                    strongSelf.magnifyView.bottomGradientView.snp.remakeConstraints {
                        $0.bottom.leading.trailing.equalToSuperview()
                        $0.height.equalTo(144.adjusted)
                    }
                    UIView.animate(withDuration: 0.2) { [weak self] in
                        guard let strongSelf = self else {return}
                        strongSelf.magnifyView.bottomGradientView.alpha = 1
                    }
                }
            }
        }
    }
    
    //MARK: - 다음 비디오로 이동
    private func didTapNextVideo() {
        if let handler = videoHandler {
            if handler.getCurrentIndex() < section.count - 1 {
                handler.setTimeToVideo(time: section[handler.getNextIndex()].start) { _ in
                    handler.playVideo()
                }
            }
        }
    }
    
    private func didTapBeforeVideo() {
        if let handler = videoHandler {
            if handler.getCurrentIndex() > 0 {
                handler.setTimeToVideo(time: section[handler.getBeforeIndex()].start) { _ in
                    handler.playVideo()
                }
            }
        }
    }
    
    private func didTapPauseVideo() {
        if let handler = videoHandler {
            if handler.videoPlayState == .isPlay {
                handler.pauseVideo()
            } else {
                handler.playVideo()
            }
                
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if self.isCellSelected {
            if let touch = touches.first {
                let touchLocation = touch.location(in: self)
                //left
                if touchLocation.x < UIScreen.main.bounds.width / 3 {
                    self.didTapBeforeVideo()
                }
                else if touchLocation.x > UIScreen.main.bounds.width / 3 && touchLocation.x < (UIScreen.main.bounds.width / 3) * 2 {
                    self.didTapPauseVideo()
                } else {
                    self.didTapNextVideo()
                }
            }
        }
    }
    
    internal func setViewComponentHidden(state: Bool) {
        DispatchQueue.main.async {
            if self.isCellSelected {
                self.reduceView.isHidden = true
                self.magnifyView.isHidden = false
            } else {
                self.reduceView.isHidden = false
                self.magnifyView.isHidden = true
            }
            self.seekBar.isHidden = !state
        }
    }
    
    private func setLayout() {
        self.backgroundColor = .PrimaryBlackAlternative
        self.clipsToBounds = true
        self.layer.cornerRadius = 10.adjusted
        guard let window = UIWindow.key else {return}
        
        self.contentView.addSubviews([videoView, magnifyView, reduceView, seekBar])
        videoView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        magnifyView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        magnifyView.isHidden = true
        reduceView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        seekBar.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(window.safeAreaInsets.bottom + 60)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(2)
        }
    }
    
    private func setTargetButton() {
        magnifyView.navigationBar.backButton.addTarget(self,
                                                       action: #selector(backButtonTapped),
                                                       for: .touchUpInside)
        magnifyView.navigationBar.rightButton.addTarget(self,
                                                       action: #selector(rightButtonTapped),
                                                       for: .touchUpInside)
    }
    
    @objc private func backButtonTapped() {
        guard let completion = backButtonCompletion else {return}
        completion()
    }
    
    @objc private func rightButtonTapped() {
        guard let completion = rightButtonCompletion else {return}
        completion()
    }
    
    let videoView = BaseVideoView(frame: .init(origin: .zero,
                                               size: .init(width: 258.adjusted,
                                                           height: 421.adjustedH)))
    let seekBar = CustomSeekBar()
    let magnifyView = SuperShortFormMagnifyView()
    let reduceView = SuperShortFormReduceView()
}
extension SuperShortFormCVC: VideoHandlerDelegate {
    func getCurrentVideo(data: Video) {
        self.danceId = data.danceID
        self.magnifyView.bindData(data: data)
        self.reduceView.bindData(profileImagePath: data.profileURL ?? "",
                                 userName: data.identifierName)
        NotificationCenter.default.post(
            name: .homeCurrentDanceId,
            object: data
        )
    }
    
    func getCurrentPlayTime(time: Float, totalPlayTime: Float) {
        self.seekBar.setProgressBarValue(value: time)
    }
    
    
}
