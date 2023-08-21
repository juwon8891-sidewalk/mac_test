import Foundation
import UIKit

class SelectMypageVideoCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .my
    var selectMypageVideoViewController: SelectMypageVideoVC
    var videoIdCompletion: (([String]) -> Void)?
    
    func start() {
        self.selectMypageVideoViewController.viewModel = SelectMypageVideoViewModel(coordinator: self,
                                                                                    videoRepository: VideoRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()),
                                                                                    authRepository: AuthRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()))
        self.navigationController.pushViewController(selectMypageVideoViewController, animated: true)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.selectMypageVideoViewController = SelectMypageVideoVC()
    }
    
    func pop() {
        DispatchQueue.main.async {
            self.navigationController.popViewController(animated: true)
        }
    }
    
    func popToEditProfile(videoID: String,
                          videoPath: String) {
        DispatchQueue.main.async {
            guard let completion = self.videoIdCompletion else {return}
            completion([videoID, videoPath])
            self.navigationController.popViewController(animated: true)
        }
    }
    
}

extension SelectMypageVideoCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}
