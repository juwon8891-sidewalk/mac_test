import UIKit


final class EmailLoginCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .auth
    var emailLoginViewController: EmailLoginVC
    
    func start() {
        self.emailLoginViewController.emailLoginViewModel = EmailLoginViewModel(coordinator: self,
                                                                                signUpRepository: AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()))
        self.navigationController.pushViewController(self.emailLoginViewController, animated: true)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.emailLoginViewController = EmailLoginVC()
    }
    
    func pushToFindPasswordView() {
        let FindPasswordCoordinator = FindPasswordCoordinator(self.navigationController)
        let FindPasswordViewController = FindPasswordCoordinator.VerifyEmaialViewController
        self.childCoordinators.append(FindPasswordCoordinator)
        FindPasswordCoordinator.finishDelegate = self
        FindPasswordCoordinator.start()
    }
    
    // 홈으로 이동
    func homeMove() {
        let termsCoordinator = AppCoordinator(self.navigationController)
        let _ = termsCoordinator.navigationController
        self.childCoordinators.append(termsCoordinator)
        termsCoordinator.finishDelegate = self
        termsCoordinator.start()
    }
}

extension EmailLoginCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}
