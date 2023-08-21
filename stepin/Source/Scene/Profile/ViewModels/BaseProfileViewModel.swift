//import Foundation
//import RxCocoa
//import RxSwift
//import RxDataSources
//
enum ProfileApiType {
    case getProfile
    case patchFollowingUser
    case getFollowingList
    case getFollowerList
    case deleteRemoveFollower
    case getFriendsList
    case postBlockUser
    case blockUserList
    case blockUserProfile
    case reportUser
    case getSearchUser
    case getSearchFollower
    case getSearchFolloing
    case patchModifyProfile
}
//
//class BaseProfileViewModel: NSObject {
//    let disposeBag = DisposeBag()
//    internal weak var myPagecoordinator: MyPageCoordinator?
//    internal weak var otherMyPageCoordinator: OtherMyPageCoordinator?
//    var userRepository: UserRepository?
//    var authRepository: AuthRepository?
//    var videoRepository = VideoRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
//
//    init(coordinator: profile, userRepository: UserRepository) {
//        self.myPagecoordinator = coordinator
//        self.userRepository = userRepository
//        self.authRepository = AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
//    }
//
//    init(coordinator: OtherMyPageCoordinator, userRepository: UserRepository) {
//        self.otherMyPageCoordinator = coordinator
//        self.userRepository = userRepository
//    }
//
//    struct Input {
//        let viewDidAppeared: Observable<Void>
//        let moreButtonDidTapped: Observable<Void>
//        let didCollectionViewInit: UICollectionView
//        let didCollectionViewScroll: Observable<CGPoint>
//        let navigationView: TitleNavigationView?
//    }
//
//    struct Output {
//        var headerBackgroundColor = BehaviorRelay<UIColor>(value: .clear)
//        var collectionViewOutputData = PublishRelay<String>()
//        var isBlockCorrect = PublishRelay<Bool>()
//        var isLoadingStart = PublishRelay<Void>()
//        var isLoaingFinish = PublishRelay<Void>()
//    }
//
//
//    internal func transform(from input: Input, disposeBag: DisposeBag) -> Output {
//        var output = Output()
//
//        return output
//    }
//
//}
