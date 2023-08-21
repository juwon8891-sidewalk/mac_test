import UIKit
import SDSKit
import RxSwift
import RxCocoa

class BaseTextField: UITextField {
    let disposeBag = DisposeBag()
    var viewModel = BaseTextFieldViewModel()
    
    internal var isEmpty: Bool = true
    internal var didEditing: Bool = false
    
    init() {
        super.init(frame: .zero)
        self.autocapitalizationType = .none
        setBaseConfig()
        bindViewModel()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    internal func bindViewModel() {
        let output = viewModel.textFieldTransform(from: .init(textFieldDidEditing: self.rx.text.orEmpty.asObservable(),
                                                              textFieldDidClear: self.rx.observe(String.self, "text").asObservable()),
                                                  disposeBag: disposeBag)
        
        output.currentTextFieldState
            .asDriver()
            .drive(onNext: { [weak self] state in
                switch state {
                case .empty:
                    self?.isEmpty = true
                case .didEditting:
                    self?.didEditing = true
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    internal func setBaseConfig() {
        self.textAlignment = .left
        self.font = SDSFont.h2.font
        self.textColor = .stepinWhite100
    }
    
}
