import Foundation

/**
 request Body
 */
struct ModifyProfile: Codable {
    private var identifierName: String
    private var name: String
    private var videoId: String?
    
    init(identiferName: String,
         name: String,
         videoId: String?) {
        self.identifierName = identiferName
        self.name = name
        self.videoId = videoId
    }
}

/**
 response Body
 */
struct PatchModifyProfileModel: Codable {
    let statusCode: Int
    let message: String
    let data: PatchModifyProfileData
}

// MARK: - DataClass
struct PatchModifyProfileData: Codable {
    let signedURL: [SignedURL]

    enum CodingKeys: String, CodingKey {
        case signedURL = "signedUrl"
    }
}

// MARK: - SignedURL
struct SignedURL: Codable {
    let signedURL: String
    let extensionHeadersKeyArray, extensionHeadersValueArray: [String]

    enum CodingKeys: String, CodingKey {
        case signedURL = "signedUrl"
        case extensionHeadersKeyArray, extensionHeadersValueArray
    }
}
