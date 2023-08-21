import UIKit
import Foundation

class CustomProgressBar: UIProgressView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(size: CGSize) {
        super.init(frame: .init(origin: .zero, size: size))
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        self.trackTintColor = .stepinWhite40
        self.progressTintColor = .stepinWhite100
    }
    
    func setValue(_ value: Float) {
        self.setProgress(value, animated: true)
    }
}
