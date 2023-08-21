import Foundation
import UIKit

class CommentViewCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .home
    var commentViewController: CommentVC
    
    func start() {
        self.commentViewController.viewModel = CommentViewModel(repository: CommentRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()),
                                                                coordinator: self)
        self.commentViewController.bindViewModel()
        self.navigationController.present(self.commentViewController, animated: true)
    }
    
    func startComment(videoId: String) {
        self.commentViewController.viewModel = CommentViewModel(repository: CommentRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()),
                                                                coordinator: self)
        self.commentViewController.viewModel?.videoId = videoId
        self.commentViewController.bindViewModel()
        self.commentViewController.modalPresentationStyle = .overFullScreen
        self.navigationController.present(commentViewController, animated: true)
    }

    func dismiss() {
        self.navigationController.dismiss(animated: false)
    }
    
    func pushToReplyCommentVC(commentId: String) {
        let replyCoordinator = ReplyCommentCoordinator(self.navigationController)
        self.childCoordinators.append(replyCoordinator)
        replyCoordinator.finishDelegate = self
        replyCoordinator.startNextModal(coordinator: self, commentId: commentId)
    }
    
    
    func pushToMyProfileView() {
        let myProfileCoordinator = ProfileCoordinator(self.navigationController)
        let myProfileViewController = myProfileCoordinator.profileViewController
        self.childCoordinators.append(myProfileCoordinator)
        myProfileCoordinator.finishDelegate = self
        myProfileCoordinator.start()
    }
    
    func pushToOtherProfileView(userId: String) {
//        let otherProfileCoordinator = OtherMyPageCoordinator(self.navigationController)
//        let otherProfileViewController = otherProfileCoordinator.otherMyPageViewController
//        self.childCoordinators.append(otherProfileCoordinator)
//        otherProfileCoordinator.finishDelegate = self
//        otherProfileCoordinator.start(userId: userId)
    }
    

    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.commentViewController = CommentVC()
    }
    

    
   
}

extension CommentViewCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}

