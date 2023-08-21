import Foundation
import UIKit

class CreateDanceCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .history
    var createDanceViewController: CreateDanceVC
    
    func start() {
        self.navigationController.pushViewController(createDanceViewController, animated: true)
    }
    
    func start(data: HistoryVideoDataModel, isNeonMode: Bool, neonVideoURL: String = "") {
        self.createDanceViewController.viewModel = CreateDanceViewModel(coordinator: self,
                                                                        danceData: data,
                                                                        videoRepository: VideoRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()))
        self.createDanceViewController.viewModel?.isNeonMode = isNeonMode
        self.createDanceViewController.viewModel?.neonVideoName = neonVideoURL
        self.navigationController.pushViewController(createDanceViewController, animated: true)
    }
    
    func pop() {
        self.navigationController.popViewController(animated: false)
    }
    
    func popToDetailView() {
        navigationController.popViewController(animated: false)
        self.navigationController.viewControllers[navigationController.viewControllers.count - 2].navigationController?.popViewController(animated: false)
    }
    
    func popToHistoryView() {
        self.navigationController.popToRootViewController(animated: false)
//        self.navigationController.viewControllers[0].navigationController?.popViewController(animated: false)
    }
    
    func pushToSelectThumbnailView(data: HistoryVideoDataModel, isNeonMode: Bool, neonVideoName: String = "") {
        let thumbnailCoordinator = ThumbnailViewCoordinator(self.navigationController)
        let thumbnailViewController = thumbnailCoordinator.thumbnailViewController
        self.childCoordinators.append(thumbnailCoordinator)
        thumbnailCoordinator.finishDelegate = self
        thumbnailCoordinator.start(data: data, isNeonMode: isNeonMode, neonVideoName: neonVideoName)
        thumbnailCoordinator.selectedTimeCompletion = { time in
            self.createDanceViewController.viewModel?.selectedTime = time
        }
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.createDanceViewController = CreateDanceVC()
    }
}
extension CreateDanceCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}

