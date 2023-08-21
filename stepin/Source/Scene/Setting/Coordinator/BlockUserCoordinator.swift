import Foundation
import UIKit

class BlockUserCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .setting
    var manageBlockViewController: ManageBlockVC
    
    func start() {
        self.navigationController.pushViewController(self.manageBlockViewController, animated: true)
        manageBlockViewController.viewModel = ManageBlockViewModel(coordinator: self,
                                                                   userRepository: UserRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()))
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.manageBlockViewController = ManageBlockVC()
    }
    
    func pushBlockedUserProfile(userId: String, stepinId: String) {
        let blockCoordinator = BlockedUserCoordinator(self.navigationController)
        let blockedProfileViewController = blockCoordinator.blockedUserViewController
        self.childCoordinators.append(blockCoordinator)
        blockCoordinator.finishDelegate = self
        blockCoordinator.start()
        blockedProfileViewController.stepinId = stepinId
        blockedProfileViewController.blockedViewModel?.userId = userId
    }
}
extension BlockUserCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}
