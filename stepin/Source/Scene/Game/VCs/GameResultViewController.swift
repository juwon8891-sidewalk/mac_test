import UIKit
import SDSKit
import SnapKit
import Then
import RxSwift
import RxCocoa


final class GameResultViewController: UIViewController {
    var viewModel: GameResultViewModel?
    var disposeBag = DisposeBag()
    
    override func loadView() {
        super.loadView()
        self.view = resultView
        self.bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLayout()
    }
    
    func bindViewModel() {
        let output = viewModel?.transform(from: .init(viewDidAppear: self.rx.methodInvoked(#selector(viewDidAppear(_:)))
            .map({ _ in })
            .asObservable(),
                                                      continueButtonTapped: self.resultView.continueButton.rx.tap.asObservable(),
                                                      doneButtonTapped: self.resultView.navigationBar.rightButton.rx.tap.asObservable(),
                                                      alertViewOkButtonTapped: self.alertView.okButton.rx.tap.asObservable(), alertViewCancelButtonTapped: self.alertView.cancelButton.rx.tap.asObservable()),
                                          disposeBag: disposeBag)
        output?.scoreOutput
            .withUnretained(self)
            .bind(onNext: { ( vc, arg1) in
                let (scoreData, score) = arg1
                vc.resultView.bindData(scoreData: scoreData,
                                       score: score)
                vc.resultView.scoreHeaderView.setScoreLabelShadow(state: score.scoreToState(score: Float(score) ?? 0),
                                                                  score: score,
                                                                  color: score.scoreToColor(score: Float(score) ?? 0))
            })
            .disposed(by: disposeBag)
        
        output?.rankData
            .withUnretained(self)
            .bind(onNext: { (vc, ranks) in
                DispatchQueue.main.async {
                    if ranks[0] <= 50 {
                        vc.resultView.bindRankData(rank: vc.ordinalString(for: ranks[0]))
                    }
                    //expected, myrank
                    //게임을 한번도 안한 경우
                    let expectedRank = ranks[0], myRank = ranks[1]
                    if myRank == 0 {
                        vc.resultView.changeRankView.bindRank(myRank: "-",
                                                              expectedRank: String(expectedRank))
                    } else {
                        if expectedRank < myRank {
                            vc.resultView.changeRankView.bindRank(myRank: String(myRank),
                                                                  expectedRank: String(expectedRank))
                        }
                        else {
                            vc.resultView.changeRankView.isHidden = true
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        output?.musicData
            .withUnretained(self)
            .bind(onNext: { (vc, musicData) in
                vc.resultView.scoreHeaderView.bindMusicInfoData(musicImagePath: musicData[0],
                                                                musicTitle: musicData[1],
                                                                artist: musicData[2])
            })
            .disposed(by: disposeBag)
        
        output?.continueButtonTap
            .debug()
            .withUnretained(self)
            .bind(onNext: { (vc, data) in
                vc.showAlertView(data: data)
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
    
    func ordinalString(for number: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal
        numberFormatter.locale = .init(identifier: "en")
        guard let ordinalString = numberFormatter.string(from: NSNumber(value: number)) else {
            return "\(number)"
        }
        return ordinalString
    }
    
    func setLayout() {
        self.view.addSubview(alertView)
        alertView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        alertView.isHidden = true
        alertView.alpha = 0
        
    }
    
    private let resultView = GameResultView()
    private let alertView = SelectGameAlertView()
    
}
