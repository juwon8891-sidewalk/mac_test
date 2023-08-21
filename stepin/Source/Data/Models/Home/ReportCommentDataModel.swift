import Foundation

struct ReportCommentDataModel: Codable {
    let statusCode: Int
    let message: String
}

//Post Reply Model
struct postReportModel: Codable {
    private var commentId: String
    private var content: String
    
    init(commentId: String, content: String) {
        self.commentId = commentId
        self.content = content
    }
}
