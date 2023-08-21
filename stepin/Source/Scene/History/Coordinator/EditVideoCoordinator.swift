import Foundation
import UIKit

class EditVideoCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .history
    var editVideoViewController: EditVideoVC
    
    func start() {
        self.navigationController.pushViewController(editVideoViewController, animated: true)
    }
    
    func start(data: HistoryVideoDataModel) {
        self.editVideoViewController.viewModel = EditVideoViewModel(coordinator: self, danceData: data)
        self.navigationController.pushViewController(editVideoViewController, animated: true)
    }
    
    func pushToCreateDanceView(data: HistoryVideoDataModel, isNeonMode: Bool, videoURL: String = "") {
        let createDanceCoordinator = CreateDanceCoordinator(self.navigationController)
        let cerateDanceViewController = createDanceCoordinator.createDanceViewController
        self.childCoordinators.append(createDanceCoordinator)
        createDanceCoordinator.finishDelegate = self
        createDanceCoordinator.start(data: data, isNeonMode: isNeonMode, neonVideoURL: videoURL)
    }
        
    func pop() {
        self.navigationController.popViewController(animated: false)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.editVideoViewController = EditVideoVC()
    }
    
}
extension EditVideoCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}
