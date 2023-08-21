import UIKit
import RxRelay

final class TermsCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .auth
    var termsViewController: TermsVC
    
    func start() {
        self.termsViewController.viewModel = TermsViewModel(coordinator: self,
                                                             signUpRepository: AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()))
        self.navigationController.pushViewController(termsViewController, animated: true)
    }
  
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.termsViewController = TermsVC()
    }
    
    func pushToEmailView() {
        let coordinator = VerifyEmailCoordinator(self.navigationController)
        let viewController = coordinator.VerifyEmaialViewController
        self.childCoordinators.append(coordinator)
        coordinator.finishDelegate = self
        coordinator.start()
    }
    
    // 추가
    func pushToBirthdayView() {
        let coordinator = BirthDateCoordinator(self.navigationController)
        let viewController = coordinator.birthDateViewController
        self.childCoordinators.append(coordinator)
        coordinator.finishDelegate = self
        coordinator.start()
    }
    
    func pushToUserLicense() {
        let coordinator = WebCoordinator(self.navigationController,
                                         url: Constants.eulaURL,
                                         type: .term)
        self.childCoordinators.append(coordinator)
        coordinator.finishDelegate = self
        coordinator.start()
        coordinator.webViewController.agreeButtonCompletion = {
            self.termsViewController.viewModel?.setTermsArray(index: 0)
            self.termsViewController.viewModel?.termSelectedRelay.accept(0)
        }
    }
    
    func pushToPersonalInformation() {
        let coordinator = WebCoordinator(self.navigationController,
                                         url: Constants.privacyURL,
                                         type: .term)
        self.childCoordinators.append(coordinator)
        coordinator.finishDelegate = self
        coordinator.start()
        coordinator.webViewController.agreeButtonCompletion = {
            self.termsViewController.viewModel?.setTermsArray(index: 1)
            self.termsViewController.viewModel?.termSelectedRelay.accept(1)
        }
    }
    
    func pushToTerms() {
        let coordinator = WebCoordinator(self.navigationController,
                                         url: Constants.eulaURL,
                                         type: .none)
        self.childCoordinators.append(coordinator)
        coordinator.finishDelegate = self
        coordinator.start()
    }
}

extension TermsCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}

// 추가
protocol TermsViewControllerDelegate {
    func didTapNextButton(boolValue: Bool )
}
extension TermsCoordinator: TermsViewControllerDelegate {
    func didTapNextButton(boolValue: Bool) {
        if boolValue {
            pushToBirthdayView()
        } else {
            pushToEmailView()
        }
    }
}
