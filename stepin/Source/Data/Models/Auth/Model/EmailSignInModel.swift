import Foundation

// MARK: - EmailVerificate
struct EmailSignInModel: Codable {
    let statusCode: Int
    let message: String
    let error: String?
    let data: SignInData?
}

// MARK: - DataClass
struct SignInData: Codable {
    let userID, identifierName, name: String
    let profileURL: String?
    let useFlag: Bool

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case identifierName, name
        case profileURL = "profileUrl"
        case useFlag
    }
}
