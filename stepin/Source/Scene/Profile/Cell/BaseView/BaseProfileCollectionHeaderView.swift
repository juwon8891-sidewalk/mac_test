import UIKit
import SnapKit
import Then

public class BaseProfileCollectionHeaderView: UICollectionReusableView {
    init() {
        super.init(frame: .zero)
        setLayout()
        didInitNotificationCenter()
        setHeaderViewConfig()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
        didInitNotificationCenter()
        setHeaderViewConfig()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setLayout()
        didInitNotificationCenter()
        setHeaderViewConfig()
    }
    
    internal func initVideoView(videoPath: String) {
        if videoPath == "" {
            DispatchQueue.main.async {
                self.backgroundImageView.isHidden = false
            }
        } else {
            DispatchQueue.main.async {
                self.backgroundImageView.isHidden = true
            }
            guard let url = URL(string: videoPath) else {return}
            self.backgroundVideoView.initVideo(videoPath: url)
            self.backgroundVideoView.clipsToBounds = true
            backgroundVideoView.playVideo()
        }
    }
    
    private func didInitNotificationCenter() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didDisposeVideo),
            name: .didDisposeVideo,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didSetVolumeValue),
            name: .didProfileVideoScrolled,
            object: nil
        )
    }
    
    @objc private func didDisposeVideo() {
        self.backgroundVideoView.disposeVideoView()
    }
    
    @objc private func didSetVolumeValue(_ sender: NSNotification) {
        if let state = sender.object as? Bool {
            if state {
                self.backgroundVideoView.muteOn()
            } else {
                self.backgroundVideoView.muteOff()
            }
        }
    }
    
    private func setHeaderViewConfig() {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                         action: #selector(didHeaderViewTapped)))
    }
    @objc private func didHeaderViewTapped() {
        if self.backgroundVideoView.isPlaying {
            self.backgroundVideoView.pauseVideo()
        } else {
            self.backgroundVideoView.playVideo()
        }
    }
    
    private func setLayout() {
        self.addSubviews([backgroundVideoView, backgroundImageView, gradientView, idLabel, bottomGradientView, alphaControlView, profileImageView])
        gradientView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        gradientView.addGradient(size: CGSize(width: UIScreen.main.bounds.width,
                                              height: ScreenUtils.setHeight(value: 468)),
                                 colors: [UIColor.stepinBlack100.cgColor,
                                          UIColor.stepinBlack90.cgColor,
                                          UIColor.stepinBlack70.cgColor,
                                          UIColor.stepinBlack60.cgColor,
                                          UIColor.stepinBlack30.cgColor,
                                          UIColor.clear.cgColor],
                                 startPoint: .bottomCenter,
                                 endPoint: .topCenter)
        backgroundImageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setHeight(value: 468))
        }
        backgroundImageView.isHidden = true
        
        backgroundVideoView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setHeight(value: 468))
        }
        profileImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 72))
        }
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = ScreenUtils.setWidth(value: 72) / 2
        idLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(ScreenUtils.setHeight(value: 4))
            $0.centerX.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 15))
        }
        bottomGradientView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(20)
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.height.equalTo(1)
        }
        alphaControlView.snp.makeConstraints {
            $0.bottom.equalTo(self.bottomGradientView.snp.top)
            $0.top.leading.trailing.equalToSuperview()
        }
    }
    

    
    internal var profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    internal var idLabel = UILabel().then {
        $0.textColor = .stepinWhite100
        $0.textAlignment = .center
        $0.font = .suitLightFont(ofSize: 12)
    }
    internal var backgroundVideoView = MyPageVideoView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width,
                                                                                                 height: ScreenUtils.setHeight(value: 511))))
    private var backgroundImageView = UIImageView(image: ImageLiterals.profileBackground)
    internal var gradientView = UIView()
    internal var bottomGradientView = HorizontalGradientView(width: 343)
    internal var alphaControlView = UIView().then {
        $0.backgroundColor = .clear
    }
}
