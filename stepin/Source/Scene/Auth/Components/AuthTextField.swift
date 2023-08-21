import UIKit
import RxSwift
import RxCocoa

class AuthTextField: BaseTextField {
    init(type: TextFiledType) {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
