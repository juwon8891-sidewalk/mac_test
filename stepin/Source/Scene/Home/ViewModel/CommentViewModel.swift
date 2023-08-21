import Foundation
import SkeletonView
import RxSwift
import RxRelay
import RxDataSources

final class CommentViewModel: NSObject {
    let tokenUtil = TokenUtils()
    var repository: CommentRepository?
    var commentCoordinator: CommentViewCoordinator?
    var authRepository = AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    
    private var dataSource: RxTableViewSectionedReloadDataSource<CommentTableviewDataSection>?
    internal var videoId: String = ""
    private var comment: String = ""
    private var commentId: String = ""
    private var reportContent: String = ""
    private var commentPage: Int = 1
    

    private var dummyComment: Comment = Comment(commentID: "\t\t",
                                                userID: "\t\t",
                                                identifierName: "\t\t",
                                                name: "\t\t",
                                                profileURL: "",
                                                content: "\t\t",
                                                likeCount: 10,
                                                replyCount: 1,
                                                alreadyLiked: true,
                                                alreadyBlocked: true,
                                                createdAt: "2023-06-09T06:30:28.707Z") //
    
    private var dummySkeletonData: CommentTableviewDataSection = CommentTableviewDataSection(items: [])
    private var commentResult: [CommentTableviewDataSection] = [.init(items: [])]
    private var resultRelay = PublishRelay<[CommentTableviewDataSection]>()
    
    

    
    internal var deleteCompletion: ((IndexPath) -> Void)?
    internal var reportCompletion: ((IndexPath) -> Void)?
    private var commentViewFirstPresentFlag: Bool = false
    private var skeletonFlag: Bool = false
    private var testFlag: Bool = false
    private var dummyTableViewReflect = PublishRelay<Void>()


    init(repository: CommentRepository, coordinator: CommentViewCoordinator) {
        self.repository = repository
        self.commentCoordinator = coordinator
    }
    
    internal func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        var output = Output()
        dataSource = RxTableViewSectionedReloadDataSource<CommentTableviewDataSection>(
            configureCell: {  [weak self] dataSource, tableview, indexPath, item in
                guard let self = self else { return UITableViewCell() }
                guard let cell = tableview.dequeueReusableCell(withIdentifier: CommentsTVC.identifier, for: indexPath) as? CommentsTVC else { return UITableViewCell() }
                
                
                cell.setData(profilePath: dataSource[indexPath.section].items[indexPath.row].profileURL ?? "",
                             stepinId: dataSource[indexPath.section].items[indexPath.row].identifierName,
                             comment: dataSource[indexPath.section].items[indexPath.row].content,
                             createdAt: dataSource[indexPath.section].items[indexPath.row].createdAt,
                             replyCount: dataSource[indexPath.section].items[indexPath.row].replyCount,
                             likeCount: dataSource[indexPath.section].items[indexPath.row].likeCount,
                             isLiked: dataSource[indexPath.section].items[indexPath.row].alreadyLiked)
                print(self.commentViewFirstPresentFlag, self.skeletonFlag)
                
                // 나중에 수정 필요. 
                if !self.commentViewFirstPresentFlag {
                    cell.skeletonAnimationPlay()
                }
                
                if self.commentViewFirstPresentFlag && self.skeletonFlag {
                    cell.hideSkeleton()
                    
                    if !self.testFlag {
                        self.resultRelay.accept(self.commentResult)
                        self.testFlag = true
                    }
                    
                }


                cell.commentsButtonTapped = {
                    self.commentCoordinator?.pushToReplyCommentVC(commentId: dataSource[indexPath.section].items[indexPath.row].commentID)
                    self.commentCoordinator?.commentViewController.removeNotification()
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
                    self.commentCoordinator?.dismiss()
                    //mypage이동
                    if dataSource[indexPath.section].items[indexPath.row].userID == UserDefaults.standard.string(forKey: UserDefaultKey.userId) {
                        self.commentCoordinator?.pushToMyProfileView()
                    }
                    else { // other page 이동
                        self.commentCoordinator?.pushToOtherProfileView(userId: dataSource[indexPath.section].items[indexPath.row].userID)
                    }
                }
                return cell
            })
        
        resultRelay
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: input.tableView.rx.items(dataSource: dataSource!))
            .disposed(by: disposeBag)
        
        input.tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        input.viewWillAppear
            .subscribe {  [weak self] _ in
                guard let self = self else {return}
                for _ in 0...7 {  // item 삽입
                    self.dummySkeletonData.items.append(self.dummyComment)
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
        
        input.textField.textView.rx.text.orEmpty.asObservable()
            .subscribe(onNext: { [weak self] comment in
                self!.comment = comment
            })
            .disposed(by: disposeBag)
        
        input.textField.writeCommentButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] comment in
                guard input.textField.textView.text != "" else {
                    return
                }
                self?.postCreateComment(input: input, disposeBag: disposeBag)
                
            })
            .disposed(by: disposeBag)
        


        input.didDismissButtonTapped
            .subscribe(onNext: { [weak self] in
                self?.commentCoordinator?.dismiss()
            })
            .disposed(by: disposeBag)
        
        self.reportCompletion = { indexPath in
            input.commentView.endEditing(true)
            self.commentId = self.commentResult[indexPath.section].items[indexPath.row].commentID
            UIView.animate(withDuration: 0.5) {
                input.reportAlertView.alpha = 1
            } completion: { _ in
                input.reportAlertView.isHidden = false
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
    
    
    internal struct Input {
        let tableView: UITableView
        let viewDidLoad: Observable<Void>
        let viewDidAppear: Observable<Void>
        let viewWillAppear: Observable<Void>
        let textField: EditCommentTextView
        let commentView: UIView
        let didDismissButtonTapped: Observable<Void>
        let reportAlertView: ReportAlertView
    }
    internal struct Output {
    }

    //MARK: Connect API
    //토큰 리프레시
    private func refreshTokenObserver(apiState: CommentApiType,
                                      input: Input,
                                      indexPath: IndexPath = [0, 0],
                                      commentId: String = "",
                                      state: Int = 0,
                                      disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .subscribe(onNext: { [weak self] result in
                switch apiState {
                case .getComment:
                    self!.repository?.getComment(videoId: self!.videoId,
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
                    
                case .createComment:
    
                    self!.repository?.postCreateComment(videoId: self!.videoId,
                                                       content: self!.comment)
                    .observe(on: MainScheduler.asyncInstance)
                    .subscribe(onNext: {[weak self] result in
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
                    self!.repository?.postReportComment(commentId: self!.commentId,
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
                    
                case .likeComment:
                    self!.repository?.patchLikeComment(commentId: commentId, state: state)
                        .observe(on: MainScheduler.asyncInstance)
                        .subscribe(onNext: { [weak self] data in
                            if data.data.state == 1 {
                                self?.commentResult[indexPath.section].items[indexPath.row].alreadyLiked = true
                            } else {
                                self?.commentResult[indexPath.section].items[indexPath.row].alreadyLiked = false
                            }
                            self?.resultRelay.accept(self!.commentResult)
                            if data.statusCode == 200 {
                                print(data)
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
            .flatMap { _ in (self.repository?.getComment(videoId: self.videoId, page: self.commentPage))! }
            .withUnretained(self)
            .subscribe(onNext: {  (viewModel,result) in
                
                
                if !viewModel.commentViewFirstPresentFlag { // 처음 화면 띄우고 더미 데이터 비우기
                    viewModel.commentResult[0].items = []
                    viewModel.commentPage = 0
                }

                if !result.items.isEmpty {
                    viewModel.commentPage += 1
                }
                if !viewModel.commentResult.isEmpty {
                    viewModel.commentResult[0].items.append(contentsOf: result.items)
                } else {
                    viewModel.commentResult.append(contentsOf: [result])
                }
                viewModel.commentViewFirstPresentFlag = true
                viewModel.skeletonFlag = true
                viewModel.testFlag = false
                viewModel.resultRelay.accept(viewModel.commentResult)
                
            })
            .disposed(by: disposeBag)
    }

    
    
    private func postCreateComment(input: Input, disposeBag: DisposeBag) {
        if self.tokenUtil.didTokenUpdate() {
            self.refreshTokenObserver(apiState: .createComment,
                                      input: input,
                                      disposeBag: disposeBag)
        } else {
            self.repository?.postCreateComment(videoId: self.videoId,
                                               content: self.comment)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: {[weak self] result in
                if result.statusCode == 200 {
                    input.textField.textView.text = ""
                    input.textField.setTextviewPlaceHolder()
                    input.commentView.endEditing(true)
                    self?.commentCoordinator?.commentViewController.initEditCommentViewConstraints()
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
            self.repository?.postReportComment(commentId: self.commentId,
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
                                 disposeBag: DisposeBag) {
        if self.tokenUtil.didTokenUpdate() {
            self.refreshTokenObserver(apiState: .likeComment,
                                      input: input,
                                      indexPath: indexPath,
                                      disposeBag: disposeBag)
        } else {
            self.repository?.patchLikeComment(commentId: commentId, state: state)
                .observe(on: MainScheduler.asyncInstance)
                .subscribe(onNext: { [weak self] data in
                    if data.data.state == 1 {
                        self?.commentResult[indexPath.section].items[indexPath.row].alreadyLiked = true
                    } else {
                        self?.commentResult[indexPath.section].items[indexPath.row].alreadyLiked = false
                    }
                    self?.resultRelay.accept(self!.commentResult)
                    if data.statusCode == 200 {
                        print(data)
                    }
                })
                .disposed(by: disposeBag)
        }
    }
    
}
 
extension CommentViewModel: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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


