import Foundation

struct AuthCheckDuplicateDTO: Codable {
    private var value: String
    
    init(value: String) {
        self.value = value
    }
}
