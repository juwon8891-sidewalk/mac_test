
import Foundation

// MARK: - ProductIPModel
struct ProductIPModel: Codable {
    let statusCode: Int
    let message: String
    let data: DataClass
}

// MARK: - DataClass
struct DataClass: Codable {
    let contry, code, tier: String
    let quantityPer1D, quantityPer2D, quantityPer5D, quantityPer10D: Int
    let ratio: Int
}

