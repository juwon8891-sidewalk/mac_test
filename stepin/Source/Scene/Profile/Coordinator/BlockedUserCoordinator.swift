import Foundation
import UIKit

class BlockedUserCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .otherMy
    var blockedUserViewController: BlockedUserVC
    
    func start() {
        self.blockedUserViewController.blockedViewModel = BlockedUserViewModel(userRepository: UserRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()),
                                                                               authRepository: AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()))
        self.navigationController.pushViewController(blockedUserViewController, animated: true)
    }
  
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.blockedUserViewController = BlockedUserVC()
    }
    
}
