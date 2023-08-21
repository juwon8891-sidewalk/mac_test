import UIKit
import SnapKit
import Then

class SuperShortFormSlider: UIView {
    var animationEndCompletion: ((String) -> Void)?
    var danceId: String = ""
    
    init(size: CGSize) {
        super.init(frame: .init(origin: .zero, size: size))
        self.layer.cornerRadius = size.height / 2.0
        self.backgroundColor = .stepinWhite100
        self.setLayout()
        self.setGesture() 
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setGesture() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(didMusicButtonTapped(_:)))
        self.addGestureRecognizer(tapGesture)
        
    }
    
    @objc private func didMusicButtonTapped(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn]) {
            for index in 0 ... 2 {
                self.musicImageView.transform = CGAffineTransform(rotationAngle: CGFloat((index % 2)) * .pi)
                self.musicImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn]) {
            for index in 0 ... 2{
                self.musicImageView.transform = CGAffineTransform(rotationAngle: CGFloat((index % 2)) * .pi)
            }
            let translationTransform = CGAffineTransform(translationX: self.frame.width - ScreenUtils.setWidth(value: 35), y: 0)
            self.musicImageBackgroundView.transform = translationTransform
        } completion: { [weak self] _ in
            guard let self = self else {return}
            guard let completion = self.animationEndCompletion else {return}
            self.musicImageView.transform = .identity
            self.musicImageBackgroundView.transform = .identity
            completion(self.danceId)
        }
    }
    
    func setSliderAnimation() {
        UIView.animateKeyframes(withDuration: 1, delay: 0, options: [.repeat]) {
            UIView.addKeyframe(withRelativeStartTime: 0,
                               relativeDuration: 1/3) {
                self.sliderImageView1.alpha = 0
                self.sliderImageView2.alpha = 1
            }
            UIView.addKeyframe(withRelativeStartTime: 1/3,
                               relativeDuration: 1/3) {
                self.sliderImageView2.alpha = 0
                self.sliderImageView3.alpha = 1
            }
            UIView.addKeyframe(withRelativeStartTime: 2/3,
                               relativeDuration: 1/3) {
                self.sliderImageView3.alpha = 0
             }
        }
    }
    
    private func setLayout() {
        musicImageView.addSubview(musicImageHoleView)
        self.addSubviews([sliderImageView1, sliderImageView2, sliderImageView3, sliderTopView, goalImageView, musicImageBackgroundView])
        
        musicImageHoleView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 6))
        }
        musicImageHoleView.layer.cornerRadius = ScreenUtils.setWidth(value: 6) / 2
        
        musicImageBackgroundView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 4))
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 24))
        }
        musicImageView.contentMode = .scaleAspectFit
        musicImageBackgroundView.addSubview(musicImageView)
        musicImageHoleView.clipsToBounds = true
        musicImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(ScreenUtils.setWidth(value: 4))
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 24))
        }
        musicImageView.layer.cornerRadius = ScreenUtils.setWidth(value: 24) / 2
        musicImageView.clipsToBounds = true
        
        sliderImageView1.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(musicImageView.snp.trailing).offset(ScreenUtils.setWidth(value: -4))
            $0.width.equalTo(ScreenUtils.setWidth(value: 18))
        }
        sliderImageView1.alpha = 1
        sliderImageView2.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(sliderImageView1.snp.trailing).offset(ScreenUtils.setWidth(value: -6))
            $0.width.equalTo(ScreenUtils.setWidth(value: 18))
        }
        sliderImageView2.alpha = 0
        sliderImageView3.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(sliderImageView2.snp.trailing).offset(ScreenUtils.setWidth(value: -6))
            $0.width.equalTo(ScreenUtils.setWidth(value: 18))
        }
        sliderImageView3.alpha = 0
        sliderTopView.snp.makeConstraints {
            $0.leading.equalTo(sliderImageView1.snp.leading)
            $0.trailing.equalTo(sliderImageView3.snp.trailing)
            $0.top.bottom.equalToSuperview()
        }
        sliderTopView.alpha = 0
        goalImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 4))
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 24))
        }
        setSliderAnimation()
    }
    
    internal func setData(imagePath: String,
                          danceId: String) {
        self.danceId = danceId
        guard let url = URL(string: imagePath) else {return}
        DispatchQueue.main.async {
            self.musicImageView.kf.setImage(with: url)
        }
    }
    
    
    internal var musicImageView = UIImageView()
    private var musicImageBackgroundView = UIView().then {
        $0.backgroundColor = .clear
    }
    private var musicImageHoleView = UIView().then {
        $0.backgroundColor = .stepinWhite100
    }
    private var sliderImageView1 = UIImageView(image: ImageLiterals.icNextAnimation)
    private var sliderImageView2 = UIImageView(image: ImageLiterals.icNextAnimation)
    private var sliderImageView3 = UIImageView(image: ImageLiterals.icNextAnimation)
    private var goalImageView = UIImageView(image: ImageLiterals.icStepinButtonGoal)
    private var sliderTopView = UIView().then {
        $0.backgroundColor = .stepinWhite100
    }
}
