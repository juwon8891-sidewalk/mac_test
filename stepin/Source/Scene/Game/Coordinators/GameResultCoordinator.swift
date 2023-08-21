import Foundation
import UIKit

class GameResultCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .game
    var gameResultViewController: GameResultViewController
    
    
    func start() {
        self.gameResultViewController.viewModel = GameResultViewModel(coordinator: self)
        self.navigationController.pushViewController(self.gameResultViewController, animated: true)
    }
    
    func start(scoreData: [String],
               score: Float,
               danceData: PlayDance?) {
        self.gameResultViewController.viewModel = GameResultViewModel(coordinator: self)
        self.gameResultViewController.viewModel?.scoreData = scoreData
        self.gameResultViewController.viewModel?.score = score
        if let danceData {
            self.gameResultViewController.viewModel?.danceInfo = danceData
        }
        self.navigationController.pushViewController(self.gameResultViewController, animated: true)
    }
    
    func pushToChallengeGameView(danceData: PlayDance) {
        let challengeGameViewCoordinator = ChallengeGameCoordinator(self.navigationController)
        self.childCoordinators.append(challengeGameViewCoordinator)
        challengeGameViewCoordinator.finishDelegate = self
        challengeGameViewCoordinator.startToData(data: danceData)
//        challengeGameViewCoordinator.start()
    }
    
    func pop() {
        self.navigationController.popViewController(animated: true)
    }
    
//    func pushToResultViewController() {
////        let challengeGameViewCoordinator = ChallengeGameCoordinator(self.navigationController)
////        self.childCoordinators.append(challengeGameViewCoordinator)
////        challengeGameViewCoordinator.finishDelegate = self
////        challengeGameViewCoordinator.startToData(data: danceData)
////        challengeGameViewCoordinator.start()
//    }
    

    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.gameResultViewController = GameResultViewController()
    }
    
}

extension GameResultCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}

