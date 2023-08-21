import Foundation
import RxCocoa
import RxSwift
import RxDataSources

final class InboxViewModel: NSObject {
    internal weak var coordinator: InboxCoordinator?
    private var disposeBag: DisposeBag?
    
    internal var authRepository: AuthRepository = AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    internal var inboxRepository: InboxRepository = InboxRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    internal var videoRepository: VideoRepository = VideoRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    
    
    private var inboxDataSource: RxTableViewSectionedReloadDataSource<InboxTableviewDataSection>?
    private var inboxData: [InboxTableviewDataSection] = []
    private var inboxRelay = PublishRelay<[InboxTableviewDataSection]>()
    private var inboxPage: Int = 1
    
    init(coordinator: InboxCoordinator) {
        self.coordinator = coordinator
    }
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let tableView: UITableView
        let backButtonTapped: Observable<Void>
    }
    
    struct Output {
        
    }
    
    internal func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        self.disposeBag = disposeBag
        self.inboxDataSource = RxTableViewSectionedReloadDataSource<InboxTableviewDataSection>(
        configureCell: { [weak self] dataSource, tableview, indexPath, item in
            guard let cell = tableview.dequeueReusableCell(withIdentifier: InboxTVC.identifier) as? InboxTVC else { return UITableViewCell() }
            cell.setData(userNickName: dataSource[indexPath.section].items[indexPath.row].data.identifierName ?? "",
                         description: dataSource[indexPath.section].items[indexPath.row].data.content ?? "",
                         profilePath: dataSource[indexPath.section].items[indexPath.row].data.profileURL ?? "",
                         followed: dataSource[indexPath.section].items[indexPath.row].data.followed ?? false,
                         energy: dataSource[indexPath.section].items[indexPath.row].data.compensation ?? 0,
                         musicName: dataSource[indexPath.section].items[indexPath.row].data.title ?? "",
                         rank: dataSource[indexPath.section].items[indexPath.row].data.rank ?? 0,
                         type: dataSource[indexPath.section].items[indexPath.row].type,
                         createdAt: dataSource[indexPath.section].items[indexPath.row].createdAt)
            cell.profileImageTapCompletion = { [weak self] in
                guard let strongSelf = self else {return}
                strongSelf.coordinator?.pushToProfileView(userId: dataSource[indexPath.section].items[indexPath.row].data.userId ?? "")
                
            }
          return cell
        })
        
        input.tableView
            .rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        input.viewWillAppear
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.inboxData = []
                self.inboxPage = 1
                self.getInboxData(disposeBag: disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.backButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.coordinator?.pop()
            })
            .disposed(by: disposeBag)
        
        input.tableView.rx.contentOffset.asObservable()
            .withUnretained(self)
            .skip(1)
            .throttle(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { (_, offset) in
                if offset.y > input.tableView.contentSize.height - input.tableView.frame.height {
                    self.getInboxData(disposeBag: disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        self.inboxRelay
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: input.tableView.rx.items(dataSource: self.inboxDataSource!))
            .disposed(by: disposeBag)
        
        return output
    }
    
    private func getInboxData(disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in (self?.inboxRepository.getInboxData(page: self!.inboxPage))! }
            .subscribe(onNext: { [weak self] result in
                if !result.items.isEmpty {
                    self?.inboxPage += 1
                }
                if !self!.inboxData.isEmpty {
                    self!.inboxData[0].items.append(contentsOf: result.items)
                } else {
                    self!.inboxData.append(contentsOf: [result])
                }
                print(self!.inboxData)
                self!.inboxRelay.accept(self!.inboxData)
            })
            .disposed(by: disposeBag)
    }
    
    private func getVideoInfo(videoId: String,
                              disposeBag: DisposeBag) {
        self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap { _ in self.videoRepository.getVideoInfo(videoId: videoId)}
            .subscribe(onNext: { (result) in
                DispatchQueue.main.async {
                    self.coordinator?.pushToVideoView(videoData: [result])
                }
            })
            .disposed(by: disposeBag)
    }
    
}

extension InboxViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //추후 수정 지금은 급함
        switch self.inboxData[indexPath.section].items[indexPath.row].type {
        //우선 비디오까지만 넘기기
        case InboxType.likeComment, InboxType.likeVideo, InboxType.commentType, InboxType.replyType:
            self.getVideoInfo(videoId: self.inboxData[indexPath.section].items[indexPath.row].data.videoId ?? "",
                              disposeBag: self.disposeBag!)
            
        case InboxType.rankIn, InboxType.rankOut:
            self.coordinator?.pushToDanceView(danceId: self.inboxData[indexPath.section].items[indexPath.row].data.danceId ?? "")
            break
        case InboxType.superShortForm:
            break
        default:
            break
        }
    }
}
