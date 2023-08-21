import UIKit
import SnapKit
import Then

class CustomSeekBar: UIProgressView {
    private var viewTag = 0
    private var duration: Float = 0
    internal var viewCount = 0
    internal var isPlaying: Bool = false
    
    private var divideViewArray: [UIView] = []
    private var currentProgress: Float = 0
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: .init(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width,
                                                            height: 2)))
    }
    
    
    internal func setVideoTime(sections: [Section],
                               videoCount: Int,
                               duration: Float) {
        self.viewCount = videoCount
        self.duration = duration
        self.setViewLayout(videoCount: videoCount,
                           sections: sections)
    }
    
    private func setViewLayout(videoCount: Int,
                               sections: [Section]) {
        DispatchQueue.main.async {
            self.progressTintColor = .stepinWhite100
            self.trackTintColor = .stepinWhite40
            self.progressViewStyle = .bar
            var beforePadding: CGFloat = 0
            
            
            for i in 0 ... videoCount - 1 {
                let divideView = UIView()
                divideView.backgroundColor = .stepinWhite100
                self.addSubview(divideView)
                let leading = beforePadding + (CGFloat(sections[i].end - sections[i].start) / CGFloat(self.duration)) * UIScreen.main.bounds.width
                divideView.snp.makeConstraints {
                    $0.top.bottom.equalToSuperview()
                    $0.width.equalTo(2)
                    $0.leading.equalToSuperview().inset(leading)
                }
                beforePadding = leading
                self.divideViewArray.append(divideView)
            }
        }
    }
    
    internal func setRemoveProgress() {
        self.progress = 0.0
    }
    
    internal func setRemoveDivideView() {
        self.divideViewArray.forEach {
            $0.removeFromSuperview()
        }
    }
    
    internal func setProgressBarValue(value: Float) {
        DispatchQueue.main.async {
            self.setProgress(value / self.duration, animated: true)
        }
    }
    
}
