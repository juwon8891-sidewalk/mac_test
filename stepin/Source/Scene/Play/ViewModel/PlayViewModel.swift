import Foundation
import RxSwift
import RxDataSources
import RxRelay

final class PlayDanceViewModel: NSObject {
    private var coordinator: PlayDanceViewCoordinator?
    private var playUseCase: PlayUseCase = PlayUseCase()
    private var isEnergyEnoughRelay = PublishRelay<Bool>()

    private var isHotDancePage: Bool = true
    
    private var myDancePage: Int = 1
    private var hotDancePage: Int = 1
    
    private var danceRelay = PublishRelay<[PlayDanceTableViewDataSection]>()
    private var danceData: [PlayDanceTableViewDataSection] = []
    private var loadingRelay = PublishRelay<Bool>()
    
    private var selectedData: PlayDance?
    private var isChallengeMode: Bool = false
    
    init(coordinator: PlayDanceViewCoordinator) {
        self.coordinator = coordinator
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        let playDataSource = RxTableViewSectionedReloadDataSource<PlayDanceTableViewDataSection>(
        configureCell: { [weak self] dataSource, tableview, indexPath, item in
            guard let cell = tableview.dequeueReusableCell(withIdentifier: PlayDanceTableViewCell.reuseIdentifier) as? PlayDanceTableViewCell else { return UITableViewCell() }
            let data = dataSource[indexPath.section].items[indexPath.row]
            cell.bindData(imagePath: data.coverURL,
                          musicTitle: data.title,
                          artist: data.artist,
                          isLiked: data.alreadyLiked)
            
            cell.heartButtonTapCompletion = { [weak self] state in
                guard let strongSelf = self else {return}
                strongSelf.playUseCase.likeButtonTapped(danceId: data.danceID,
                                                                     state: state)
                .withUnretained(strongSelf)
                .bind(onNext: { (vm, code) in
                    print(code)
                })
                .disposed(by: disposeBag)
            }
            
            cell.playButtonTapCompletion = { [weak self] in
                guard let strongSelf = self else {return}
                output.isPlayButtonTapped.accept(data)
                strongSelf.selectedData = data
            }
            
          return cell
        })
        
        input.searchButtonTapp
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                vm.coordinator?.pushToPlaySearchView()
            })
            .disposed(by: disposeBag)
        
        input.energyBarTapp
            .when(.recognized)
            .withUnretained(self)
            .asDriver{ _ in .never()}
            .drive(onNext: { (vm, gesture) in
                vm.coordinator?.presentToStoreView()
            })
            .disposed(by: disposeBag)
        
        input.viewDidAppear
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                output.isLoadingStart.accept(())
                if vm.isHotDancePage {
                    vm.getHotDanceList(isReset: true, disposeBag: disposeBag)
                } else {
                    vm.getMyDanceList(isReset: true, disposeBag: disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        input.myButtonTapped
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                vm.isHotDancePage = false
                output.isLoadingStart.accept(())
                output.isMyPageSelect.accept(true)
                self.myDancePage = 1
                vm.getMyDanceList(isReset: true, disposeBag: disposeBag)
            })
            .disposed(by: disposeBag)
        
        
        input.hotButtonTapped
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                vm.isHotDancePage = true
                output.isLoadingStart.accept(())
                output.isMyPageSelect.accept(false)
                self.hotDancePage = 1
                vm.getHotDanceList(isReset: true, disposeBag: disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.alertViewOkButtonTapped
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                output.isAlertOkButtonTapped.accept(())
                vm.getEnergyData(disposeBag: disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.alertViewCancelButtonTapped
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                output.isAlertCancelButtonTapped.accept(())
            })
            .disposed(by: disposeBag)

        input.tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        input.tableView.rx.contentOffset.asObservable()
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.asyncInstance)
            .withUnretained(self)
            .bind(onNext: { (vm, point) in
                if point.y > (input.tableView.contentSize.height - input.tableView.frame.size.height) {
                    output.isLoadingStart.accept(())
                    if self.isHotDancePage {
                        self.hotDancePage += 1
                        self.getHotDanceList(disposeBag: disposeBag)
                    } else {
                        self.myDancePage += 1
                        self.getMyDanceList(disposeBag: disposeBag)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        self.loadingRelay
            .withUnretained(self)
            .bind(onNext: { (vm, state) in
                output.isLoadingEnd.accept(())
            })
            .disposed(by: disposeBag)
        
        self.danceRelay
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: input.tableView.rx.items(dataSource: playDataSource))
            .disposed(by: disposeBag)
        
        input.isChallengeMode
            .withUnretained(self)
            .bind(onNext: { (vm, state) in
                vm.isChallengeMode = state
            })
            .disposed(by: disposeBag)
        
        self.isEnergyEnoughRelay
            .withUnretained(self)
            .subscribe(onNext: { (vm, data) in
                guard let danceData = vm.selectedData else {return}
                input.energyView.refreshEnergyBar()
                if data {
                    //challengemode
                    DispatchQueue.main.async {
                        if vm.isChallengeMode {
                            vm.coordinator?.pushToChallengeGameView(danceData: danceData)
                        } else { //practicemode
                            vm.coordinator?.pushToPracticeGameView(danceData: danceData)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        vm.coordinator?.presentToStoreView()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        
        return output
    }
    
    private func getHotDanceList(isReset: Bool = false,
                                 disposeBag: DisposeBag) {
        self.playUseCase.getHotDanceList(page: self.hotDancePage, isResetData: isReset)
            .withUnretained(self)
            .bind(onNext: { (vm, result) in
                if let data = result {
                    vm.danceData = data
                    vm.danceRelay.accept(data)
                    vm.loadingRelay.accept(false)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func getMyDanceList(isReset: Bool = false,
                                disposeBag: DisposeBag) {
        self.playUseCase.getMyDanceList(page: self.myDancePage, isResetData: isReset)
            .withUnretained(self)
            .bind(onNext: { (vm, result) in
                if let data = result {
                    vm.danceRelay.accept(data)
                    vm.loadingRelay.accept(false)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func getEnergyData(disposeBag: DisposeBag) {
        self.loadingRelay.accept(true)
        self.playUseCase.getEnergyData()
            .withUnretained(self)
            .bind(onNext: { (vm, result) in
                if result.data.stamina.onFree {
                    self.isEnergyEnoughRelay.accept(true)
                } else {
                    self.isEnergyEnoughRelay.accept(self.didCanPlayGame(staminaInfo: result.data.stamina))
                }
                self.loadingRelay.accept(false)
            })
            .disposed(by: disposeBag)
    }
    
    var createdAtDate: Date?
    private func didCanPlayGame(staminaInfo: Stamina) -> Bool{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // 주어진 문자열의 형식 지정
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // UTC로 지정
        self.createdAtDate = dateFormatter.date(from: staminaInfo.staminaLatestUpdate)!
        
        let now = Date()
        let utcMillis = now.timeIntervalSince1970 * 1000.0
        let nowUtcDate = Date(timeIntervalSince1970: utcMillis / 1000.0)
        
        /** 시간 차 */
        let diff = nowUtcDate.timeIntervalSince(self.createdAtDate!)
        let addedStamina = diff / 600
        var totalStamina: Int = 0
        
        let minValue = min(5, Int(staminaInfo.stamina + addedStamina))
        if staminaInfo.stamina >= 5 {
            totalStamina = Int(staminaInfo.stamina)
        } else {
            totalStamina = minValue
        }
        print(totalStamina, "토탈")
        if totalStamina >= 1 {
            return true
        } else {
            return false
        }
    }
    
    struct Input {
        let viewDidAppear: Observable<Void>
        let tableView: UITableView
        let hotButtonTapped: Observable<Void>
        let myButtonTapped: Observable<Void>
        let alertViewOkButtonTapped: Observable<Void>
        let alertViewCancelButtonTapped: Observable<Void>
        let isChallengeMode: Observable<Bool>
        let searchButtonTapp: Observable<Void>
        let energyBarTapp: Observable<UITapGestureRecognizer>
        let energyView: EnergyBar
    }

    struct Output {
        var isMyPageSelect = PublishRelay<Bool>()
        var isLoadingStart = PublishRelay<Void>()
        var isLoadingEnd = PublishRelay<Void>()
        var isPlayButtonTapped = PublishRelay<PlayDance>()
        var isAlertCancelButtonTapped = PublishRelay<Void>()
        var isAlertOkButtonTapped = PublishRelay<Void>()
    }
}
extension PlayDanceViewModel: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let danceId = danceData[indexPath.section].items[indexPath.row].danceID
        self.coordinator?.pushToDanceView(danceId: danceId)
    }
    
}
