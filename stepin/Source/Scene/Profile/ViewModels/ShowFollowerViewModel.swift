import Foundation
import RxCocoa
import RxSwift
import RxDataSources
import RxGesture

enum SearchBarState {
    case hidden
    case show
}

final class ShowFollowerViewModel {
    private var deleteRow: Int = 0
    private var tokenUtil = TokenUtils()
    internal weak var coordinator: ShowFollowerCoordinator?
    private var userRepository: UserRepository?
    var authRepository: AuthRepository?
    var followerViewType: FollowerViewType?
    
    internal var userId = ""
    private var followerStepinId = ""
    private var followingStepinId = ""
    //일반적인 뷰 로드
    private var followingListData: [FollowingTableviewDataSection] = []
    private var followingRelay = PublishRelay<[FollowingTableviewDataSection]>()
    private var followingPage: Int = 1
    
    private var followerListData: [FollowerTableviewDataSection] = []
    private var followerRelay = PublishRelay<[FollowerTableviewDataSection]>()
    private var followerPage: Int = 1
    
    //서치 뷰 로드
    private var isFollowSearch: Bool = false
    private var followingSearchListData: [FollowingTableviewDataSection] = []
    private var followingSearchPage: Int = 1

    private var isFollowingSearch: Bool = false
    private var followerSearchListData: [FollowerTableviewDataSection] = []
    private var followerSearchPage: Int = 1

    
    init(coordinator: ShowFollowerCoordinator, repository: UserRepository) {
        self.coordinator = coordinator
        self.userRepository = repository
        self.authRepository = AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    }
    
    struct Input {
        let didViewAppear: Observable<Void>
        let didInitFollowersTableView: UITableView
        let didInitFollowingTableView: UITableView
        let didScrollViewHorizontalScrolled: Observable<CGPoint>
        let didFollowerSearchBarUsed: Observable<String>
        let didFollowingSearchBarUsed: Observable<String>
        let didDeleteFollowerTapped: Observable<Void>
        let didCancelDeleteFollowerButtonTapped: Observable<Void>
        let didDeleteUserAlertView: DeleteUserAlertView
        let navigationView: TitleNavigationView
    }
    
    struct Output {
        var searchHeaderState = PublishRelay<SearchBarState>()
        var tabbarLeftPadding = PublishRelay<CGFloat>()
        var didRemoveFollowerButtonClicked = PublishRelay<Bool>()
        var didCancelDeleteFollowerButton = PublishRelay<Bool>()
    }
    
    internal func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        print(self.userId)
        let output = Output()
        let followerTableViewDataSource = RxTableViewSectionedReloadDataSource<FollowerTableviewDataSection>(
        configureCell: {[weak self] dataSource, tableview, indexPath, item in
            guard let cell = tableview.dequeueReusableCell(withIdentifier: FollowerTVC.identifier) as? FollowerTVC else { return UITableViewCell() }
            cell.cellType = self?.followerViewType
            cell.setData(profiePath: dataSource[indexPath.section].items[indexPath.row].profileURL ?? "",
                         stepinId: dataSource[indexPath.section].items[indexPath.row].identifierName,
                         isFollow: dataSource[indexPath.section].items[indexPath.row].followed,
                         tag: indexPath.row)
            //나 팔로우한놈 제거
            cell.deleteButtonCompletion = { row in
                self?.deleteRow = row
                input.didDeleteUserAlertView.setData(profilePath: dataSource[indexPath.section].items[indexPath.row].profileURL ?? "",
                                                     userName: dataSource[indexPath.section].items[indexPath.row].identifierName)
                output.didRemoveFollowerButtonClicked.accept(true)
            }
            //follower cell의 팔로우 버튼 눌렀을 때
            cell.followButtonCompletion = { row in
                self?.patchFollowUser(input: input,
                                      disposeBag: disposeBag,
                                      indexPath: row,
                                      state: 1,
                                      type: .follower)
            }
            
          return cell
        })
        
        let followingTableViewDataSource = RxTableViewSectionedReloadDataSource<FollowingTableviewDataSection>(
            configureCell: {[weak self] dataSource, tableview, indexPath, item in
                guard let cell = tableview.dequeueReusableCell(withIdentifier: FollowingTVC.identifier) as? FollowingTVC else { return UITableViewCell() }
                cell.setData(profiePath: dataSource[indexPath.section].items[indexPath.row].profileURL ?? "",
                             stepinId: dataSource[indexPath.section].items[indexPath.row].identifierName,
                             isFollow: dataSource[indexPath.section].items[indexPath.row].followed,
                             tag: indexPath.row)
                
                cell.followButtonCompletion = { row, state in
                    //1 == following , -1 == unfollow
                    let followState: Int = state ? -1: 1
                    print(followState, row)
                    self?.patchFollowUser(input: input,
                                          disposeBag: disposeBag,
                                          indexPath: row,
                                          state: followState,
                                          type: .following)
                }
                
              return cell
            })
        
        self.getUserInfo(input: input, disposeBag: disposeBag)
        
        
        input.didFollowerSearchBarUsed
            .throttle(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] string in
                self?.followerStepinId = string
                if string != "" {
                    self?.isFollowSearch = true
                    self?.followerSearchListData = []
                    self?.followerListData = []
                    self?.followerPage = 1
                    self?.followerSearchPage = 1
                    self?.getSearchFollowerData(input: input, disposeBag: disposeBag, stepinId: string)
                } else {
                    self?.isFollowSearch = false
                    self?.followerSearchListData = []
                    self?.followerSearchPage = 1
                    self?.getFollowerData(input: input, disposeBag: disposeBag)
                }
            })
            .disposed(by: disposeBag)

        
        input.didFollowingSearchBarUsed
            .subscribe(onNext: { [weak self] string in
                self?.followingStepinId = string
                if string != "" {
                    self?.isFollowingSearch = true
                    self?.followingListData = []
                    self?.followingSearchListData = []
                    self?.followingPage = 1
                    self?.followingSearchPage = 1
                    self?.getSearchFollowingData(input: input, disposeBag: disposeBag, stepinId: string)
                } else {
                    self?.isFollowingSearch = false
                    self?.followingSearchListData = []
                    self?.followingSearchPage = 1
                    self?.getFollowingData(input: input, disposeBag: disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        input.didInitFollowersTableView.refreshControl?.rx.controlEvent(.valueChanged).asObservable()
            .subscribe(onNext: { [weak self] in
                if self!.isFollowSearch {
                    self!.followerSearchListData = []
                    self!.followerSearchPage = 1
                    self?.getSearchFollowerData(input: input, disposeBag: disposeBag, stepinId: self!.followerStepinId)
                    input.didInitFollowersTableView.refreshControl?.endRefreshing()
                } else {
                    self!.followerListData = []
                    self!.followerPage = 1
                    self?.getFollowerData(input: input, disposeBag: disposeBag)
                    input.didInitFollowersTableView.refreshControl?.endRefreshing()
                }
            })
            .disposed(by: disposeBag)
        
        input.didInitFollowingTableView.refreshControl?.rx.controlEvent(.valueChanged).asObservable()
            .subscribe(onNext: {[weak self] in
                if self!.isFollowingSearch {
                    self!.followingSearchListData = []
                    self!.followingSearchPage = 1
                    self?.getSearchFollowingData(input: input, disposeBag: disposeBag, stepinId: self!.followingStepinId)
                    input.didInitFollowingTableView.refreshControl?.endRefreshing()
                } else {
                    self!.followingListData = []
                    self!.followingPage = 1
                    self?.getFollowingData(input: input, disposeBag: disposeBag)
                    input.didInitFollowingTableView.refreshControl?.endRefreshing()
                }
            })
            .disposed(by: disposeBag)
        

        input.didInitFollowersTableView.rx.willBeginDecelerating.asObservable()
            .subscribe(onNext: { [weak self] in
                if input.didInitFollowersTableView.panGestureRecognizer.translation(in: input.didInitFollowersTableView).y < 0 {
                    output.searchHeaderState.accept(.hidden)
                } else {
                    output.searchHeaderState.accept(.show)
                }
            })
            .disposed(by: disposeBag)
        
        input.didInitFollowingTableView.rx.willBeginDecelerating.asObservable()
            .subscribe(onNext: { [weak self] in
                if input.didInitFollowingTableView.panGestureRecognizer.translation(in: input.didInitFollowersTableView).y < 0 {
                    output.searchHeaderState.accept(.hidden)
                } else {
                    output.searchHeaderState.accept(.show)
                }
            })
            .disposed(by: disposeBag)
        
        input.didScrollViewHorizontalScrolled
            .subscribe(onNext: { [weak self] point in
                let offsetY = min(point.x / 2, UIScreen.main.bounds.width / 2)
                let value = max(ScreenUtils.setWidth(value: 18), offsetY)
                output.tabbarLeftPadding.accept(value)
            })
        
        //페이징 관련
        input.didInitFollowersTableView.rx.contentOffset.asObservable()
            .throttle(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] offset in
                if offset.y > input.didInitFollowersTableView.contentSize.height - input.didInitFollowersTableView.frame.height && offset.y != 0{
                    if !self!.isFollowSearch {
                        self?.getFollowerData(input: input, disposeBag: disposeBag)
                    } else {
                        self?.getSearchFollowerData(input: input, disposeBag: disposeBag, stepinId: self!.followerStepinId)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        input.didInitFollowingTableView.rx.contentOffset.asObservable()
            .throttle(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] offset in
                if offset.y > input.didInitFollowingTableView.contentSize.height - input.didInitFollowingTableView.frame.height && offset.y != 0 {
                    if !self!.isFollowingSearch {
                        self?.getFollowingData(input: input, disposeBag: disposeBag)
                    } else {
                        self?.getSearchFollowingData(input: input, disposeBag: disposeBag, stepinId: self!.followingStepinId)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        //팔로워 삭제 관련 알러트 뷰
        input.didDeleteFollowerTapped
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] in
                self!.deleteFollowUser(input: input, disposeBag: disposeBag, indexPath: self!.deleteRow)
                output.didCancelDeleteFollowerButton.accept(true)
            })
            .disposed(by: disposeBag)
        
        input.didCancelDeleteFollowerButtonTapped
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] in
                output.didCancelDeleteFollowerButton.accept(true)
            })
            .disposed(by: disposeBag)
        
        //셀 선택시
        input.didInitFollowersTableView.rx.itemSelected.asObservable()
            .subscribe(onNext: { [weak self] indexPath in
                if self!.isFollowSearch {
                    self?.coordinator?.pushToOtherProfilePage(userID: self?.followerSearchListData[0].items[indexPath.row].userID ?? "")
                } else {
                    self?.coordinator?.pushToOtherProfilePage(userID: self?.followerListData[0].items[indexPath.row].userID ?? "")
                }
            })
        input.didInitFollowingTableView.rx.itemSelected.asObservable()
            .subscribe(onNext: { [weak self] indexPath in
                if self!.isFollowingSearch {
                    self?.coordinator?.pushToOtherProfilePage(userID: self?.followingSearchListData[0].items[indexPath.row].userID ?? "")
                } else {
                    self?.coordinator?.pushToOtherProfilePage(userID: self?.followingListData[0].items[indexPath.row].userID ?? "")
                }
            })
        
        //뷰 새로 그려줌
        self.followingRelay
            .bind(to: input.didInitFollowingTableView.rx.items(dataSource: followingTableViewDataSource))
            .disposed(by: disposeBag)
        
        self.followerRelay
            .bind(to: input.didInitFollowersTableView.rx.items(dataSource: followerTableViewDataSource))
            .disposed(by: disposeBag)
        
        return output
    }
    
    private func getUserInfo(input: Input, disposeBag: DisposeBag) {
        self.authRepository?.postRefreshToken()
            .withUnretained(self)
            .flatMap { _ in (self.userRepository?.getUserProfile(type: "id", data: self.userId))!}
            .withUnretained(self)
            .subscribe(onNext: { (_, data) in
                DispatchQueue.main.async {
                    input.navigationView.setTitle(title: data.data.identifierName)
                }
            })
            .disposed(by: disposeBag)
    }

    //팔로잉 리스트
    private func getFollowingData(input: Input, disposeBag: DisposeBag) {
        self.authRepository?.postRefreshToken()
            .withUnretained(self)
            .flatMap { _ in (self.userRepository?.getUserFollowingList(userId: self.userId, page: self.followingPage))!}
            .withUnretained(self)
            .subscribe(onNext: { (_, result) in
                if !result.items.isEmpty {
                    self.followingPage += 1
                }
                if !self.followingListData.isEmpty {
                    self.followingListData[0].items.append(contentsOf: result.items)
                } else {
                    self.followingListData.append(contentsOf: [result])
                }
                self.followingRelay.accept(self.followingListData)
            })
            .disposed(by: disposeBag)
    }
    
    private func getSearchFollowerData(input: Input, disposeBag: DisposeBag, stepinId: String) {
        self.authRepository?.postRefreshToken()
            .withUnretained(self)
            .flatMap { _ in (self.userRepository?.getSearchFollowerUserList(userId: self.userId,
                                                                            stepinId: stepinId,
                                                                            page: self.followerSearchPage))!}
            .withUnretained(self)
            .subscribe(onNext: { (_, result) in
                if !result.items.isEmpty {
                    self.followerSearchPage += 1
                }
                if !self.followerSearchListData.isEmpty {
                    self.followerSearchListData[0].items.append(contentsOf: result.items)
                } else {
                    self.followerSearchListData.append(contentsOf: [result])
                }
                self.followerRelay.accept(self.followerSearchListData)
            })
            .disposed(by: disposeBag)
    }

    
    //팔로워 리스트
    private func getFollowerData(input: Input, disposeBag: DisposeBag) {
        self.authRepository?.postRefreshToken()
            .withUnretained(self)
            .flatMap { _ in (self.userRepository?.getUserFollowerList(userId: self.userId,
                                                                      page: self.followerPage))!}
            .withUnretained(self)
            .subscribe(onNext: { (_, result) in
                if !result.items.isEmpty {
                    self.followerPage += 1
                }
                if !self.followerListData.isEmpty {
                    self.followerListData[0].items.append(contentsOf: result.items)
                } else {
                    self.followerListData.append(contentsOf: [result])
                }
                self.followerRelay.accept(self.followerListData)
                print(self.followerListData)
            })
            .disposed(by: disposeBag)
    }
    
    private func getSearchFollowingData(input: Input, disposeBag: DisposeBag, stepinId: String) {
        self.authRepository?.postRefreshToken()
            .withUnretained(self)
            .flatMap { _ in ( self.userRepository?.getSearchFollowingUserList(userId: self.userId, stepinId: stepinId, page: self.followingSearchPage))!}
            .withUnretained(self)
            .subscribe(onNext: { (_, result) in
                if !result.items.isEmpty {
                    self.followingSearchPage += 1
                }
                if !self.followingSearchListData.isEmpty {
                    self.followingSearchListData[0].items.append(contentsOf: result.items)
                } else {
                    self.followingSearchListData.append(contentsOf: [result])
                }
                self.followingRelay.accept(self.followingSearchListData)
            })
            .disposed(by: disposeBag)
    }
    
    //날 팔로우한 유저 삭제
    private func deleteFollowUser(input: Input, disposeBag: DisposeBag, indexPath: Int) {
        let followedId = self.followerListData[0].items[indexPath].followID
        self.authRepository?.postRefreshToken()
            .withUnretained(self)
            .flatMap { _ in ( self.userRepository?.deleteMyFollower(followId: followedId))!}
            .withUnretained(self)
            .subscribe(onNext: { (_, result) in
                if result.statusCode == 200 {
                    self.followerListData[0].items.remove(at: indexPath)
                    self.followerRelay.accept(self.followerListData)
                } else {
                    print("삭제 실패")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func patchFollowUser(input: Input, disposeBag: DisposeBag, indexPath: Int, state: Int, type: DidTapFollowViewType) {
        var userId = ""
        if type == .following {
            //검색해서 팔로우 진행할 때
            if self.followingListData.count == 0 && isFollowingSearch {
                userId = self.followingSearchListData[0].items[indexPath].userID
            } else {
                userId = self.followingListData[0].items[indexPath].userID
            }
        } else {
            if self.followerListData.count == 0 && isFollowSearch {
                userId = self.followerSearchListData[0].items[indexPath].userID
            } else {
                userId = self.followerListData[0].items[indexPath].userID
            }
        }
        
        self.authRepository?.postRefreshToken()
            .withUnretained(self)
            .flatMap { _ in ( self.userRepository?.patchFollowUser(userId: userId, state: state))!}
            .subscribe(onNext: { [weak self] result in
                print(result)
                if result.data.state == 1 {
                    if type == .follower {
                        if self?.followerSearchListData.count == 0 && self!.isFollowSearch {
                            self?.followerSearchListData[0].items[indexPath].followed = true
                            self?.followerRelay.accept(self!.followerSearchListData)
                        } else {
                            //팔로우 상태 변경
                            self?.followerListData[0].items[indexPath].followed = true
                            self?.followerRelay.accept(self!.followerListData)
                        }
                    } else {
                        if self?.followingListData.count == 0 && self!.isFollowingSearch {
                            self?.followingSearchListData[0].items[indexPath].followed = true
                            self?.followingRelay.accept(self!.followingSearchListData)
                        } else {
                            self?.followingListData[0].items[indexPath].followed = true
                            self?.followingRelay.accept(self!.followingListData)
                        }
                    }
                } else {
                    if type == .follower {
                        if self?.followerSearchListData.count == 0 && self!.isFollowSearch {
                            self?.followerSearchListData[0].items[indexPath].followed = false
                            self?.followerRelay.accept(self!.followerSearchListData)
                        } else {
                            //팔로우 상태 변경
                            self?.followerListData[0].items[indexPath].followed = false
                            self?.followerRelay.accept(self!.followerListData)
                        }
                    } else {
                        if self?.followingListData.count == 0 && self!.isFollowingSearch {
                            self?.followingSearchListData[0].items[indexPath].followed = false
                            self?.followingRelay.accept(self!.followingSearchListData)
                        } else {
                            self?.followingListData[0].items[indexPath].followed = false
                            self?.followingRelay.accept(self!.followingListData)
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}
