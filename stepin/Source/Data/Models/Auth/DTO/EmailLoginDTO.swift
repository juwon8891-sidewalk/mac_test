import Foundation

struct EmailLoginDTO: Codable {
    private var type: String // 추가
    private var email: String
    private var password: String
    
    init(type: String,
        email: String,
         password: String) {
        self.type = type
        self.email = email
        self.password = password
    }
}
