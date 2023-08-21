import UIKit
import SnapKit
import Then

class SSRDetailInfoView: UIView {
    private var danceId: String = ""
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    init() {
        super.init(frame: .zero)
        self.setDetailLayout()
        self.setSliderButtonLayout()
    }
    
    private func setDetailLayout() {
        self.addSubviews([interactionStackView, profileInfoView, navigationView, sliderButton])
        self.interactionStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(ScreenUtils.setWidth(value: 184))
            $0.width.equalTo(ScreenUtils.setWidth(value: 50))
            $0.height.equalTo(ScreenUtils.setWidth(value: 134))
        }
        self.profileInfoView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(ScreenUtils.setWidth(value: 80))
            $0.width.equalTo(ScreenUtils.setWidth(value: 148))
            $0.height.equalTo(ScreenUtils.setWidth(value: 67))
        }
        navigationView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 60))
        }

        sliderButton.isHidden = true
        didTapMoreButton()
    }
    private func setSliderButtonLayout() {
        self.sliderButton.snp.makeConstraints {
            $0.bottom.equalTo(self.profileInfoView.snp.bottom)
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 16))
            $0.width.equalTo(ScreenUtils.setWidth(value: 100))
            $0.height.equalTo(ScreenUtils.setWidth(value: 32))
        }
        
        sliderButton.isHidden = false
        sliderButton.layer.shadowColor = UIColor.stepinWhite100.cgColor
        sliderButton.layer.shadowOpacity = 0.5
        sliderButton.layer.shadowRadius = ScreenUtils.setWidth(value: 15)
        sliderButton.clipsToBounds = false
        sliderButton.layer.cornerRadius = ScreenUtils.setWidth(value: 15)
        
        sliderButton.animationEndCompletion = { [weak self] _ in
            guard let self = self else {return}
            NotificationCenter.default.post(
                name: .didStepinPlayButtonTapped,
                object: self.danceId
            )
        }
    }
    
    private func didTapMoreButton() {
        self.profileInfoView.moreTappedCompletion = { state in
            if state {
                self.bottomGradientView.removeFromSuperview()
                self.bottomGradientView = UIView(frame: .init(origin: .zero,
                                                              size: CGSize(width: UIScreen.main.bounds.width,
                                                                           height: ScreenUtils.setWidth(value: 204))))
                self.bottomGradientView.addGradient(to: self.bottomGradientView,
                                               colors: [UIColor.stepinBlack100.cgColor, UIColor.clear.cgColor], startPoint: .bottomCenter, endPoint: .topCenter)
                self.insertSubview(self.bottomGradientView, at: 2)
                self.bottomGradientView.snp.remakeConstraints {
                    $0.bottom.leading.trailing.equalToSuperview()
                    $0.height.equalTo(ScreenUtils.setWidth(value: 204))
                }
                self.profileInfoView.snp.remakeConstraints {
                    $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
                    $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(ScreenUtils.setWidth(value: 60))
                    $0.width.equalTo(ScreenUtils.setWidth(value: 242))
                    $0.height.equalTo(ScreenUtils.setWidth(value: 142))
                }
            } else {
                self.bottomGradientView.removeFromSuperview()
                self.bottomGradientView = UIView(frame: .init(origin: .zero,
                                                              size: CGSize(width: UIScreen.main.bounds.width,
                                                                           height: ScreenUtils.setWidth(value: 144))))
                self.bottomGradientView.addGradient(to: self.bottomGradientView,
                                               colors: [UIColor.stepinBlack100.cgColor, UIColor.clear.cgColor], startPoint: .bottomCenter, endPoint: .topCenter)
                self.insertSubview(self.bottomGradientView, at: 2)
                self.bottomGradientView.snp.remakeConstraints {
                    $0.bottom.leading.trailing.equalToSuperview()
                    $0.height.equalTo(ScreenUtils.setWidth(value: 144))
                }
                self.profileInfoView.snp.remakeConstraints {
                    $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 16))
                    $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(ScreenUtils.setWidth(value: 80))
                    $0.width.equalTo(ScreenUtils.setWidth(value: 242))
                    $0.height.equalTo(ScreenUtils.setWidth(value: 67))
                }
            }
        }
    }
    internal func setData(danceId: String) {
        self.danceId = danceId
    }
    internal func setSliderButtonImage(path: String) {
        guard let url = URL(string: path) else {return}
        self.sliderButton.musicImageView.kf.setImage(with: url)
    }
    
    internal let navigationView = SSFTopNavigationView()
    
    internal lazy var sliderButton = SuperShortFormSlider(size: CGSize(width: ScreenUtils.setWidth(value: 100),
                                                                       height: ScreenUtils.setWidth(value: 32)))
    private var seekBarView: CustomSeekBar?
    internal let interactionStackView = VideoStackView()
    internal let profileInfoView = ProfileInfoView()
    private var bottomGradientView = UIView(frame: .init(origin: .zero,
                                                         size: CGSize(width: UIScreen.main.bounds.width,
                                                                      height: ScreenUtils.setWidth(value: 144))))
}

