import Foundation

struct ResetPasswordDTO: Codable {
    private var token: String
    private var password: String
    
    init() {
        self.token = TokenUtils().read(account: "findEmailVerify") ?? ""
        self.password = TokenUtils().read(account: UserDefaultKey.password) ?? ""
    }
}
