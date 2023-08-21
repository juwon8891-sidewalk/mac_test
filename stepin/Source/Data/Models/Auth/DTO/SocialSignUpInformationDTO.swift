
import Foundation

struct SocialSignUpInformationDTO: Codable {
    
    private var type: String
    private var accessToken: String
    private var birthDate: String
    private var identifierName: String
    
    init(type: String,
         accessToken: String,
         birthDate: String,
         identifierName: String) {
        
        self.type = type
        self.accessToken = accessToken
        self.birthDate = birthDate
        self.identifierName = identifierName
    }
}
