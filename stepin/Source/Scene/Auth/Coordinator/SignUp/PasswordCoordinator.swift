import UIKit

final class PasswordCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .auth
    var passwordViewController: PasswordVC
    
    func start() {
        self.passwordViewController.viewModel = PasswordViewModel(coordinator: self,
                                                             repository: AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()))
        self.navigationController.pushViewController(self.passwordViewController, animated: true)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.passwordViewController = PasswordVC()
        
    }
    
    func pushToNextView() {
        let coordinator = BirthDateCoordinator(self.navigationController)
        let viewController = coordinator.birthDateViewController
        self.childCoordinators.append(coordinator)
        coordinator.finishDelegate = self
        coordinator.start()
    }
    
    func pushToLoginView() {
        let coordinator = LoginCoordinator(self.navigationController)
        let viewController = coordinator.loginViewController
        self.childCoordinators.append(coordinator)
        coordinator.finishDelegate = self
        coordinator.start()
    }
    
    
}
extension PasswordCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}
