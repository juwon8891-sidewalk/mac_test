import Foundation
import RxSwift

class PlayUseCase: NSObject{
    private var userRepository = UserRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    private var danceRepository = DanceRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    private var authRepository = AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService())
    
    var playDataSection: [PlayDanceTableViewDataSection]?
    
    override init() {
        super.init()
    }
    
    
    func getHotDanceList(page: Int, isResetData: Bool = false) -> Observable<[PlayDanceTableViewDataSection]?> {
        self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap { (uc, _) in uc.danceRepository.getPlayHotDance(page: page)}
            .withUnretained(self)
            .map { (uc, result) in
                //최초 초기화
                if isResetData {
                    uc.playDataSection = nil
                }
                if uc.playDataSection == nil {
                    uc.playDataSection = [.init(items: result.data.dance)]
                } else {
                    uc.playDataSection?[0].items.append(contentsOf: result.data.dance)
                }
                return uc.playDataSection
            }
    }
    
    func getMyDanceList(page: Int, isResetData: Bool = false) -> Observable<[PlayDanceTableViewDataSection]?> {
        self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap { (uc, _) in uc.danceRepository.getLikedDance(page: page) }
            .withUnretained(self)
            .map { (uc, result) in
                //최초 초기화
                if isResetData {
                    uc.playDataSection = nil
                }
                if uc.playDataSection == nil {
                    uc.playDataSection = [.init(items: result.data.dance)]
                } else {
                    uc.playDataSection?[0].items.append(contentsOf: result.data.dance)
                }
                return uc.playDataSection
            }
    }
    
    func likeButtonTapped(danceId: String,
                          state: Int) -> Observable<Int>{
        self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap { (uc, _) in uc.danceRepository.patchLikeDane(danceId: danceId, state: state) }
            .withUnretained(self)
            .map { (uc, result) in
                print(result.message)
                return result.statusCode
            }
    }
    
    func getEnergyData() -> Observable<StaminaDataModel> {
        self.authRepository.postRefreshToken()
            .flatMap { [weak self] _ in (self?.userRepository.getUserStamina())! }
            .withUnretained(self)
            .map { (uc, result) in
                return result
            }
    }
    
    
}
