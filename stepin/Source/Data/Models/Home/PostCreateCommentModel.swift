import Foundation

struct PostCreateCommentModel: Codable {
    let statusCode: Int
    let message: String
}

//Post Comment Model
struct CreateCommentRequestBody: Codable {
    private var videoId: String
    private var content: String
    
    init(videoId: String, content: String) {
        self.videoId = videoId
        self.content = content
    }
}

//Post Reply Model
struct CreateReplyRequestBody: Codable {
    private var videoId: String
    private var commentId: String
    private var content: String
    
    init(videoId: String, commentId: String, content: String) {
        self.videoId = videoId
        self.commentId = commentId
        self.content = content
    }
}
