import Foundation

struct PatchModifyVideoData: Codable {
    let signedURL: [SignedURL]

    enum CodingKeys: String, CodingKey {
        case signedURL = "signedUrl"
    }
}


struct ModifyVideoDataModel: Codable {
    let content: String
    let hashtag: [String]
    let allowComment, oepnScore: Bool
    
    init(content: String,
         hashTag: [String],
         allowComment: Bool,
         openScore: Bool) {
        self.content = content
        self.hashtag = hashTag
        self.allowComment = allowComment
        self.oepnScore = openScore
    }
}
