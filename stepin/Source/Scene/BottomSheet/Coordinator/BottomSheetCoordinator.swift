import Foundation
import UIKit

class BottomSheetCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .my
    var bottomSheetViewController: BottomSheetVC
    
    func start() {
        self.bottomSheetViewController.modalPresentationStyle = .overFullScreen
        self.navigationController.present(bottomSheetViewController, animated: true)
    }
    
    func startData(userId: String,
                   videoId: String,
                   isFollowed: Bool,
                   isBlocked: Bool,
                   isBoosted: Bool,
                   type: BottomSheetType) {
        self.bottomSheetViewController.type = type
        bottomSheetViewController.modalPresentationStyle = .overFullScreen
        bottomSheetViewController.coordinator = self
        bottomSheetViewController.userId = userId
        bottomSheetViewController.videoId = videoId
        bottomSheetViewController.isFollowed = isFollowed
        bottomSheetViewController.isBlocked = isBlocked
        bottomSheetViewController.isBoosted = isBoosted
        self.navigationController.present(bottomSheetViewController, animated: true)
    }
    
    func pushToModifyVideoView(videoId: String) {
        let modifyVideoViewCoordinator = ModifyVideoViewCoordinator(self.navigationController)
        let modifyVideoViewController = modifyVideoViewCoordinator.modifyVideoViewController
        self.childCoordinators.append(modifyVideoViewCoordinator)
        modifyVideoViewCoordinator.finishDelegate = self
        modifyVideoViewCoordinator.start(videoId: videoId, videoURL: "")
    }
    
    func dismiss() {
        self.navigationController.dismiss(animated: false) {
            if let previousViewController = self.navigationController.viewControllers.last {
                // 이전 뷰 컨트롤러의 viewDidAppear를 호출
                previousViewController.viewDidAppear(true)
            }
        }
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.bottomSheetViewController = BottomSheetVC()
        self.bottomSheetViewController.coordinator = self
    }
   
}
extension BottomSheetCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}
