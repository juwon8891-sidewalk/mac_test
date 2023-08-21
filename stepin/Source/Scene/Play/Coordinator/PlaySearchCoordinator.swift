import Foundation
import UIKit

class PlaySearchCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .play
    var playViewController: PlaySearchVC
    
    func start() {
        self.playViewController.viewModel = PlaySearchViewModel(coordinator: self,
                                                                danceRepository: DanceRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()))
        self.navigationController.pushViewController(playViewController, animated: true)
    }
    
    func pushToDanceView(danceId: String) {
        let danceViewCoordinator = DanceViewCoordinator(self.navigationController)
        let danceViewController = danceViewCoordinator.danceViewController
        danceViewCoordinator.danceId = danceId
        self.childCoordinators.append(danceViewCoordinator)
        danceViewCoordinator.finishDelegate = self
        danceViewCoordinator.start()
    }
    
    func pop() {
        self.navigationController.popViewController(animated: true)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.playViewController = PlaySearchVC()
    }
    
    
}
extension PlaySearchCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}

