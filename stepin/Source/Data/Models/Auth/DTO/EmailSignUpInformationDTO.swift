import Foundation

struct EmailSignUpInformationDTO: Codable {
    
    private var type: String
    private var email: String
    private var password: String
    private var birthDate: String
    private var identifierName: String
    
    init(type: String,
         email: String,
         password: String,
         birthDate: String,
         identifierName: String) {
        
        self.type = type
        self.email = email
        self.password = password
        self.birthDate = birthDate
        self.identifierName = identifierName
    }
}
