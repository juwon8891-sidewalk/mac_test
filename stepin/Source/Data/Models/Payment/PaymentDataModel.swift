import Foundation

// MARK: - Welcome
struct PaymentDataModel: Codable {
    let statusCode: Int
    let message: String
    let data: PaymentData
}

// MARK: - DataClass
struct PaymentData: Codable {
    let status: Bool
}

struct receiptsRequestBody: Codable {
    var receipt: String
    
    init(receipt: String) {
        self.receipt = receipt
    }
}
