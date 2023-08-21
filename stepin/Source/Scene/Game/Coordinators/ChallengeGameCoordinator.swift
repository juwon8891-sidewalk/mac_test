import Foundation
import UIKit

class ChallengeGameCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .game
    var challengeGameViewController: ChallengeGameViewController
    var danceId: String = ""
    
    func start() {
        self.challengeGameViewController.viewModel = ChallengeGameViewModel(coordinator: self)
        self.navigationController.pushViewController(self.challengeGameViewController, animated: true)
    }
    
    func startToData(data: PlayDance) {
        self.challengeGameViewController.viewModel = ChallengeGameViewModel(coordinator: self)
        self.challengeGameViewController.viewModel?.danceData = data
        self.navigationController.pushViewController(self.challengeGameViewController, animated: true)
    }
    
    func pop() {
        self.navigationController.popViewController(animated: false)
    }
    
    func pushToResultViewController(scoreData: [String],
                                    score: Float,
                                    danceData: PlayDance?) {
        let resultGameViewCoordinator = GameResultCoordinator(self.navigationController)
        self.childCoordinators.append(resultGameViewCoordinator)
        resultGameViewCoordinator.finishDelegate = self
        resultGameViewCoordinator.start(scoreData: scoreData,
                                        score: score,
                                        danceData: danceData)
    }
    

    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.challengeGameViewController = ChallengeGameViewController()
    }
    
}

extension ChallengeGameCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}

