import Foundation

enum EmailAuthnticatyionType {
    case normal
    case findPassword
}

struct EmailAuthenticationDTO: Codable {
    private var email: String
    private var type: String
    
    init(type: EmailAuthnticatyionType) {
        if type == .normal {
            self.email = UserDefaults.standard.string(forKey: UserDefaultKey.email) ?? ""
            self.type = UserDefaults.standard.string(forKey: UserDefaultKey.emailVerifyType) ?? ""
        } else {
            self.email = UserDefaults.standard.string(forKey: UserDefaultKey.findPwdEmail) ?? ""
            self.type = UserDefaults.standard.string(forKey: UserDefaultKey.passwordReset) ?? ""
        }
    }
}
