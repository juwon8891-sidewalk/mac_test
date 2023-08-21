import Foundation
import UIKit
import RxSwift
import RxRelay
import RxDataSources

final class ReplyCommentViewModel: NSObject {
    let tokenUtil = TokenUtils()
    var repository: CommentRepository?
    var coordinator: ReplyCommentCoordinator?
    var authRepository = AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    
    internal var deleteCompletion: ((IndexPath) -> Void)?
    internal var reportCompletion: ((IndexPath) -> Void)?
    internal var headerLikeCompletion: ((Int) -> Void)?
    internal var profileImageViewTapped: (() -> Void)?

    private var dataSource: RxTableViewSectionedReloadDataSource<ReplyCommentTableviewDataSection>?
    internal var commentId: String = ""
    internal var videoId: String = ""
    private var comment: String = ""
    private var commentPage: Int = 1
    private var replyCommentId: String = ""
    private var reportContent: String = ""
    fileprivate var userId: String = ""


    private var dummyReply: Reply = Reply(commentID: "\t\t",
                                          userID: "\t\t",
                                          identifierName: "\t\t",
                                          name: "\t\t",
                                          profileURL: "",
                                          content: "\t\t",
                                          likeCount: 1,
                                          alreadyLiked: true,
                                          alreadyBlocked: true,
                                          createdAt: "")
    
    
    private var dummySkeletonData: ReplyCommentTableviewDataSection =
    ReplyCommentTableviewDataSection(header:Comment(commentID: "\t\t",
                                                   userID: "\t\t",
                                                   identifierName: "\t\t",
                                                   name: "\t\t",
                                                   profileURL: "",
                                                   content: "\t\t",
                                                   likeCount: 1,
                                                   replyCount: 1,
                                                   alreadyLiked: true,
                                                   alreadyBlocked: true,
                                                   createdAt: ""),
                                           items: [])
    
    private var commentResult: [ReplyCommentTableviewDataSection] = []
    private var resultRelay = PublishRelay<[ReplyCommentTableviewDataSection]>()
    private var commentViewFirstPresentFlag: Bool = false
    fileprivate var headercommentViewFirstPresentFlag: Bool = false
    private var skeletonFlag: Bool = false
    private var dummyTableViewReflect = PublishRelay<Void>()
    private var testFlag: Bool = false




    
    init(repository: CommentRepository, coordinator: ReplyCommentCoordinator) {
        self.repository = repository
        self.coordinator = coordinator
    }
    
    internal func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        var output = Output()
        dataSource = RxTableViewSectionedReloadDataSource<ReplyCommentTableviewDataSection>(
            configureCell: {  [weak self] dataSource, tableview, indexPath, item in
                guard let self = self else { return UITableViewCell() }
                guard let cell = tableview.dequeueReusableCell(withIdentifier: ReplyCommentTVC.identifier, for: indexPath) as? ReplyCommentTVC else { return UITableViewCell() }

                cell.setData(profilePath: dataSource[indexPath.section].items[indexPath.row].profileURL ?? "",
                             stepinId: dataSource[indexPath.section].items[indexPath.row].identifierName,
                             comment: dataSource[indexPath.section].items[indexPath.row].content,
                             createdAt: dataSource[indexPath.section].items[indexPath.row].createdAt,
                             likeCount: dataSource[indexPath.section].items[indexPath.row].likeCount,
                             isLiked: dataSource[indexPath.section].items[indexPath.row].alreadyLiked)
                
                // 나중에 수정 필요.
                if !self.commentViewFirstPresentFlag {
                    cell.skeletonAnimationPlay()
                }
  
                
                if self.commentViewFirstPresentFlag && self.skeletonFlag{
                    cell.hideSkeleton()
                    if !self.testFlag {
                        self.resultRelay.accept(self.commentResult)
                        self.testFlag = true
                    }
                }

                
                cell.likeButtonTapped = { state in
                    if state == -1 { //취소
                        self.commentResult[indexPath.section].items[indexPath.row].likeCount -= 1
                    } else {
                        self.commentResult[indexPath.section].items[indexPath.row].likeCount += 1
                    }
                    self.patchLikeButton(commentId: dataSource[indexPath.section].items[indexPath.row].commentID,
                                          indexPath: indexPath,
                                          state: state,
                                          input: input,
                                          disposeBag: disposeBag)
                }
                
                cell.profileImageViewTapped = {
                    self.coordinator?.dismiss()
                    //mypage이동
                    if dataSource[indexPath.section].items[indexPath.row].userID == UserDefaults.standard.string(forKey: UserDefaultKey.userId) {
                        self.coordinator?.pushToMyProfileView()
                    }
                    else { // other page 이동
                        self.coordinator?.pushToOtherProfileView(userId: dataSource[indexPath.section].items[indexPath.row].userID)
                    }
                }

                return cell
            })
        
        resultRelay
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] _ in
                output.headerOutputData.accept(self!.commentResult[0].header)
            })
            .disposed(by: disposeBag)
        
        resultRelay
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: input.tableView.rx.items(dataSource: dataSource!))
            .disposed(by: disposeBag)
        
        input.tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)

        
        input.viewWillAppear
            .subscribe { [weak self] _ in
                guard let self = self else {return}
                self.commentResult.append(self.dummySkeletonData)
                for _ in 0...7 {  // item 삽입
                    self.dummySkeletonData.items.append(self.dummyReply)
                }
                self.commentResult[0].items.append(contentsOf: self.dummySkeletonData.items) // 더미 데이터 넣기
                self.resultRelay.accept(self.commentResult)
                self.getComment(input: input, disposeBag: disposeBag) 
            }
            .disposed(by: disposeBag)
        
        

        //pagination
        input.tableView.rx.contentOffset.asObservable()
            .throttle(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] offset in
                guard let self = self else {return}
            

                if offset.y > input.tableView.contentSize.height - input.tableView.frame.height && offset.y > 0 {

                    guard !self.commentResult.isEmpty else {return}
                    if self.commentResult[0].items.count < 10 {
                        self.commentPage = 1
                    } else {
                        self.getComment(input: input, disposeBag: disposeBag)
                        print(self.commentResult[0].items.count)
                    }
                }
            })
            .disposed(by: disposeBag)

        
        //pull to refresh
        input.tableView.refreshControl?.rx.controlEvent(.valueChanged).asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                if input.tableView.refreshControl!.isRefreshing {
                    self.commentPage = 1
                    self.commentResult = []
                    self.getComment(input: input, disposeBag: disposeBag)
                    input.tableView.refreshControl!.endRefreshing()
               }
            })
            .disposed(by: disposeBag)
        
        
        
        input.didBackButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.backToCommentView()
            })
            .disposed(by: disposeBag)
        
        input.textField.textView.rx.text.orEmpty.asObservable()
            .subscribe(onNext: { [weak self] comment in
                self!.comment = comment
            })
            .disposed(by: disposeBag)
        
        input.textField.writeCommentButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.postCreateComment(input: input, disposeBag: disposeBag)
            })
            .disposed(by: disposeBag)
        

        
        
        self.headerLikeCompletion = { state in
            if state == -1 { //취소
                self.commentResult[0].header.likeCount -= 1
            } else {
                self.commentResult[0].header.likeCount += 1
            }
            self.patchLikeButton(commentId: self.commentId,
                                 indexPath: [0, 0],
                                 state: state,
                                 input: input,
                                 isHeader: true,
                                 disposeBag: disposeBag)
        }

        
        input.didDismissButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.dismiss()
            })
            .disposed(by: disposeBag)
        
        self.reportCompletion = { indexPath in
            self.replyCommentId = self.commentResult[indexPath.section].items[indexPath.row].commentID
            UIView.animate(withDuration: 0.5) {
                input.reportAlertView.alpha = 1
            } completion: { _ in
                input.reportAlertView.isHidden = false
            }
        }
        self.profileImageViewTapped = {
            print("\(self.userId)")
            self.coordinator?.dismiss()
            // mypage이동
            if self.userId == UserDefaults.standard.string(forKey: UserDefaultKey.userId) {
                self.coordinator?.pushToMyProfileView()
            }
            else { // other page 이동
                self.coordinator?.pushToOtherProfileView(userId: self.userId)
            }
        }
        
        input.reportAlertView.dontLikeReportButton.buttonTapCompletion = { content in
            self.reportContent = content
            self.reportComment(input: input, disposeBag: disposeBag)
        }
        input.reportAlertView.spamReportButton.buttonTapCompletion = { content in
            self.reportContent = content
            self.reportComment(input: input, disposeBag: disposeBag)
        }
        input.reportAlertView.nakedReportButton.buttonTapCompletion = { content in
            self.reportContent = content
            self.reportComment(input: input, disposeBag: disposeBag)
        }
        input.reportAlertView.fraoudReportButton.buttonTapCompletion = { content in
            self.reportContent = content
            self.reportComment(input: input, disposeBag: disposeBag)
        }
        
        deleteComment(input: input, disposeBag: disposeBag)
        

        
 

        return output
    }
    
    struct Input {
        let tableView: UITableView
        let viewDidLoad: Observable<Void>
        let viewDidAppear: Observable<Void>
        let viewWillAppear: Observable<Void>
        let textField: EditCommentTextView
        let commentView: UIView
        let didBackButtonTapped: Observable<Void>
        let didDismissButtonTapped: Observable<Void>
        let reportAlertView: ReportAlertView
        
    }
    struct Output {
        var headerOutputData = PublishRelay<Comment>()
    }
    
    //MARK: Connect API
    //토큰 리프레시
    private func refreshTokenObserver(apiState: CommentApiType,
                                      input: Input,
                                      indexPath: IndexPath = [0, 0],
                                      commentId: String = "",
                                      state: Int = 0,
                                      isHeader: Bool = false,
                                      disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .subscribe(onNext: { [weak self] result in
                switch apiState {
                case .getReply:
                    self?.repository?.getReplyComment(commentId: self!.commentId,
                                                     page: self!.commentPage)
                    .observe(on: MainScheduler.asyncInstance)
                    .subscribe(onNext: { [weak self] result in
                        if !result.items.isEmpty {
                            self?.commentPage += 1
                        }
                        if !self!.commentResult.isEmpty {
                            self!.commentResult[0].items.append(contentsOf: result.items)
                        } else {
                            self!.commentResult.append(contentsOf: [result])
                        }
                        self!.resultRelay.accept(self!.commentResult)
                    })
                    .disposed(by: disposeBag)
                case .createReply:
                    self!.repository?.postCreateReply(videoId: self!.videoId,
                                                     commentId: self!.commentId,
                                                     content: self!.comment)
                    .observe(on: MainScheduler.asyncInstance)
                    .subscribe(onNext: { [weak self] result in
                        if result.statusCode == 200 {
                            input.textField.textView.text = ""
                            input.commentView.endEditing(true)
                            self!.commentPage = 1
                            self!.commentResult = []
                            self?.getComment(input: input, disposeBag: disposeBag)
                        }
                    })
                    .disposed(by: disposeBag)
                    
                case .removeComment:
                    self!.repository?.deleteComment(commentId: self!.commentResult[indexPath.section].items[indexPath.row].commentID)
                        .observe(on: MainScheduler.asyncInstance)
                        .subscribe(onNext: { [weak self] data in
                            if data.statusCode == 200 {
                                self?.commentResult[indexPath.section].items.remove(at: indexPath.row)
                                self?.resultRelay.accept(self!.commentResult)
                            }
                        })
                        .disposed(by: disposeBag)
                    
                case .reportComment:
                    self!.repository?.postReportComment(commentId: self!.replyCommentId,
                                                        content: self!.reportContent)
                    .observe(on: MainScheduler.asyncInstance)
                    .subscribe(onNext: { [weak self] data in
                        if data.statusCode == 200 {
                            UIView.animate(withDuration: 0.5) {
                                input.reportAlertView.alpha = 0
                            } completion: { _ in
                                input.reportAlertView.isHidden = true
                            }
                        }
                    })
                    .disposed(by: disposeBag)
                    break
                case .likeComment:
                    self!.repository?.patchLikeComment(commentId: commentId, state: state)
                        .observe(on: MainScheduler.asyncInstance)
                        .subscribe(onNext: { [weak self] data in
                            //헤더의 경우
                            if isHeader {
                                if data.data.state == 1 {
                                    self?.commentResult[indexPath.section].header.alreadyLiked = true
                                } else {
                                    self?.commentResult[indexPath.section].header.alreadyLiked = false
                                }
                                input.tableView.reloadSections(IndexSet.init(integer: 0), with: .automatic)
                                if data.statusCode == 200 {
                                    print(data)
                                }
                            } else {
                                //일반 셀의 경우
                                if data.data.state == 1 {
                                    self?.commentResult[indexPath.section].items[indexPath.row].alreadyLiked = true
                                } else {
                                    self?.commentResult[indexPath.section].items[indexPath.row].alreadyLiked = false
                                }
                                self?.resultRelay.accept(self!.commentResult)
                                if data.statusCode == 200 {
                                    print(data)
                                }
                            }
                        })
                        .disposed(by: disposeBag)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func getComment(input: Input, disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap { _ in (self.repository?.getReplyComment(commentId: self.commentId, page: self.commentPage))!}
            .withUnretained(self)
            .subscribe { viewModel, result in

                if !self.commentViewFirstPresentFlag { // 처음 화면 띄우고 더미 데이터 비우기
                    self.commentResult[0].header = result.header
                    self.commentResult[0].items = []
                    self.commentPage = 0
                }
                
                if !result.items.isEmpty {
                    viewModel.commentPage += 1
                }

                if !viewModel.commentResult.isEmpty {
                    viewModel.commentResult[0].items.append(contentsOf: result.items)
                } else {
                    viewModel.commentResult.append(contentsOf: [result])
                }

                self.commentViewFirstPresentFlag = true
                self.headercommentViewFirstPresentFlag = true
                self.skeletonFlag = true
                self.testFlag = false
                viewModel.resultRelay.accept(viewModel.commentResult)
                
       
            }
            .disposed(by: disposeBag)
    }

    
    private func postCreateComment(input: Input, disposeBag: DisposeBag) {
        if self.tokenUtil.didTokenUpdate() {
            self.refreshTokenObserver(apiState: .createReply,
                                      input: input,
                                      disposeBag: disposeBag)
        } else {
            self.repository?.postCreateReply(videoId: self.videoId,
                                             commentId: self.commentId,
                                             content: self.comment)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] result in
                if result.statusCode == 200 {
                    input.textField.textView.text = ""
                    input.commentView.endEditing(true)
                    self?.coordinator?.replyViewController.initEditCommentViewConstraints()
                    self!.commentPage = 1
                    self!.commentResult = []
                    self?.getComment(input: input, disposeBag: disposeBag)
                }
            })
            .disposed(by: disposeBag)
        }
    }
    
    private func deleteComment(input: Input, disposeBag: DisposeBag) {
        self.deleteCompletion = { indexPath in
            if self.tokenUtil.didTokenUpdate() {
                self.refreshTokenObserver(apiState: .removeComment,
                                          input: input,
                                          indexPath: indexPath,
                                          disposeBag: disposeBag)
            } else {
                self.repository?.deleteComment(commentId: self.commentResult[indexPath.section].items[indexPath.row].commentID)
                    .observe(on: MainScheduler.asyncInstance)
                    .subscribe(onNext: { [weak self] data in
                        if data.statusCode == 200 {
                            self?.commentResult[indexPath.section].items.remove(at: indexPath.row)
                            self?.resultRelay.accept(self!.commentResult)
                        }
                    })
                    .disposed(by: disposeBag)
            }
        }
    }
    
    private func reportComment(input: Input, disposeBag: DisposeBag) {
        if self.tokenUtil.didTokenUpdate() {
            self.refreshTokenObserver(apiState: .reportComment,
                                      input: input,
                                      disposeBag: disposeBag)
        } else {
            self.repository?.postReportComment(commentId: self.replyCommentId,
                                               content: self.reportContent)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] data in
                if data.statusCode == 200 {
                    UIView.animate(withDuration: 0.5) {
                        input.reportAlertView.alpha = 0
                    } completion: { _ in
                        input.reportAlertView.isHidden = true
                    }
                }
            })
            .disposed(by: disposeBag)
        }
    }
    
    private func patchLikeButton(commentId: String,
                                 indexPath: IndexPath,
                                 state: Int,
                                 input: Input,
                                 isHeader: Bool = false,
                                 disposeBag: DisposeBag) {
        if self.tokenUtil.didTokenUpdate() {
            self.refreshTokenObserver(apiState: .likeComment,
                                      input: input,
                                      indexPath: indexPath,
                                      isHeader: isHeader,
                                      disposeBag: disposeBag)
        } else {
            self.repository?.patchLikeComment(commentId: commentId, state: state)
                .observe(on: MainScheduler.asyncInstance)
                .subscribe(onNext: { [weak self] data in
                    //헤더의 경우
                    if isHeader {
                        if data.data.state == 1 {
                            self?.commentResult[indexPath.section].header.alreadyLiked = true
                        } else {
                            self?.commentResult[indexPath.section].header.alreadyLiked = false
                        }
                        input.tableView.reloadSections(IndexSet.init(integer: 0), with: .automatic)
                        if data.statusCode == 200 {
                            print(data)
                        }
                    } else {
                        //일반 셀의 경우
                        if data.data.state == 1 {
                            self?.commentResult[indexPath.section].items[indexPath.row].alreadyLiked = true
                        } else {
                            self?.commentResult[indexPath.section].items[indexPath.row].alreadyLiked = false
                        }
                        self?.resultRelay.accept(self!.commentResult)
                        if data.statusCode == 200 {
                            print(data)
                        }
                    }
                })
                .disposed(by: disposeBag)
        }
    }
}
 
extension ReplyCommentViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return ScreenUtils.setWidth(value: 80)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ReplyHeaderView.identifier) as? ReplyHeaderView else {return UITableViewHeaderFooterView()}

        
        headerView.setData(profilePath: self.commentResult[0].header.profileURL ?? "",
                           stepinId: self.commentResult[0].header.identifierName,
                           comment: self.commentResult[0].header.content,
                           createdAt: self.commentResult[0].header.createdAt,
                           replyCount: self.commentResult[0].header.replyCount,
                           likeCount: self.commentResult[0].header.likeCount,
                           isLiked: self.commentResult[0].header.alreadyLiked)

        if !self.headercommentViewFirstPresentFlag {
            headerView.skeletonAnimationPlay()
        }

        if self.headercommentViewFirstPresentFlag && self.skeletonFlag{
            headerView.hideSkeleton()
            if !self.testFlag {
                self.resultRelay.accept(self.commentResult)
                self.testFlag = true
            }
        }

        self.userId = self.commentResult[0].header.userID
        headerView.likeButtonTapped = { state in
            guard let completion = self.headerLikeCompletion else {return}
            completion(state)
        }
        headerView.profileImageViewTapped = {
            guard let completion = self.profileImageViewTapped else {return}
            completion()
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let removeAction = UIContextualAction(style: .normal, title: "", handler: { action, view, completionHaldler in
            guard let completion = self.deleteCompletion else {return}
            completion(indexPath)
            completionHaldler(true)
        })
        
        removeAction.backgroundColor = .stepinRed100
        removeAction.image = ImageLiterals.icDelete
        
        let reportAction = UIContextualAction(style: .normal, title: "", handler: { action, view, completionHaldler in
            guard let completion = self.reportCompletion else {return}
            completion(indexPath)
            completionHaldler(true)
        })
        reportAction.backgroundColor = .stepinWhite40
        reportAction.image = ImageLiterals.icWhiteReport
        
        if self.commentResult[indexPath.section].items[indexPath.row].userID == UserDefaults.standard.string(forKey: UserDefaultKey.userId) {
            return UISwipeActionsConfiguration(actions: [removeAction, reportAction])
        } else {
            return UISwipeActionsConfiguration(actions: [reportAction])
        }
    }
}
