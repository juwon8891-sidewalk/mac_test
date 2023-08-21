//이메일 확인 요청
struct VerifyEmailModel: Codable {
    let statusCode: Int
    let message: String
    let data: Token
}

struct Token: Codable {
    let token: String
}

//이메일 체크 확인
struct CheckVerifyEmailModel: Codable {
    let statusCode: Int
    let message: String
    let data: IsComplete
}

struct IsComplete: Codable {
    let isCompleted: Bool
}
