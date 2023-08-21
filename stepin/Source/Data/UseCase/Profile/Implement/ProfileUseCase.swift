import Foundation
import RxSwift
import RxRelay

final class ProfileUseCase: NSObject {
    weak var delegate: ProfileUseCaseDelegate?
    private var disposeBag = DisposeBag()
    
    private let authRepository = AuthRepository(defaultURLSessionNetworkService: .init())
    private let userRepository = UserRepository(defaultURLSessionNetworkService: .init())
    private let videoRepository = VideoRepository(defaultURLSessionNetworkService: .init())
    
    private var videoPageNum: Int = 1
    private var videoData: [Video] = []
    
    var isNotReload: Bool = false
    
    func setPageNum(_ pageNum: Int) {
        self.videoPageNum = pageNum
    }
    func increasePageNum() {
        self.videoPageNum += 1
    }
    
    //make share link
    func getProfileShareLink(userId: String) -> Observable<String> {
        return self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap { (uc, _) in uc.userRepository.getUserDynamicLink(userId: userId)}
            .withUnretained(self)
            .map { (uc, data) in
                return data.data.dynamiclink
            }
    }
    
    
    //following follow
    func patchFollowingUser(userId: String, followingState: Bool) -> Observable<Bool>{
        let state = followingState ? -1 : 1
        return self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap { (uc, _) in uc.userRepository.patchFollowUser(userId: userId,
                                                                    state: state)}
            .withUnretained(self)
            .map { (uc, data) in
                if data.data.state == 1 {
                    return true
                } else {
                    return false
                }
            }
    }
    
    //blockUser
    func poseBlockUser(userId: String, wantBlock: Bool) -> Observable<Bool> {
        var blockState: Int = -1
        if wantBlock { //for blocking
            blockState = 1
        }
        return self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap { (uc, _) in uc.userRepository.postUserBlock(state: blockState,
                                                                  userId: userId)}
            .withUnretained(self)
            .map { (uc, data) in
                if data.data.state == 1 {
                    return true
                } else {
                    return false
                }
            }
    }
    
    //부스트 클릭시
    func patchUserBoost(userId: String) -> Observable<String> {
        self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap { (uc, _) in uc.userRepository.patchBoostUser(userId: userId)}
            .withUnretained(self)
            .map { (uc, data) in
                return data.message
            }
    }
    
    //부스트 가능
    func checkBoostPossible() -> Observable<Bool> {
        self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap { (uc, _) in uc.userRepository.getBoostIsPossible()}
            .withUnretained(self)
            .map { (uc, data) in
                return data.data.possible
            }
    }
    
    //profileInfo가져오기
    func getProfileInfo(userId: String) -> Observable<MyPageData> {
        self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap { (uc, _) in uc.userRepository.getUserProfile(type: "id",
                                                                   data: userId)}
            .withUnretained(self)
            .map { (uc, data) in
                return data.data
            }
    }
    
    //Video 가져오기
    func getVideoList(userId: String) -> Observable<[Video]> {
        self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap { (uc, _) in uc.videoRepository.getUserVideo(type: "id",
                                                                  userId: userId,
                                                                  page: uc.videoPageNum)}
            .withUnretained(self)
            .map { (uc, data) in
                if data.data.video.count == 0 {
                    self.isNotReload = true
                }
                uc.videoData.append(contentsOf: data.data.video)
                return uc.videoData
            }
    }
    
    func getProfileData(userId: String) -> Observable<[ProfileCollectionViewDataSection]> {
        let profileData = self.getProfileInfo(userId: userId).asObservable()
        let videoData = self.getVideoList(userId: userId).asObservable()
        
        return Observable.combineLatest(profileData, videoData)
            .withUnretained(self)
            .map { (uc, arg1) in
                let (myPageData, videoList) = arg1
                let dataSection = [ProfileCollectionViewDataSection(header: myPageData, items: videoList)]
                return dataSection
            }
    }
    
}
