import UIKit
import SDSKit
import RxSwift
import RxRelay
import RxCocoa

final class PlayVC: UIViewController {
    var disposeBag = DisposeBag()
    var viewModel: PlayDanceViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.setConfig()
        self.bindViewModel()
        self.setAlertViewLayout()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setTabbarConfig()
    }
    
    override func loadView() {
        super.loadView()
        self.view = playDanceView
    }
    
    func bindViewModel() {
        let output = viewModel?.transform(from: .init(viewDidAppear: self.rx.methodInvoked(#selector(viewDidAppear(_:)))
            .map({ _ in })
            .asObservable(),
                                                      tableView: self.playDanceView.tableView,
                                                      hotButtonTapped: self.playDanceView.hotDanceButton.rx.tap.asObservable(),
                                                      myButtonTapped:  self.playDanceView.myDanceButton.rx.tap.asObservable(),
                                                      alertViewOkButtonTapped: self.alertView.okButton.rx.tap.asObservable(),
                                                      alertViewCancelButtonTapped: self.alertView.cancelButton.rx.tap.asObservable(),
                                                      isChallengeMode: self.alertView.isChallengeMode.asObservable(),
                                                      searchButtonTapp: self.playDanceView.playNavigationView.searchButton.rx.tap.asObservable(),
                                                      energyBarTapp: self.playDanceView.playNavigationView.energyBar.rx.tapGesture().asObservable(),
                                                      energyView: self.playDanceView.playNavigationView.energyBar),
                                          disposeBag: disposeBag)
        
        output?.isMyPageSelect
            .withUnretained(self)
            .bind(onNext: { (vc, state) in
                vc.playDanceView.myDanceButton.isSelected = state ? true: false
                vc.playDanceView.hotDanceButton.isSelected = state ? false: true
            })
            .disposed(by: disposeBag)
        
        output?.isLoadingStart
            .withUnretained(self)
            .bind(onNext: { (vc, state) in
                DispatchQueue.main.async {
                    vc.view.showLoadingIndicator()
                }
            })
            .disposed(by: disposeBag)
        
        output?.isLoadingEnd
            .withUnretained(self)
            .bind(onNext: { (vc, state) in
                DispatchQueue.main.async {
                    vc.view.removeLoadingIndicator()
                }
            })
            .disposed(by: disposeBag)
        
        output?.isPlayButtonTapped
            .withUnretained(self)
            .bind(onNext: { (vc, data) in
                DispatchQueue.main.async {
                    vc.showAlertView(data: data)
                }
            })
            .disposed(by: disposeBag)
        
        output?.isAlertOkButtonTapped
            .withUnretained(self)
            .bind(onNext: { (vc, _) in
                vc.removeAlertView()
            })
            .disposed(by: disposeBag)
        
        output?.isAlertCancelButtonTapped
            .withUnretained(self)
            .bind(onNext: { (vc, _) in
                vc.removeAlertView()
            })
            .disposed(by: disposeBag)
    }
    
    private func showAlertView(data: PlayDance) {
        self.alertView.setData(danceData: data)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let strongSelf = self else {return}
                strongSelf.alertView.isHidden = false
                strongSelf.alertView.alpha = 1
            }
        }
    }
    
    private func removeAlertView() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let strongSelf = self else {return}
                strongSelf.alertView.alpha = 0
            } completion: { [weak self] _ in
                guard let strongSelf = self else {return}
                strongSelf.alertView.isHidden = true
            }
        }
    }
    
    func setAlertViewLayout() {
        self.view.addSubview(alertView)
        alertView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        alertView.isHidden = true
        alertView.alpha = 0
    }
    
    func setConfig() {
        playDanceView.tableView.register(PlayDanceTableViewCell.self,
                                         forCellReuseIdentifier: PlayDanceTableViewCell.reuseIdentifier)
    }
    
    
    func setTabbarConfig() {
        self.tabBarController?.tabBar.isTranslucent = true
        self.tabBarController?.tabBar.backgroundColor = .PrimaryBlackDisabled
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private let playDanceView = PlayDanceView()
    private let alertView = SelectGameAlertView()
}
