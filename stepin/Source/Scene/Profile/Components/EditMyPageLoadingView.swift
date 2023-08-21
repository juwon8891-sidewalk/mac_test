import UIKit
import SnapKit
import Then
import Lottie

class EditMyPageLoadingView: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    init() {
        super.init(frame: .zero)
        self.setLayout()
        self.setLoadingLabelAnimate()
    }
    
    private func setLoadingLabelAnimate() {
        self.animationView.play()
        self.animationView.loopMode = .loop
    }
    
    private func setLayout() {
        self.addSubviews([backGroundBlurView, animationView, loadingLabel])
        backGroundBlurView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        animationView.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
            $0.width.equalTo(ScreenUtils.setWidth(value: 75))
            $0.height.equalTo(ScreenUtils.setWidth(value: 138))
        }
        loadingLabel.snp.makeConstraints {
            $0.top.equalTo(self.animationView.snp.bottom)
            $0.centerX.equalToSuperview()
        }
    }
    
    private let backGroundBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let animationView = LottieAnimationView(name: "skeleton-loading")
    private let loadingLabel = UILabel().then {
        $0.font = .suitExtraBoldFont(ofSize: 20)
        $0.textColor = .white
        $0.text = "mypage_loading_view_title".localized() + "..."
        $0.textAlignment = .center
    }
}
