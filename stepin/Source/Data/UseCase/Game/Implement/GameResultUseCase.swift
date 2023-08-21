import Foundation
import AVFoundation
import UIKit
import RxSwift
import RxCocoa
import RxRelay

class GameResultUseCase: NSObject {
    var disposeBag = DisposeBag()
    weak var delegate: GameResultProtocol?
    
    private var authRepository: AuthRepository = AuthRepository(defaultURLSessionNetworkService: .init())
    private var gameRepository: GameRepository = GameRepository(defaultURLSessionNetworkService: .init())
    private var danceRepository: DanceRepository = DanceRepository(defaultURLSessionNetworkService: .init())
    
    override init() {
        super.init()
    }
    
    //MARK: - controll
    func getExpectedRank(danceId: String,
                         score: Float) -> Observable<[Int]>{
        self.authRepository.postRefreshToken()
            .withUnretained(self)
            .flatMap { (uc, _) in uc.danceRepository.getExpectedRank(danceId: danceId, score: score)}
            .withUnretained(self)
            .map {(uc, result) in
                var resultArray: [Int] = []
                if let expectedRank = result.data.expectedRank {
                    resultArray.append(expectedRank)
                } else {
                    resultArray.append(0)
                }
                
                if let myRank = result.data.myRank {
                    resultArray.append(myRank)
                } else {
                    resultArray.append(0)
                }
                
                return resultArray
            }
    }
    
    //MARK: - Network
}
