import UIKit
import SDSKit
import SnapKit
import Then
import Lottie

class NeonLoadingView: UIView {
    private var totalFrame: Int = 0
    private var currentFrame: Int = 0
    private var inferencTime: Float = 0
    private var percent: Float = 0
    
    init() {
        super.init(frame: .zero)
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    internal func setEstimateTime(totalFrame: Int,
                                  currentFrame: Int,
                                  inferenceTime: Float) {
        self.totalFrame = totalFrame
        self.currentFrame = currentFrame
        self.inferencTime = inferenceTime
        self.estimatedTime()
    }
    
    /**
     time is total seconds
     */
    private func setEstimateLabel() {
        self.percentLabel.text = "\(Int(percent * 100))%"
    }
    
    private func estimatedTime() {
        //남은 장수 * infernceTime = 남은 시간
        DispatchQueue.main.async {
            self.percent = Float(self.currentFrame) / Float(self.totalFrame)
            self.progressBar.setProgress(self.percent, animated: true)
            self.setEstimateLabel()
        }
    }
     
    
    private func setLayout() {
        self.backgroundColor = .black.withAlphaComponent(0.5)
        self.addSubview(backGroundView)
        backGroundView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        backGroundView.layer.cornerRadius = ScreenUtils.setWidth(value: 30)
        backGroundView.clipsToBounds = true
        
        self.backGroundView.addSubviews([titleLabel, animationView, percentLabel, estimateTimeDescription, descriotionLabel, cancelButton, loadingBackgroundView, progressBar])
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24.adjusted)
            $0.leading.trailing.equalToSuperview()
        }
        animationView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8.adjusted)
            $0.leading.trailing.equalToSuperview().inset(99.adjusted)
            $0.width.equalTo(ScreenUtils.setWidth(value: 75))
            $0.height.equalTo(ScreenUtils.setWidth(value: 138))
        }
        progressBar.snp.makeConstraints {
            $0.top.equalTo(animationView.snp.bottom).offset(16.adjusted)
            $0.leading.trailing.equalToSuperview().inset(36.adjusted)
            $0.height.equalTo(6.adjusted)
        }
        progressBar.layer.cornerRadius = 3.adjusted
        progressBar.clipsToBounds = true
        
        percentLabel.snp.makeConstraints {
            $0.top.equalTo(self.progressBar.snp.bottom).offset(12.adjusted)
            $0.leading.trailing.equalToSuperview()
        }
        estimateTimeDescription.snp.makeConstraints {
            $0.top.equalTo(self.percentLabel.snp.bottom).offset(ScreenUtils.setWidth(value: 16))
            $0.leading.trailing.equalToSuperview()
        }
        self.descriotionLabel.snp.makeConstraints {
            $0.top.equalTo(self.estimateTimeDescription.snp.bottom).offset(ScreenUtils.setWidth(value: 16))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 20))
            $0.bottom.equalTo(cancelButton.snp.top).inset(-24.adjusted)
        }
        cancelButton.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(ScreenUtils.setWidth(value: 48))
        }
        self.animationView.loopMode = .loop
        self.animationView.play()
        
        
        //ffmpeg 로딩 시 로딩 뷰
        loadingBackgroundView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        loadingBackgroundView.addSubview(self.circleLoadingView)
        self.circleLoadingView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 100))
        }
        self.circleLoadingView.loopMode = .loop
        self.circleLoadingView.play()
        loadingBackgroundView.isHidden = true
    }
    

    
    
    private let backGroundView = UIView().then {
        $0.backgroundColor = .stepinBlack100
        $0.layer.borderWidth = ScreenUtils.setWidth(value: 1)
        $0.layer.borderColor = UIColor.stepinWhite40.cgColor
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .suitExtraBoldFont(ofSize: 20)
        $0.text = "history_view_loading_title".localized()
        $0.textColor = .stepinWhite100
        $0.textAlignment = .center
    }
    private let animationView = LottieAnimationView(name: "skeleton-loading")
    private let progressBar = GradientProgressBar(progressViewStyle: .default)
    private let percentLabel = UILabel().then {
        $0.font = .suitExtraBoldFont(ofSize: 20)
        $0.textColor = .stepinWhite100
        $0.textAlignment = .center
    }
    private let estimateTimeDescription = UILabel().then {
        $0.font = .suitRegularFont(ofSize: 12)
        $0.textColor = .stepinWhite100
        $0.text = "history_view_loading_estimate_time_title".localized()
        $0.textAlignment = .center
    }
    private let descriotionLabel = UILabel().then {
        $0.font = .suitMediumFont(ofSize: 16)
        $0.textColor = .stepinWhite100
        $0.text = "history_view_loading_description".localized()
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    internal let cancelButton = SDSMediumButton(type: .alternative).then {
        $0.setTitle("histroy_loading_view_cancel_button_title".localized(), for: .normal)
    }
    
    internal let loadingBackgroundView = UIView().then {
        $0.backgroundColor = .stepinBlack50
    }
    internal let circleLoadingView = LottieAnimationView(name: "loading")
    
}
