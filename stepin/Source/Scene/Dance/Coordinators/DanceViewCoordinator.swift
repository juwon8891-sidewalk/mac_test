import Foundation
import UIKit

class DanceViewCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .dance
    var danceViewController: DanceVC
    var danceId: String = ""
    
    func start() {
        self.danceViewController.viewModel = DanceViewModel(coordinator: self,
                                                            danceRepository: DanceRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()))
        self.danceViewController.viewModel?.danceId = self.danceId
        self.navigationController.pushViewController(self.danceViewController, animated: true)
    }
    
    func pop() {
        self.navigationController.popViewController(animated: true)
    }
    
    func pushToChallengeGameView(danceData: PlayDance) {
        let challengeGameViewCoordinator = ChallengeGameCoordinator(self.navigationController)
        self.childCoordinators.append(challengeGameViewCoordinator)
        challengeGameViewCoordinator.finishDelegate = self
        challengeGameViewCoordinator.startToData(data: danceData)
    }
    
    func pushToPracticeGameView(danceData: PlayDance) {
        let practiceGameViewCoordinator = PracticeGameCoordinator(self.navigationController)
        self.childCoordinators.append(practiceGameViewCoordinator)
        practiceGameViewCoordinator.finishDelegate = self
        practiceGameViewCoordinator.startToData(data: danceData)
    }
    
    func pushToNormalVideoView(videoData: [NormalVideoCollectionViewDataSection],
                               pageNum: Int,
                               type: callVideoType,
                               indexPath: IndexPath) {
        let normalVideoViewCoordinator = NormalViewCoordinator(self.navigationController)
        self.childCoordinators.append(normalVideoViewCoordinator)
        normalVideoViewCoordinator.finishDelegate = self
        normalVideoViewCoordinator.start(videoData: videoData,
                                         pageNum: pageNum,
                                         type: type,
                                         indexPath: indexPath)
    }
    
    func presentToStoreView() {
        let storeViewCoordinator = StoreViewCoordinators(self.navigationController)
        self.childCoordinators.append(storeViewCoordinator)
        storeViewCoordinator.finishDelegate = self
        storeViewCoordinator.start()
    }
    

    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.danceViewController = DanceVC()
    }
    
}

extension DanceViewCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}

