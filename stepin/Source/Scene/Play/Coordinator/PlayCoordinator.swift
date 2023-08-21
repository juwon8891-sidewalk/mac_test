import Foundation

class PlayDanceViewCoordinator: Coordinator {
    var finishDelegate: CoordinatorFinishDelegate?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var type: CoordinatorType = .play
    var playDanceViewController: PlayVC
    
    
    
    func start() {
        self.playDanceViewController.viewModel = PlayDanceViewModel(coordinator: self)
        self.navigationController.pushViewController(self.playDanceViewController, animated: true)
    }
    
    func pushToChallengeGameView(danceData: PlayDance) {
        let challengeGameViewCoordinator = ChallengeGameCoordinator(self.navigationController)
        self.childCoordinators.append(challengeGameViewCoordinator)
        challengeGameViewCoordinator.finishDelegate = self
        challengeGameViewCoordinator.startToData(data: danceData)
    }
    
    func pushToPracticeGameView(danceData: PlayDance) {
        let practiceGameViewCoordinator = PracticeGameCoordinator(self.navigationController)
        self.childCoordinators.append(practiceGameViewCoordinator)
        practiceGameViewCoordinator.finishDelegate = self
        practiceGameViewCoordinator.startToData(data: danceData)
    }
    
    func pushToDanceView(danceId: String) {
        let danceViewCoordinator = DanceViewCoordinator(self.navigationController)
        let danceViewController = danceViewCoordinator.danceViewController
        danceViewCoordinator.danceId = danceId
        self.childCoordinators.append(danceViewCoordinator)
        danceViewCoordinator.finishDelegate = self
        danceViewCoordinator.start()
    }
    
    func pushToPlaySearchView() {
        let playSearchViewCoordinator = PlaySearchCoordinator(self.navigationController)
        let playSearchViewController = playSearchViewCoordinator.playViewController
        self.childCoordinators.append(playSearchViewCoordinator)
        playSearchViewCoordinator.finishDelegate = self
        playSearchViewCoordinator.start()
    }
    
    func presentToStoreView() {
        let storeViewCoordinator = StoreViewCoordinators(self.navigationController)
        self.childCoordinators.append(storeViewCoordinator)
        storeViewCoordinator.finishDelegate = self
        storeViewCoordinator.start()
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.playDanceViewController = PlayVC()
    }

}

extension PlayDanceViewCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators
            .filter { $0.type != childCoordinator.type }
    }
}

