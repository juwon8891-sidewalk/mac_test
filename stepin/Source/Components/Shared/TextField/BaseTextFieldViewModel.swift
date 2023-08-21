import UIKit
import RxSwift
import RxCocoa

enum TextFieldState {
    case none
    case didEditting
    case empty
    case unformatted_email_form
    case unformatted_email_dupplicated
    case unformatted_password_contain_alphabet
    case unformatted_password_contain_number
    case unformatted_password_length
    case unformatted_id
    case unformatted_dupplicated_id
    case unformatted_login_pwd
    case unformatted_nickname
    case formatted_email
    case formatted_password_contain_alphabet
    case formatted_password_contain_number
    case formatted_password_length
    case formatted_id
    case formatted_login_pwd
    case formatted_nickname
    case formatted_use_stepinid
    case formatted_use_nickname
    case alreadyUse
    case complete
    case fail_network
}

class BaseTextFieldViewModel {
    init() {
    }
    
    struct Input {
        let textFieldDidEditing: Observable<String>
        let textFieldDidClear: Observable<String?>
    }
    
    struct Output {
        var currentTextFieldState = BehaviorRelay<TextFieldState>(value: .empty)
    }
    
    func textFieldTransform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        /**
         글자가 하나이상 입력되어, 변화가 존재할때
         */
        input.textFieldDidEditing
            .subscribe(onNext: { [weak self] text in
                if text.count == 0 {
                    output.currentTextFieldState.accept(.empty)
                } else {
                    output.currentTextFieldState.accept(.didEditting)
                }
            })
            .disposed(by: disposeBag)
        /**
         remove button 호출로 인한 텍스트 필드 비우기 감지
         */
        input.textFieldDidClear
            .subscribe(onNext: { [weak self] text in
                output.currentTextFieldState.accept(.empty)
            })
            .disposed(by: disposeBag)
        
        return output
    }
}

