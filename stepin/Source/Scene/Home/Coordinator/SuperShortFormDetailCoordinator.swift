//import Foundation
//import UIKit
//
//class SuperShortFormDetailCoordinator: Coordinator {
//    var finishDelegate: CoordinatorFinishDelegate?
//    var navigationController: UINavigationController
//    var childCoordinators: [Coordinator] = []
//    var type: CoordinatorType = .home
//    var detailViewController: SuperShortFormDetailVC
//    var sendData: [SuperShortFormCollectionViewDataSection] = []
//    
//    func start() {
//        self.detailViewController.viewModel = SuperShortFormDetailViewModel(coordinator: self,
//                                                                            homeRepository: HomeRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()))
//        self.navigationController.pushViewController(self.detailViewController, animated: true)
//    }
//    
//    func startForData(indexPath: IndexPath) {
//        self.detailViewController.viewModel = SuperShortFormDetailViewModel(coordinator: self,
//                                                                            homeRepository: HomeRepository(defaultURLSessionNetworkService: DefaultURLSessionNetworkService()))
//        self.navigationController.pushViewController(self.detailViewController, animated: false)
//        self.detailViewController.viewModel?.result = self.sendData
//        self.detailViewController.viewModel?.selectedIndexPath = indexPath
//    }
//    
//    func pop() {
//        self.navigationController.popViewController(animated: true)
//    }
//    
//    func presentToComment(videoId: String) {
//        let commentCoordinator = CommentViewCoordinator(self.navigationController)
//        let commentViewContolloer = commentCoordinator.commentViewController
//        commentViewContolloer.viewModel?.videoId = videoId
//        self.childCoordinators.append(commentCoordinator)
//        commentCoordinator.finishDelegate = self
//        commentCoordinator.startComment(videoId: videoId)
//    }
//    
//    func pushToDanceView() {
//        let danceViewCoordinator = DanceViewCoordinator(self.navigationController)
//        let danceViewController = danceViewCoordinator.danceViewController
//        self.childCoordinators.append(danceViewCoordinator)
//        danceViewCoordinator.finishDelegate = self
//        danceViewCoordinator.start()
//    }
//    
//    required init(_ navigationController: UINavigationController) {
//        self.navigationController = navigationController
//        self.detailViewController = SuperShortFormDetailVC()
//    }
//    
//    init(_ navigationController: UINavigationController, data: [SuperShortFormCollectionViewDataSection]) {
//        self.navigationController = navigationController
//        self.detailViewController = SuperShortFormDetailVC()
//        self.sendData = data
//    }
//}
//
//extension SuperShortFormDetailCoordinator: CoordinatorFinishDelegate {
//    func coordinatorDidFinish(childCoordinator: Coordinator) {
//        self.childCoordinators = self.childCoordinators
//            .filter { $0.type != childCoordinator.type }
//    }
//}
//
