import Foundation

// MARK: - Welcome
struct StaminaDataModel: Codable {
    let statusCode: Int?
    let message: String?
    let data: StaminaData
}

// MARK: - DataClass
struct StaminaData: Codable {
    let stamina: Stamina
}

// MARK: - Stamina
struct Stamina: Codable {
    let stamina: Double
    let staminaLatestUpdate: String
    let onFree: Bool
    let createdAt: String
}
