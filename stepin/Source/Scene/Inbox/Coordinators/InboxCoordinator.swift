import Foundation
import UIKit

class InboxCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .inbox
    var inboxViewController: InboxVC
    
    func start() {
        self.navigationController.pushViewController(self.inboxViewController, animated: true)
        inboxViewController.viewModel = InboxViewModel(coordinator: self)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.inboxViewController = InboxVC()
    }
    
    func pop() {
        self.navigationController.popViewController(animated: true)
    }
    
    func pushToProfileView(userId: String) {
        if userId == UserDefaults.standard.string(forKey: UserDefaultKey.userId) {
            self.pushToMyProfileView()
        } else {
            self.pushToOtherProfileView(userId: userId)
        }
    }
    
    func pushToOtherProfileView(userId: String) {
//        let profileCoordinator = OtherMyPageCoordinator(self.navigationController)
//        let otherPageViewController = profileCoordinator.otherMyPageViewController
//        self.childCoordinators.append(profileCoordinator)
//        profileCoordinator.finishDelegate = self
//        profileCoordinator.start(userId: userId)
    }
    
    func pushToMyProfileView() {
        let profileCoordinator = ProfileCoordinator(self.navigationController)
        let myPageViewController = profileCoordinator.profileViewController
        self.childCoordinators.append(profileCoordinator)
        profileCoordinator.finishDelegate = self
        profileCoordinator.start()
    }
    
    func pushToVideoView(videoData: [NormalVideoCollectionViewDataSection]) {
        let videoCoordinator = NormalViewCoordinator(self.navigationController)
        let videoViewController = videoCoordinator.normalVideoViewController
        self.childCoordinators.append(videoCoordinator)
        videoCoordinator.finishDelegate = self
        videoCoordinator.start(videoData: videoData,
                               pageNum: 1,
                               type: .inbox,
                               indexPath: .init(row: 0, section: 0))
    }
    
    func pushToDanceView(danceId: String) {
        let danceCoordinator = DanceViewCoordinator(self.navigationController)
        let danceViewController = danceCoordinator.danceViewController
        self.childCoordinators.append(danceCoordinator)
        danceCoordinator.finishDelegate = self
        danceCoordinator.danceId = danceId
        danceCoordinator.start()
    }
    
}
extension InboxCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}
