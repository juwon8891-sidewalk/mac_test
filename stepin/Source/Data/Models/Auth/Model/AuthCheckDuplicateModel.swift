import Foundation

// MARK: - EmailVerificate
struct AuthCheckDuplicateModel: Codable {
    let statusCode: Int
    let message: String
    let data: IsUnique
}

// MARK: - DataClass
struct IsUnique: Codable {
    let isUnique: Bool
}
