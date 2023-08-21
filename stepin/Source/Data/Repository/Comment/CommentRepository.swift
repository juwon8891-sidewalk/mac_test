import Foundation
import RxSwift

enum CommentApiType {
    case getComment
    case getReply
    case createComment
    case createReply
    case removeComment
    case reportComment
    case likeComment
}

class CommentRepository {
    private let tokenUtil = TokenUtils()
    private let defaultURLSessionNetworkService: DefaultURLSessionNetworkService
    
    init(defaultURLSessionNetworkService: DefaultURLSessionNetworkService) {
        self.defaultURLSessionNetworkService = defaultURLSessionNetworkService
    }
    
    //댓글 리스트 조회
    func getComment(videoId: String, page: Int, top: Int = 0) -> Observable<CommentTableviewDataSection> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        
        var url: String = ""
        if top == 0 {
            url = Constants.baseURL + "/comment/video/\(videoId)?page=\(page)"
        } else {
            url = Constants.baseURL + "/comment/video/\(videoId)?page=\(page)&top=\(top)"
        }
        
        return self.defaultURLSessionNetworkService.get(url: Constants.baseURL + "/comment/video/\(videoId)?page=\(page)",
                                                        headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(CommentDataModel.self, from: result.get())
            let returnModel = CommentTableviewDataSection(items: json.data.comment)
            return returnModel
        }
    }
    
    //대댓글 리스트 조회
    func getReplyComment(commentId: String, page: Int, top: Int = 0) -> Observable<ReplyCommentTableviewDataSection> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        var url: String = ""
        if top == 0 {
            url = Constants.baseURL + "/comment/\(commentId)?page=\(page)"
        } else {
            url = Constants.baseURL + "/comment/\(commentId)?page=\(page)&top=\(top)"
        }
        
        return self.defaultURLSessionNetworkService.get(url: url,
                                                        headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(ReplyCommentDataModel.self, from: result.get())
            let returnModel = ReplyCommentTableviewDataSection(header: json.data.comment, items: json.data.reply)
            return returnModel
        }
    }
    
    //댓글 작성
    func postCreateComment(videoId: String, content: String) -> Observable<PostCreateCommentModel>{
        let requestBody = CreateCommentRequestBody(videoId: videoId,
                                                   content: content)
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.post(requestBody,
                                                         url: Constants.baseURL + "/comment",
                                                         headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(PostCreateCommentModel.self, from: result.get())
            return json
        }
    }
    
    //대댓글 작성
    func postCreateReply(videoId: String, commentId: String, content: String) -> Observable<PostCreateCommentModel>{
        let requestBody = CreateReplyRequestBody(videoId: videoId,
                                                 commentId: commentId,
                                                 content: content)
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.post(requestBody,
                                                         url: Constants.baseURL + "/comment/reply",
                                                         headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(PostCreateCommentModel.self, from: result.get())
            return json
        }
    }
    
    //댓글 삭제
    func deleteComment(commentId: String) -> Observable<DeleteCommentModel> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        return self.defaultURLSessionNetworkService.delete(url: Constants.baseURL + "/comment/\(commentId)",
                                                           headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(DeleteCommentModel.self, from: result.get())
            return json
        }
    }
    
    //댓글 좋아요
    func patchLikeComment(commentId: String, state: Int) -> Observable<PatchLikeCommentModel> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        print(Constants.baseURL + "/comment/like/\(commentId)?state=\(state)")
        return self.defaultURLSessionNetworkService.patch(url: Constants.baseURL + "/comment/like/\(commentId)?state=\(state)",
                                                          headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(PatchLikeCommentModel.self, from: result.get())
            return json
        }
    }
    
    //댓글 신고
    func postReportComment(commentId: String, content: String) -> Observable<ReportCommentDataModel> {
        let authHeader: [String: String] = ["Content-Type": "application/json",
                                            "accept": "application/json",
                                            "accesstoken": "Bearer \((self.tokenUtil.read(account: UserDefaultKey.accessToken) ?? ""))"]
        let requestBody = postReportModel(commentId: commentId, content: content)
        print(requestBody, Constants.baseURL + "/comment/report/\(commentId)")
        return self.defaultURLSessionNetworkService.post(requestBody,
                                                         url: Constants.baseURL + "/comment/report",
                                                         headers: authHeader)
        .map { result in
            let decoder = JSONDecoder()
            let json = try decoder.decode(ReportCommentDataModel.self, from: result.get())
            return json
        }
    }
}
