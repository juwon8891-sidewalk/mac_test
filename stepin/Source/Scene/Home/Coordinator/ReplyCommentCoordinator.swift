import Foundation
import UIKit

class ReplyCommentCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .home
    var replyViewController: ReplyCommentVC
    var commentViewCoordinator: CommentViewCoordinator?
    
    func start() {
        self.replyViewController.bindViewModel()
        self.replyViewController.modalPresentationStyle = .overFullScreen
        self.navigationController.pushViewController(self.replyViewController, animated: true)
    }
    
    func startNextModal(coordinator: CommentViewCoordinator, commentId: String) {
        self.commentViewCoordinator = coordinator
        self.replyViewController.viewModel = ReplyCommentViewModel(repository: CommentRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()),
                                                                   coordinator: self)
        self.replyViewController.viewModel?.commentId = commentId
        self.replyViewController.viewModel?.videoId = coordinator.commentViewController.viewModel?.videoId ?? ""
        self.replyViewController.bindViewModel()
        self.replyViewController.modalPresentationStyle = .overFullScreen
        
        self.commentViewCoordinator?.commentViewController.removeNotification()
        self.commentViewCoordinator!.commentViewController.present(self.replyViewController, animated: false) {
            self.replyViewController.view.isHidden = true // present시 일시적으로 튀는현상 숨기기위함.
            DispatchQueue.main.async {
                self.replyViewController.view.isHidden = false
                switch self.commentViewCoordinator?.commentViewController.fullScreenFlag {
                case true:
                    self.replyViewController.fullScreenUpdate()
                default:
                    self.replyViewController.notFullScreenUpdate()
                }
                
                guard let yPoint = self.commentViewCoordinator?.commentViewController.view.frame.origin.y else {return}

                self.replyViewController.view.transform = CGAffineTransform(translationX: self.replyViewController.view.frame.width , y: yPoint)
                
                UIView.animate(withDuration: 0.5) {
                    self.replyViewController.view.transform = CGAffineTransform(translationX: 0 , y: yPoint)
                } completion: { _ in
                    self.commentViewCoordinator?.commentViewController.view.alpha = 0
                }
            }
        
        }
    }
    
    func backToCommentView() {
        
        switch self.replyViewController.fullScreenFlag {
        case true:
            self.commentViewCoordinator?.commentViewController.fullScreenUpdate()
        default:
            self.commentViewCoordinator?.commentViewController.notFullScreenUpdate()
        }
        self.commentViewCoordinator?.commentViewController.initNotificationCenter()
        let yPoint = self.replyViewController.view.frame.origin.y
        
        
        self.commentViewCoordinator?.commentViewController.view.alpha = 1
        UIView.animate(withDuration: 0.5) {
            self.replyViewController.view.transform = CGAffineTransform(translationX: self.replyViewController.view.frame.width , y: 0)
        } completion: { _ in
            self.replyViewController.dismiss(animated: false)
        }
    }
    
    func dismiss() {
        self.replyViewController.presentingViewController?.presentingViewController?.dismiss(animated: false)
    }

    func pop() {
        self.navigationController.popViewController(animated: true)
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
        self.replyViewController = ReplyCommentVC()
    }
    
   
}

extension ReplyCommentCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}

