import UIKit

final class VerifyEmailCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .auth
    var VerifyEmaialViewController: VerifyEmailVC
    
    func start() {
        self.VerifyEmaialViewController.viewModel = VerifyEmailViewModel(coordinator: self,
                                                             signUpRepository: AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()))
        self.navigationController.pushViewController(self.VerifyEmaialViewController, animated: true)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.VerifyEmaialViewController = VerifyEmailVC()
        
    }
    
    func pushToNextView() {
        let coordinator = PasswordCoordinator(self.navigationController)
        let viewController = coordinator.passwordViewController
        self.childCoordinators.append(coordinator)
        coordinator.finishDelegate = self
        coordinator.start()
        print("email Success")
    }
    
    
}
extension VerifyEmailCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}
