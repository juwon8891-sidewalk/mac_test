import Foundation
import UIKit

class ModifyVideoViewCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .history
    var modifyVideoViewController: ModifyVideoVC
    
    func start() {
        self.navigationController.pushViewController(modifyVideoViewController, animated: true)
    }
    
    func start(videoId: String,
               videoURL: String) {
        self.modifyVideoViewController.viewModel = ModifyVideoViewModel(coordinator: self,
                                                                        videoId: videoId,
                                                                        videoURL: videoURL,
                                                                        videoRepository: VideoRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()))
        self.navigationController.dismiss(animated: true)
        self.navigationController.pushViewController(modifyVideoViewController, animated: true)
    }
    
    func pop() {
        self.navigationController.popViewController(animated: true)
    }
    
    func pushToSelectThumbnailView(data: HistoryVideoDataModel, isNeonMode: Bool, neonVideoName: String = "") {
        let thumbnailCoordinator = ThumbnailViewCoordinator(self.navigationController)
        let thumbnailViewController = thumbnailCoordinator.thumbnailViewController
        self.childCoordinators.append(thumbnailCoordinator)
        thumbnailCoordinator.finishDelegate = self
        thumbnailCoordinator.start(data: data, isNeonMode: isNeonMode, neonVideoName: neonVideoName)
        thumbnailCoordinator.selectedTimeCompletion = { time in
            self.modifyVideoViewController.viewModel?.selectedTime = time
        }
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.modifyVideoViewController = ModifyVideoVC()
    }
}
extension ModifyVideoViewCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}

