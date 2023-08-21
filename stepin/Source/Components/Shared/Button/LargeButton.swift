import UIKit
import Foundation

class LargeButton: UIButton {
    internal var isButtonSelected: Bool?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    internal func isUnselectedButton(title: String) { }
    internal func isSelectedButton(title: String) { }
}
