import UIKit
import SDSKit
import Foundation

class StepinButton: UIView {
    var animationEndCompletion: (() -> Void)?
    
    init(size: CGSize) {
        super.init(frame: CGRect(origin: .zero, size: size))
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    internal func setImageView(imagePath: String) {
        guard let url = URL(string: imagePath) else {return}
        self.musicImageView.kf.setImage(with: url)
    }
    
    internal func playAnimation() {
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
            let translationTransform = CGAffineTransform(translationX: self.frame.width - ScreenUtils.setWidth(value: 32), y: 0)
            self.musicImageBackgroundView.transform = translationTransform
        } completion: { _ in
            guard let completion = self.animationEndCompletion else {return}
            self.musicImageView.transform = .identity
            self.musicImageBackgroundView.transform = .identity
            completion()
        }
    }
    //pagenation
    
    private func setLayout() {
        self.backgroundColor = .stepinWhite100
        self.setMusicView()
        self.addSubviews([stepinButtonGoal, stepinLogoImageView, musicImageBackgroundView])
        musicImageBackgroundView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview().inset(ScreenUtils.setWidth(value: 4))
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 24))
        }
        musicImageView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        musicImageView.layer.cornerRadius = ScreenUtils.setWidth(value: 24) / 2
        musicImageView.clipsToBounds = true
        stepinLogoImageView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(ScreenUtils.setWidth(value: 6))
            $0.leading.equalTo(musicImageView.snp.trailing).offset(7.adjusted)
            $0.trailing.equalTo(stepinButtonGoal.snp.leading).inset(-7.adjusted)
        }
        stepinButtonGoal.snp.makeConstraints {
            $0.top.trailing.bottom.equalToSuperview().inset(ScreenUtils.setWidth(value: 4))
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 24))
        }
    }
    
    private func setMusicView() {
        musicImageBackgroundView.addSubview(musicImageView)
        musicImageView.addSubview(musicImageHoleView)
        musicImageHoleView.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 6))
        }
        musicImageHoleView.layer.cornerRadius = ScreenUtils.setWidth(value: 6) / 2
    }
    private var musicImageBackgroundView = UIView().then {
        $0.backgroundColor = .clear
    }
    private var musicImageView = UIImageView()
    private var musicImageHoleView = UIView().then {
        $0.backgroundColor = .stepinWhite100
    }
    private var stepinLogoImageView = UIImageView(image: SDSIcon.icStepinTextLogo.withTintColor(.PrimaryBlackNormal,
                                                                                                renderingMode: .alwaysTemplate)).then {
        $0.tintColor = .PrimaryBlackNormal
        $0.contentMode = .scaleAspectFill
    }
    private var stepinButtonGoal = UIImageView(image: ImageLiterals.icStepinButtonGoal)
}
