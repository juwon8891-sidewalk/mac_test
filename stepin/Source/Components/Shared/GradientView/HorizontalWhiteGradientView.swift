import UIKit

class HorizontalGradientView: UIView {
    init() {
        super.init(frame: CGRect(origin: .zero,
                                 size: CGSize(width: ScreenUtils.setWidth(value: 232),
                                              height: 1)))
        self.addGradient(to: self,
                         colors: [UIColor.stepinWhite0.cgColor, UIColor.stepinWhite40.cgColor, UIColor.stepinWhite0.cgColor],
                         startPoint: .centerLeft,
                         endPoint: .centerRight)
        
    }
    
    init(width: CGFloat) {
        super.init(frame: CGRect(origin: .zero,
                                 size: CGSize(width: ScreenUtils.setWidth(value: width),
                                              height: 1)))
        self.addGradient(to: self,
                         colors: [UIColor.stepinWhite0.cgColor, UIColor.stepinWhite40.cgColor, UIColor.stepinWhite0.cgColor],
                         startPoint: .centerLeft,
                         endPoint: .centerRight)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
