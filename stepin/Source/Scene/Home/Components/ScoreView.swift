import UIKit
import SDSKit
import SnapKit
import Then

class ScoreView: UIView {
    private var circleLayer = CAShapeLayer()
    private var progressLayer = CAShapeLayer()
    private var startPoint = CGFloat(3 * Double.pi / 4)
    private var endPoint = CGFloat(Double.pi / 4)

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setBackgroundBlur()
        self.layer.cornerRadius = frame.size.height / 2
        createCircularPath()
        setLayout()
    }
    
    private func setBackgroundBlur() {
        let blureView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        self.addSubview(blureView)
        blureView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        blureView.layer.cornerRadius = 36.adjusted
        blureView.clipsToBounds = true
    }

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    internal func setPercent(value: Double, scale: CGFloat = 1.0) {
        //100.0
        let strValue = String(value)
        let attributedString = NSMutableAttributedString(string: strValue)
        guard let dotIndex = strValue.firstIndex(of: ".") else { fatalError() }
        
        let firstLength = strValue.distance(from: strValue.startIndex, to: dotIndex)
        let secondRange = strValue.count - firstLength
        attributedString.addAttribute(.font, value: SDSFont.h1.font, range: NSRange(location: 0, length: firstLength))
        attributedString.addAttribute(.font, value: SDSFont.callout.font, range: NSRange(location: secondRange, length: strValue.count - secondRange))
        
        self.scoreLabel.attributedText = attributedString
        self.percentLabel.font = SDSFont.body.font
        layoutIfNeeded()
    }
    
    private func setLayout() {
        self.addSubviews([scoreLabel, percentLabel])
        scoreLabel.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
        }
        percentLabel.snp.makeConstraints {
            $0.top.equalTo(scoreLabel.snp.bottom)
            $0.centerX.equalToSuperview()
        }
    }
    
    func createCircularPath() {
        // created circularPath for circleLayer and progressLayer
        let circularPath = UIBezierPath(arcCenter: .init(x: self.frame.width / 2.0,
                                                         y: self.frame.height / 2.0),
                                        radius: (frame.size.height - 10.adjusted) / 2.0 ,
                                        startAngle: startPoint,
                                        endAngle: endPoint,
                                        clockwise: true)
        // circleLayer path defined to circularPath
        circleLayer.path = circularPath.cgPath
        // ui edits
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineCap = .round
        circleLayer.lineWidth = 3
        circleLayer.strokeEnd = 1.0
        circleLayer.strokeColor = UIColor.PrimaryWhiteAlternative.cgColor
        // added circleLayer to layer
        layer.addSublayer(circleLayer)
        // progressLayer path defined to circularPath
        progressLayer.path = circularPath.cgPath
        // ui edits
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.lineWidth = 3
        progressLayer.strokeEnd = 0
        progressLayer.strokeColor = UIColor.PrimaryWhiteNormal.cgColor
        // added progressLayer to layer
        layer.addSublayer(progressLayer)
    }
    
    func progressAnimation(duration: TimeInterval, value: Double) {
        // created circularProgressAnimation with keyPath
        let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        // set the end time
        circularProgressAnimation.duration = duration
        circularProgressAnimation.toValue = value
        circularProgressAnimation.fillMode = .forwards
        circularProgressAnimation.isRemovedOnCompletion = false
        progressLayer.add(circularProgressAnimation, forKey: "progressAnim")
        self.layoutIfNeeded()
    }
    
    func setprogressValue(value: Double) {
        let circularPath = UIBezierPath(arcCenter: .init(x: self.frame.width / 2.0,
                                                         y: self.frame.height / 2.0),
                                        radius: (frame.size.height - 10.adjusted) / 2.0 ,
                                        startAngle: startPoint,
                                        endAngle: endPoint,
                                        clockwise: true)
        let progressLayer = CAShapeLayer()
        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.lineWidth = 3
        progressLayer.strokeEnd = value
        progressLayer.strokeColor = UIColor.PrimaryWhiteNormal.cgColor
        layer.addSublayer(progressLayer)
        layoutIfNeeded()
    }
    
    
    private var scoreLabel = UILabel().then {
        $0.font = SDSFont.callout.font
        $0.textColor = .PrimaryWhiteNormal
        $0.textAlignment = .center
    }
    let percentLabel = UILabel().then {
        $0.font = SDSFont.body.font
        $0.textColor = .PrimaryWhiteNormal
        $0.text = "%"
    }
}

