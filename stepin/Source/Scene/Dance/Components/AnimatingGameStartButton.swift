import Foundation
import UIKit
import SDSKit
import SnapKit
import Then

final class AnimatingGameStartButton: UIView {
    private var flag: Bool = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    init() {
        super.init(frame: .zero)
        self.setLayout()
    }
    
    private func setLayout() {
        self.addSubview(circleView)
        self.addSubview(iconBackgroundImageView)
        iconBackgroundImageView.addSubview(imageView)
        iconBackgroundImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(90)
        }
        imageView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        circleView.snp.makeConstraints {
            $0.centerX.centerY.equalTo(iconBackgroundImageView)
            $0.width.height.equalTo(30)
        }
        makeCircleViewBorder()
    }
    
    @objc private func pressView(_ sender: UILongPressGestureRecognizer) {
        UIView.animate(withDuration: 0.1) {
            self.iconBackgroundImageView.transform = .init(scaleX: 1.1, y: 1.1)
            self.circleView.transform = .init(scaleX: 1.1, y: 1.1)
            self.imageView.transform = .init(scaleX: 1.1, y: 1.1)
        }
        if sender.state == .ended {
            UIView.animate(withDuration: 0.1) {
                self.iconBackgroundImageView.transform = .identity
                self.circleView.transform = .identity
                self.imageView.transform = .identity
            }
            if flag == false {
                self.circleView.layer.removeAllAnimations()
            } else {
                self.setAnimation()
            }
            self.flag.toggle()
        }
    }
    
    func setAnimation() {
        UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut]) {
            self.circleView.transform = .init(scaleX: 2.4, y: 2.4)
        } completion: { [weak self] _ in
            guard let self = self else {return}
            UIView.animate(withDuration: 0.2) {
                self.circleView.transform = .identity
            }
        }
    }
    
    private func makeCircleViewBorder() {
        circleView.setGradientBorder(width: 15, colors: [UIColor(red: 75.0 / 255.0, green: 188 / 255.0, blue: 251 / 255.0, alpha: 1),
                                                        UIColor(red: 255 / 255.0, green: 255 / 255.0, blue: 255 / 255.0, alpha: 1),
                                                        UIColor(red: 75 / 255.0, green: 188 / 255.0, blue: 251 / 255.0, alpha: 1)],
                                     radius: 15)
        circleView.layer.cornerRadius = 15
        circleView.clipsToBounds = true
    }
    
    private lazy var iconBackgroundImageView = UIImageView(image: SDSIcon.icAnimationButtonBase).then {
        $0.isUserInteractionEnabled = true
        let pressGesture = UILongPressGestureRecognizer(target: self,
                                                        action: #selector(self.pressView))
        pressGesture.minimumPressDuration = 0
        $0.addGestureRecognizer(pressGesture)

    }
    private let imageView = UIImageView(image: SDSIcon.icAnimationButtonLine).then{
        $0.isUserInteractionEnabled = true
    }
    private let circleView = UIView(frame: .init(origin: .zero, size: .init(width: 30,
                                                                            height: 30))).then {
        $0.isUserInteractionEnabled = true
    }
}
