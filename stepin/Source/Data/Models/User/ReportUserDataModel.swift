import Foundation

struct ReportUserDataModel: Codable {
    let statusCode: Int
    let message: String
}

//Post Reply Model
struct PostReportUserModel: Codable {
    private var userId: String
    private var content: String
    
    init(userId: String, content: String) {
        self.userId = userId
        self.content = content
    }
}
