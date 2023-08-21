import UIKit
import Lottie

extension UIViewController {
    func makeRandomPassword() -> String {
        let str = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let size = 8
        let pwString = (0 ..< size).map{ _ in str.randomElement()! }
        return String(pwString)
    }
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func makeAlert(title: String,
                   message: String,
                   okAction: ((UIAlertAction) -> Void)? = nil,
                   completion: (() -> Void)? = nil) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let alertViewController = UIAlertController(title: title, message: message,
                                                    preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "okText".localized(), style: .default, handler: okAction)
        alertViewController.addAction(okAction)
        
        
        self.present(alertViewController, animated: true, completion: completion)
    }
    
    func addLoadingIndicator() -> [UIView] {
        let animationView = LottieAnimationView(name: "loading")
        let backgroundBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        self.view.addSubviews([backgroundBlurView, animationView])
        backgroundBlurView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        animationView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 100))
        }
        animationView.loopMode = .loop
        animationView.play()
        
        return [animationView, backgroundBlurView]
    }
    
    func removeLoadingIndicator(_ views: [UIView]) {
        let animationView = views[0] as! LottieAnimationView
        let backGroundView = views[1] as! UIVisualEffectView
        animationView.stop()
        backGroundView.removeFromSuperview()
        animationView.removeFromSuperview()
    }
}
