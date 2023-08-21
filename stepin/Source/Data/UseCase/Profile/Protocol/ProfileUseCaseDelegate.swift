import Foundation

protocol ProfileUseCaseDelegate: NSObject {
    func getProfileData(data: [ProfileCollectionViewDataSection], isFail: Bool)
    func didFollowSuccess(state: Bool?, isFail: Bool)
    func didBoostPossible(state: Bool?, isFail: Bool)
    func didPatchBoostSuccess(state: Bool?, isFail: Bool)
    func didBlockSuccess(state: Bool?, isFail: Bool)
}
