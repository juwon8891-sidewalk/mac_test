import UIKit


final class LoginCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .auth
    var loginViewController: LoginVC
    
    func start() {
        self.loginViewController.loginViewModel = LoginViewModel(coordinator: self, signInRepository: AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()))
//        self.navigationController.viewControllers = [self.loginViewController]
        self.navigationController.pushViewController(self.loginViewController, animated: true)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.loginViewController = LoginVC()
    }
    // 홈으로 이동
    func homeMove() {
        let termsCoordinator = AppCoordinator(self.navigationController)
        let _ = termsCoordinator.navigationController
        self.childCoordinators.append(termsCoordinator)
        termsCoordinator.finishDelegate = self
        termsCoordinator.start()
    }
    
    func doEmailLogin() {
        let termsCoordinator = EmailLoginCoordinator(self.navigationController)
        let _ = termsCoordinator.emailLoginViewController
        self.childCoordinators.append(termsCoordinator)
        termsCoordinator.finishDelegate = self
        termsCoordinator.start()
    }
    
    func pushToTermView() {
        let termsCoordinator = TermsCoordinator(self.navigationController)
        let _ = termsCoordinator.termsViewController
        self.childCoordinators.append(termsCoordinator)
        termsCoordinator.finishDelegate = self
        termsCoordinator.start()
        print("약관 동의 화면 전환")
    }
    
    func pop() {
        self.navigationController.popViewController(animated: true)
    }
}

extension LoginCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}
