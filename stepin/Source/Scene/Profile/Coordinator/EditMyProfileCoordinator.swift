import Foundation
import UIKit

class EditMyProfileCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .my
    var editMyProfileViewController: EditMyPageVC
    
    func start() {
        self.editMyProfileViewController.viewModel = EditMyPageViewModel(coordinator: self,
                                                                         userRepository: UserRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()),
                                                                         authRepository: AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()))
        self.navigationController.pushViewController(editMyProfileViewController, animated: true)
    }
    
    func start(backgroundVideoPath: String) {
        self.editMyProfileViewController.viewModel = EditMyPageViewModel(coordinator: self,
                                                                         userRepository: UserRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()),
                                                                         authRepository: AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()))
        self.editMyProfileViewController.viewModel?.videoPath = backgroundVideoPath
        self.navigationController.pushViewController(editMyProfileViewController, animated: true)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.editMyProfileViewController = EditMyPageVC()
    }
    
    func popToPreiview() {
        DispatchQueue.main.async {
            self.navigationController.popViewController(animated: true)
        }
    }
    
    func pushToSelectVideoView() {
        let selectedVideoCoordinator = SelectMypageVideoCoordinator(self.navigationController)
        self.childCoordinators.append(selectedVideoCoordinator)
        selectedVideoCoordinator.finishDelegate = self
        selectedVideoCoordinator.start()
        
        selectedVideoCoordinator.videoIdCompletion = { [weak self] videoInfo in
            guard let self = self else {return}
            self.editMyProfileViewController.viewModel?.videoId = videoInfo[0]
            self.editMyProfileViewController.viewModel?.videoPath = videoInfo[1]
            self.editMyProfileViewController.viewModel?.isVideoChanged = true
        }
    }
    
}
extension EditMyProfileCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}
