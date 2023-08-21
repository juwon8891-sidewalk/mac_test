import UIKit
import SnapKit
import Then
import MarqueeLabel

class TitleNavigationView: NavigationView {
    var rightButtonCompletion: (() -> Void)?

    override init() {
        super.init()
        self.backgroundColor = .clear
        setTitleNavigationLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func setGradientBackground() {
        self.backgroundColor = .clear
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.frame = self.frame
        self.insertSubview(blurView, belowSubview: self.titleLabel)
        blurView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    internal func setTitle(title: String) {
        self.titleLabel.text = title
    }
    
    internal func setRightButtonTextColor(color: UIColor) {
        self.rightButton.setTitleColor(color, for: .normal)
    }
    
    internal func setRightButtonText(text: String) {
        self.rightButton.setTitle(text, for: .normal)
        self.rightButton.titleLabel?.font = .suitExtraBoldFont(ofSize: 20)
        
        self.rightButton.titleLabel?.textAlignment = .center
        self.rightButton.snp.remakeConstraints {
            $0.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 12))
            $0.centerY.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 51))
        }
    }
    
    internal func setRightButtonUnselected() {
        self.rightButton.setTitleColor(.stepinWhite40, for: .normal)
    }
    
    internal func setRightButtonSelected() {
        self.rightButton.setTitleColor(.stepinWhite100, for: .normal)
    }
    
    internal func setRightButtonImage(image: UIImage) {
        if image == ImageLiterals.icMore {
            self.rightButton.setImage(image, for: .normal)
        } else {
            self.rightButton.setBackgroundImage(image, for: .normal)
        }
    }
    
    internal func setRightButtonSelectedImage(image: UIImage) {
        self.rightButton.setBackgroundImage(image, for: .selected)
    }
    
    internal func setRightButtonHidden() {
        self.rightButton.isHidden = true
    }
    
    internal func setRightButtonShow() {
        self.rightButton.isHidden = false
    }
    
    private func setTitleNavigationLayout() {
        self.addSubviews([titleLabel, rightButton])
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 106))
            $0.centerY.equalToSuperview()
        }
        rightButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 48))
        }
        rightButton.addTarget(self, action: #selector(didRightButtonClicked(_:)), for: .touchUpInside)
    }
    
    @objc private func didRightButtonClicked(_ sender: UIButton) {
        guard let completion = rightButtonCompletion else {return}
        completion()
    }
    
    private var titleLabel = MarqueeLabel().then {
        $0.trailingBuffer = 30
        $0.font = .suitExtraBoldFont(ofSize: 20)
        $0.textColor = .stepinWhite100
        $0.textAlignment = .center
    }
    internal var rightButton = UIButton()
}
