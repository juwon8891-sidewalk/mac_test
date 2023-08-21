import Foundation
import UIKit
import AVFoundation

class ThumbnailViewCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .history
    var thumbnailViewController: ThumbnailVC
    
    var selectedTimeCompletion: ((CMTime) -> Void)?
    
    func start() {
        self.navigationController.pushViewController(thumbnailViewController, animated: true)
    }
    
    func start(data: HistoryVideoDataModel, isNeonMode: Bool, neonVideoName: String = "") {
        self.thumbnailViewController.viewModel = ThumbnailViewModel(coordinator: self, danceData: data)
        self.thumbnailViewController.viewModel?.isNeonMode = isNeonMode
        self.thumbnailViewController.viewModel?.videoName = neonVideoName
        self.navigationController.pushViewController(thumbnailViewController, animated: true)
    }
    
//    func pushToCreateDanceView(data: HistoryVideoDataModel) {
//        let createDanceCoordinator = CreateDanceCoordinator(self.navigationController)
//        let cerateDanceViewController = createDanceCoordinator.createDanceViewController
//        self.childCoordinators.append(createDanceCoordinator)
//        createDanceCoordinator.finishDelegate = self
//        createDanceCoordinator.start(data: data)
//    }
        
    func pop() {
        self.navigationController.popViewController(animated: true)
    }
    
    func popToData(selectedTime: CMTime) {
        guard let completion = selectedTimeCompletion else {return}
        completion(selectedTime)
        self.navigationController.popViewController(animated: true)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.thumbnailViewController = ThumbnailVC()
    }
    
}
//extension EditVideoCoordinator: CoordinatorFinishDelegate {
//    func coordinatorDidFinish(childCoordinator: Coordinator) {
//        self.childCoordinators = self.childCoordinators
//            .filter { $0.type != childCoordinator.type }
//    }
//}
