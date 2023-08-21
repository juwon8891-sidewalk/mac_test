import Foundation
import UIKit

class ShowFollowerCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .my
    var showFollowerViewController: ShowFollowerVC
    
    func start() {
        self.showFollowerViewController.viewModel = ShowFollowerViewModel(coordinator: self,
                                                                          repository: UserRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()))
        self.navigationController.pushViewController(showFollowerViewController, animated: true)
    }
    
    func start(type: DidTapFollowViewType) {
        self.showFollowerViewController.viewModel = ShowFollowerViewModel(coordinator: self,
                                                                          repository: UserRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()))
        self.showFollowerViewController.type = type
        self.navigationController.pushViewController(showFollowerViewController, animated: true)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.showFollowerViewController = ShowFollowerVC()
    }
    
    func pushToOtherProfilePage(userID: String) {
        let otherMyPageCoordinator = ProfileCoordinator(self.navigationController)
        let otherMyPageViewContolloer = otherMyPageCoordinator.profileViewController
        self.childCoordinators.append(otherMyPageCoordinator)
        otherMyPageCoordinator.finishDelegate = self
        otherMyPageCoordinator.start(userId: userID,
                                     profileState: .other)
    }
    
}

extension ShowFollowerCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}
