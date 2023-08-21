import Foundation
import UIKit
import Lottie

enum borderRect {
    case top
    case bottom
    case left
    case right
}
extension UIView {
    func addSubviews(_ views: [UIView]) {
        views.forEach { self.addSubview($0) }
    }
    func removeAllSubViews() {
        self.subviews.forEach { $0.removeFromSuperview() }
    }
    
    func addBorderGradient(to view: UIView, startColor:UIColor, endColor: UIColor, lineWidth: CGFloat, startPoint: CGPoint, endPoint: CGPoint) {
        self.layer.cornerRadius = view.bounds.size.height / 2.0
        self.clipsToBounds = true
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        let shape = CAShapeLayer()
        shape.lineWidth = lineWidth
        shape.path = UIBezierPath(arcCenter: CGPoint(x: view.bounds.height/2,
                                                     y: view.bounds.height/2),
                                  radius: view.bounds.height/2,
                                  startAngle: CGFloat(0),
                                  endAngle: CGFloat(CGFloat.pi * 2),
                                  clockwise: true).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = .none
        gradient.mask = shape
        view.layer.insertSublayer(gradient, at: 0)
        view.layer.setNeedsDisplay()
    }
    
    func addBorderGradient(size: CGSize,
                           startColor: CGColor,
                           endColor: CGColor,
                           lineWidth: CGFloat,
                           startPoint: CGPoint,
                           endPoint: CGPoint,
                           cornerRadius: CGFloat) {
        removeGradient()
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: size)
        gradient.colors = [startColor, endColor]
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.cornerRadius = cornerRadius
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = lineWidth
        shapeLayer.path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size),
                                       cornerRadius: cornerRadius ).cgPath
        shapeLayer.fillColor = .none
        shapeLayer.strokeColor = UIColor.black.cgColor
        gradient.mask = shapeLayer
        
        self.layer.insertSublayer(gradient, at: 0)
        self.layer.setNeedsDisplay()
    }
    
    func addGradient(to view: UIView,
                     startColor:UIColor,
                     endColor: UIColor,
                     startPoint: CGPoint,
                     endPoint: CGPoint) {
        removeGradient()
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        
        view.layer.insertSublayer(gradient, at: 0)
        view.layer.setNeedsDisplay()
    }
    
    func addGradient(to view: UIView,
                     colors: [CGColor],
                     startPoint: CGPoint,
                     endPoint: CGPoint) {
        removeGradient()
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = colors
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        
        view.layer.insertSublayer(gradient, at: 0)
        view.layer.setNeedsDisplay()
    }
    
    func addGradient(size: CGSize,
                     colors: [CGColor],
                     startPoint: CGPoint,
                     endPoint: CGPoint) {
        removeGradient()
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: size)
        gradient.colors = colors
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        
        self.layer.insertSublayer(gradient, at: 0)
        self.layer.setNeedsDisplay()
    }
    func removeGradient() {
        if let gradientLayer = (self.layer.sublayers?.compactMap { $0 as? CAGradientLayer })?.first {
            gradientLayer.removeFromSuperlayer()
        }
    }
    
    @discardableResult
    func drawShadow(color: UIColor,
                    opacity: Float,
                    offset: CGSize,
                    radius: CGFloat) -> Self {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        return self
    }
    
    func removeLoadingIndicator(view: LottieAnimationView) {
        view.stop()
        view.removeFromSuperview()
    }
    
    func shake() {
        self.transform = CGAffineTransform(translationX: 20, y: 0)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    
    func addBorder(rect: borderRect, borderColor: UIColor, borderWidth: CGFloat, superView: UIView) {
        let borderView = UIView()
        borderView.backgroundColor = borderColor
        self.addSubview(borderView)
        switch rect {
        case .top:
            borderView.snp.makeConstraints {
                $0.top.leading.trailing.equalTo(superView)
                $0.height.equalTo(borderWidth)
            }
        case .bottom:
            borderView.snp.makeConstraints {
                $0.bottom.leading.trailing.equalTo(superView)
                $0.height.equalTo(borderWidth)
            }
        case .left:
            borderView.snp.makeConstraints {
                $0.top.leading.bottom.equalTo(superView)
                $0.width.equalTo(borderWidth)
            }
        case .right:
            borderView.snp.makeConstraints {
                $0.top.trailing.bottom.equalTo(superView)
                $0.width.equalTo(borderWidth)
            }
        }
        
    }
    
    func brighteningUpAnimate() {
        let view = UIView()
        view.backgroundColor = UIColor.black
        self.addSubview(view)
        self.bringSubviewToFront(view)
        view.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        UIView.animate(withDuration: 0.5, delay: 0) {
            view.alpha = 0
        }
    }
    
    func makeToast(title: String, type: ToastViewIconType) {
        DispatchQueue.main.async {
            let toastView = ToastView(title: title,
                                      icon: type)
            self.addSubview(toastView)
            self.bringSubviewToFront(toastView)
            toastView.snp.makeConstraints {
                $0.top.equalTo(self.safeAreaLayoutGuide).offset(ScreenUtils.setWidth(value: 15))
                $0.centerX.equalToSuperview()
                $0.height.equalTo(ScreenUtils.setWidth(value: 40))
            }
            toastView.layer.cornerRadius = ScreenUtils.setWidth(value: 20)
            
            UIView.animate(withDuration: 2.0,
                           delay: 0.5, options: .curveEaseOut,
                           animations: { toastView.alpha = 0.0 },
                           completion: {(isCompleted) in toastView.removeFromSuperview() })
        }
    }
    
    func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
    
    func captureAsImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        guard let pngData = image.pngData() else { return nil }
        return UIImage(data: pngData)
    }
    
    func showLoadingIndicator() {
        let backgroundView = UIView()
        let animationView = LottieAnimationView(name: "loading")
        self.addSubview(backgroundView)
        backgroundView.backgroundColor = .stepinBlack70
        backgroundView.tag = 99
        backgroundView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        backgroundView.addSubview(animationView)
        animationView.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 64))
        }
        animationView.loopMode = .loop
        animationView.play()
    }
    
    func removeLoadingIndicator() {
        self.subviews.forEach {
            if $0.tag == 99 {
                $0.removeFromSuperview()
            }
        }
    }
    
    func getTabbarHeight() -> CGFloat{
        guard let window = UIWindow.key else { return 0}
        return window.safeAreaInsets.bottom + 60
    }
    
}
