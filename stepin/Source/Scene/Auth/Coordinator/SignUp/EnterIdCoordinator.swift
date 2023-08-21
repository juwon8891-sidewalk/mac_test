import UIKit

final class EnterIdCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .auth
    var enterIdViewController: EnterIdVC
    
    func start() {
        self.enterIdViewController.viewModel = EnterIdViewModel(coordinator: self,
                                                             signUpRepository: AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()))
        self.navigationController.pushViewController(self.enterIdViewController, animated: true)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.enterIdViewController = EnterIdVC()
    }
    
    func pushToLoginView() {
        let loginCoordinator = LoginCoordinator(self.navigationController)
        let _ = loginCoordinator.loginViewController
        self.childCoordinators.append(loginCoordinator)
        loginCoordinator.finishDelegate = self
        loginCoordinator.start()
        print("signUp success")
    }
    
    func homeMove() {
        let loginCoordinator = AppCoordinator(self.navigationController)
        let _ = loginCoordinator.navigationController
        self.childCoordinators.append(loginCoordinator)
        loginCoordinator.finishDelegate = self
        loginCoordinator.start()
        print("signUp success")
    }
}
extension EnterIdCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}
