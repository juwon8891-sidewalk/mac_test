import Foundation
import RxCocoa
import RxSwift
import RxDataSources

final class ManageBlockViewModel {
    private var tokenUtil = TokenUtils()
    internal weak var coordinator: BlockUserCoordinator?
    private var userRepository: UserRepository?
    
    private var blockUserList: [BlockTableviewDataSection] = []
    private var blockUserRelay = PublishRelay<[BlockTableviewDataSection]>()
    private var blockUserPage: Int = 1
    
    
    init(coordinator: BlockUserCoordinator, userRepository: UserRepository) {
        self.coordinator = coordinator
        self.userRepository = userRepository
    }
    
    struct Input {
        let viewDidAppear: Observable<Void>
        let didInitTableView: UITableView
    }
    
    struct Output {
        var isTableViewEmpty = PublishRelay<Bool>()
    }
    
    internal func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        let dataSource = RxTableViewSectionedReloadDataSource<BlockTableviewDataSection>(
        configureCell: {[weak self] dataSource, tableview, indexPath, item in
            guard let cell = tableview.dequeueReusableCell(withIdentifier: BlockUserTVC.identifier) as? BlockUserTVC else { return UITableViewCell() }
            cell.setData(profilePath: dataSource[indexPath.section].items[indexPath.row].profileURL ?? "",
                         stepinId: dataSource[indexPath.section].items[indexPath.row].identifierName,
                         isBlocked: dataSource[indexPath.section].items[indexPath.row].isBlocked,
                         tag: indexPath.row)
            cell.blockButtonCompletion = { row, state in
                let blockState = state ? -1: 1
                self?.postBlockUser(input: input,
                                    disposeBag: disposeBag,
                                    row: row,
                                    state: blockState)
            }
          return cell
        })
        
        input.viewDidAppear
            .subscribe(onNext: { [weak self] in
                self?.getBlockUserList(input: input, disposeBag: disposeBag)
            })
            .disposed(by: disposeBag)
        
        //pagination
        input.didInitTableView.rx.contentOffset.asObservable()
            .throttle(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] offset in
                if offset.y > input.didInitTableView.contentSize.height - input.didInitTableView.frame.height {
                    self?.getBlockUserList(input: input, disposeBag: disposeBag)
                }
            })
        
        //pull to refresh
        input.didInitTableView.refreshControl?.rx.controlEvent(.valueChanged).asObservable()
            .subscribe(onNext: { [weak self] in
                self!.blockUserPage = 1
                self!.blockUserList = []
                self?.getBlockUserList(input: input, disposeBag: disposeBag)
                input.didInitTableView.refreshControl?.endRefreshing()
            })
            .disposed(by: disposeBag)
        
        //empty view 관련
        self.blockUserRelay
            .subscribe(onNext: { [weak self] data in
                if data[0].items.count == 0 {
                    output.isTableViewEmpty.accept(true)
                } else {
                    output.isTableViewEmpty.accept(false)
                }
            })
        
        //cell 터치시 블락 view보여줌
        input.didInitTableView.rx.itemSelected.asObservable()
            .subscribe(onNext: { [weak self] indexPath in
                self?.coordinator?.pushBlockedUserProfile(userId: self!.blockUserList[0].items[indexPath.row].userID,
                                                         stepinId: self!.blockUserList[0].items[indexPath.row].identifierName)
            })
        
        //bind tableview datasource
        self.blockUserRelay
            .bind(to: input.didInitTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        
        return output
    }
    
    private func refreshTokenObserver(apiState: ProfileApiType,
                                      input: Input,
                                      row: Int,
                                      state: Int,
                                      disposeBag: DisposeBag) {
        switch apiState {
        case .blockUserList:
            self.userRepository?.getBlockUserList(page: self.blockUserPage)
                .subscribe(onNext: { [weak self] result in
                    if !result.items.isEmpty {
                        self?.blockUserPage += 1
                    }
                    if !self!.blockUserList.isEmpty {
                        self?.blockUserList[0].items.append(contentsOf: result.items)
                    } else {
                        self?.blockUserList.append(contentsOf: [result])
                    }
                    self!.blockUserRelay.accept(self!.blockUserList)
                })
                .disposed(by: disposeBag)
        case .postBlockUser:
            self.userRepository?.getBlockUserList(page: self.blockUserPage)
                .subscribe(onNext: { [weak self] result in
                    if !result.items.isEmpty {
                        self?.blockUserPage += 1
                    }
                    if !self!.blockUserList.isEmpty {
                        self?.blockUserList[0].items.append(contentsOf: result.items)
                    } else {
                        self?.blockUserList.append(contentsOf: [result])
                    }
                    self!.blockUserRelay.accept(self!.blockUserList)
                })
                .disposed(by: disposeBag)
        default:
            break
        }
    }
    
    private func getBlockUserList(input: Input, disposeBag: DisposeBag) {
        if tokenUtil.didTokenUpdate() {
            refreshTokenObserver(apiState: .blockUserList,
                                 input: input,
                                 row: 0,
                                 state: 0,
                                 disposeBag: disposeBag)
        } else {
            self.userRepository?.getBlockUserList(page: self.blockUserPage)
                .subscribe(onNext: { [weak self] result in
                    if !result.items.isEmpty {
                        self?.blockUserPage += 1
                    }
                    if !self!.blockUserList.isEmpty {
                        self?.blockUserList[0].items.append(contentsOf: result.items)
                    } else {
                        self?.blockUserList.append(contentsOf: [result])
                    }
                    self!.blockUserRelay.accept(self!.blockUserList)
                })
                .disposed(by: disposeBag)
        }
    }
    
    private func postBlockUser(input: Input, disposeBag: DisposeBag, row: Int, state: Int) {
        if tokenUtil.didTokenUpdate() {
            refreshTokenObserver(apiState: .postBlockUser,
                                 input: input,
                                 row: row,
                                 state: state,
                                 disposeBag: disposeBag)
        } else {
            self.userRepository?.postUserBlock(state: state, userId: self.blockUserList[0].items[row].userID)
                .subscribe(onNext: { [weak self] result in
                    if result.data.state == 1 { // 블락해제
                        self?.blockUserList[0].items[row].isBlocked = true
                        self?.blockUserRelay.accept(self!.blockUserList)

                    } else { //블락 당해버린 것
                        self?.blockUserList[0].items[row].isBlocked = false
                        self?.blockUserRelay.accept(self!.blockUserList)
                    }
                    print(row, result)
                })
                .disposed(by: disposeBag)
        }
    }
}
