import UIKit
import RxRelay
import RxSwift

class AuthTextFieldViewModel: BaseTextFieldViewModel {
    let disposeBag = DisposeBag()
    private var signUpRepository = AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    
    struct Input {
        init(type: TextFiledType, obserbe: Observable<String>) {
            switch type {
            case .email, .login_email:
                self.emailTextFieldDidEditting = obserbe
                self.passwordTextFieldDidEditting = nil
                self.idTextFieldDidEditting = nil
            case .id:
                self.idTextFieldDidEditting = obserbe
                self.emailTextFieldDidEditting = nil
                self.passwordTextFieldDidEditting = nil
            case .password, .login_password:
                self.passwordTextFieldDidEditting = obserbe
                self.emailTextFieldDidEditting = nil
                self.idTextFieldDidEditting = nil
            }
        }
        let emailTextFieldDidEditting: Observable<String>?
        let passwordTextFieldDidEditting: Observable<String>?
        let idTextFieldDidEditting: Observable<String>?
    }
    
    struct Output {
        var authTextFieldState = BehaviorRelay<TextFieldState>(value: .none)
    }
    
    func authTextFieldTransform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.emailTextFieldDidEditting?
            .subscribe(onNext: { email in
                if email.isValidEmail() {
                    output.authTextFieldState.accept(.formatted_email)
                } else {
                    output.authTextFieldState.accept(.unformatted_email_form)
                }
                
            })
            .disposed(by: disposeBag)
        
        input.passwordTextFieldDidEditting?
            .subscribe(onNext: { pwd in
                //알파벳 포함
                let alphabetOption = pwd.isContainEnglish()
                output.authTextFieldState.accept(alphabetOption ? .formatted_password_contain_alphabet: .unformatted_password_contain_alphabet)
                //숫자 포함
                let numOption = pwd.isContainNumber()
                output.authTextFieldState.accept(numOption ? .formatted_password_contain_number: .unformatted_password_contain_number)
                //8자 이상
                let countOption = pwd.isLengthOver8()
                output.authTextFieldState.accept(countOption ? .formatted_password_length: .unformatted_password_length)
                
                if alphabetOption && numOption && countOption {
                    output.authTextFieldState.accept(.formatted_login_pwd)
                } else {
                    output.authTextFieldState.accept(.unformatted_login_pwd)
                }
            })
            .disposed(by: disposeBag)
        
        input.idTextFieldDidEditting?
            .subscribe(onNext: { id in
                if id.count >= 5 {
                    if id.isContainNumberAndAlphabet() {
                        UserDefaults.standard.set(id, forKey: UserDefaultKey.identifierName)
                        output.authTextFieldState.accept(.formatted_id)
                    } else {
                        output.authTextFieldState.accept(.unformatted_id)
                    }
                } else {
                    output.authTextFieldState.accept(.unformatted_id)
                }
            })
            .disposed(by: disposeBag)
        return output
    }
    
}
