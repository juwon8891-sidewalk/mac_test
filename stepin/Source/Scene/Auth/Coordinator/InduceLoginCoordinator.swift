import UIKit

final class InduceLoginCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .auth
    var induceLoginViewController: InduceLoginVC
    
    func start() {
//        self.induceLoginViewController.viewModel = InduceLoginViewModel(coordinator: self)
//        self.navigationController.pushViewController(self.induceLoginViewController, animated: true)
    }
    
    func start(viewType: InduceLoginType) {
        self.induceLoginViewController.viewModel = InduceLoginViewModel(coordinator: self, type: viewType)
        self.navigationController.pushViewController(self.induceLoginViewController, animated: true)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.induceLoginViewController = InduceLoginVC()
        
    }
    
    func pushToLoginView() {
        let coordinator = LoginCoordinator(self.navigationController)
        let viewController = coordinator.loginViewController
        self.childCoordinators.append(coordinator)
        coordinator.finishDelegate = self
        coordinator.start()
    }
    
    
}
extension InduceLoginCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}
