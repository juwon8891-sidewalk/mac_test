struct PostBlockUserModel: Codable {
    let statusCode: Int
    let message: String
    let data: PostBlockData
}

struct PostBlockData: Codable {
    let state: Int
}
