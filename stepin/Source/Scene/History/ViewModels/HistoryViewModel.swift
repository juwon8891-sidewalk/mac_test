import Foundation
import RxCocoa
import RxSwift
import RxDataSources
import RealmSwift

final class HistoryViewModel: NSObject {
    var coordinator : HistoryCoordinator?
    private var videoList: [HistoryColletionViewDataSection] = [.init(items: [])]
    private var collectionViewRelay = PublishRelay<[HistoryColletionViewDataSection]>()
    private var dataSource: RxCollectionViewSectionedReloadDataSource<HistoryColletionViewDataSection>?
    
    private var checkingList: [Bool] = []
    private var input: Input?
    
    
    private var isCheckModeRelay = PublishRelay<Bool>()
    private var isCheckMode: Bool = false
    private var isHighlightsModeRelay = PublishRelay<Bool>()
    private var isHighlightsMode: Bool = false
    private var navigationTitleRelay = PublishRelay<String>()
    private var deleteBottomViewHidden = PublishRelay<Void>()
    
    private var currentDate: Date = Date()
    
    struct Input {
        let viewDidAppeared: Observable<Void>
        let viewWillDisappear: Observable<Void>
        let calendarView: CalendarView
        let navigationView: HistoryNavigationView
        let storageInfoView: StorageInfoView
        let deleteAlertView: DeleteDanceAlertView
        let collectionView: UICollectionView
        let bottomDeleteBar: VideoDeleteBottomBar
    }
    
    struct Output {
        var setCurrentTitle = PublishRelay<String>()
        var isHiddenBottomDeleteBar = PublishRelay<Bool>()
        var showDeleteAlertView = PublishRelay<Int>()
        var hideDeleteAlertView = PublishRelay<Void>()
        
        var isDeleteMode = PublishRelay<Bool>()
        
    }
    
    init(coordinator: HistoryCoordinator) {
        self.coordinator = coordinator
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        self.input = input
        
        registerCells(input: input)
        addNotificationObserver()
        
        dataSource = RxCollectionViewSectionedReloadDataSource<HistoryColletionViewDataSection>(
            configureCell: { dataSource, collectionView, indexPath, item in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HistoryCVC.reuseIdentifier, for: indexPath) as? HistoryCVC else {return UICollectionViewCell()}
                
                let data = dataSource[indexPath.section].items[indexPath.row]
                cell.bindData(imagePath: data.video_url,
                              score: data.score,
                              isChecked: self.checkingList[indexPath.row],
                              isCheckedMode: self.isCheckMode,
                              isHighlithedMode: self.isHighlightsMode)
                return cell
            })
        
        input.viewDidAppeared
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                self.readDate()
            })
            .disposed(by: disposeBag)
        
        self.collectionViewRelay
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: input.collectionView.rx.items(dataSource: dataSource!))
            .disposed(by: disposeBag)
        
        input.collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        input.deleteAlertView.okButton.rx.tap.asObservable()
            .withUnretained(self)
            .subscribe(onNext: { (vm, _) in
                vm.deleteData()
                output.hideDeleteAlertView.accept(())
            })
            .disposed(by: disposeBag)
        
        input.deleteAlertView.cancelButton.rx.tap.asObservable()
            .withUnretained(self)
            .subscribe(onNext: { (vm, _) in
                output.hideDeleteAlertView.accept(())
            })
            .disposed(by: disposeBag)
        
        input.storageInfoView.deleteButton.rx.tap.asObservable()
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                vm.isCheckModeRelay.accept(true)
            })
            .disposed(by: disposeBag)

        input.storageInfoView.selectAllButton.rx.tap.asObservable()
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                input.storageInfoView.selectAllButton.isSelected.toggle()
                var list: [Bool] = []
                vm.checkingList.forEach { _ in
                    list.append(input.storageInfoView.selectAllButton.isSelected)
                }
                vm.checkingList = list
                input.collectionView.reloadData()
                if vm.isAllSelected() {
                    input.bottomDeleteBar.deleteButton.buttonState = .enabled
                } else {
                    input.bottomDeleteBar.deleteButton.buttonState = .disabled
                }
            })
            .disposed(by: disposeBag)
        
        isCheckModeRelay
            .withUnretained(self)
            .bind(onNext: { (vm, state) in
                vm.isCheckMode = state
                if state {
                    input.collectionView.reloadData()
                    output.isHiddenBottomDeleteBar.accept(!state)
                    output.isDeleteMode.accept(vm.isCheckMode)
                } else {
                    input.collectionView.reloadData()
                    output.isHiddenBottomDeleteBar.accept(!state)
                    output.isDeleteMode.accept(vm.isCheckMode)
                }
            })
            .disposed(by: disposeBag)
        
        input.bottomDeleteBar.cancelButton.rx.tap.asObservable()
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                for index in 0 ..< vm.checkingList.count {
                    vm.checkingList[index] = false
                }
                vm.isCheckModeRelay.accept(false)
            })
            .disposed(by: disposeBag)
        
        input.bottomDeleteBar.deleteButton.rx.tap.asObservable()
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                if input.bottomDeleteBar.deleteButton.buttonState == .enabled {
                    output.showDeleteAlertView.accept(vm.selectedCount())
                }
            })
            .disposed(by: disposeBag)
        
        
        input.navigationView.heartButton.rx.tap.asObservable()
            .withUnretained(self)
            .bind(onNext: { (vm, _) in
                self.isHighlightsModeRelay.accept(input.navigationView.heartButton.isSelected)
            })
            .disposed(by: disposeBag)
        
        isHighlightsModeRelay
            .withUnretained(self)
            .bind(onNext: { (vm, state) in
                if state {
                    self.readLikeDate()
                } else {
                    self.readDate(selectedDate: self.currentDate)
                }
            })
            .disposed(by: disposeBag)
        
        input.collectionView.rx.itemSelected.asObservable()
            .withUnretained(self)
            .bind(onNext: { (vm, indexPath) in
                //선택상태 바꾸어주기
                if self.isCheckMode {
                    vm.checkingList[indexPath.row].toggle()
                    input.collectionView.reloadData()
                    
                    if vm.isSelected() {
                        input.bottomDeleteBar.deleteButton.buttonState = .enabled
                    } else {
                        input.bottomDeleteBar.deleteButton.buttonState = .disabled
                    }
                    
                    input.storageInfoView.selectAllButton.isSelected = vm.isAllSelected()
                } else {
                    self.coordinator?.presentToDetailView(data: self.videoList[indexPath.section].items[indexPath.row])
                }
            })
            .disposed(by: disposeBag)
        
        self.navigationTitleRelay
            .withUnretained(self)
            .bind(onNext: { (vm, date) in
                output.setCurrentTitle.accept(date)
                input.calendarView.reloadData()
            })
            .disposed(by: disposeBag)
        
        self.deleteBottomViewHidden
            .withUnretained(self)
            .bind(onNext: { (vm, _ ) in
                output.isHiddenBottomDeleteBar.accept(true)
            })
            .disposed(by: disposeBag)
        
        
        
        return output
    }
    
    private func selectedCount() -> Int {
        var cnt: Int = 0
        for index in 0 ... self.checkingList.count - 1 {
            if self.checkingList[index] {
                cnt += 1
            }
        }
        return cnt
    }
    
    private func isAllSelected() -> Bool {
        return self.checkingList.allSatisfy { $0 == true }
    }
    
    
    private func isSelected() -> Bool {
        return !self.checkingList.allSatisfy { $0 == false}
    }
    
    private func registerCells(input: Input) {
        input.collectionView.register(HistoryCVC.self, forCellWithReuseIdentifier: HistoryCVC.reuseIdentifier)
    }
    
    private func deleteData() {
        var checkingIndex: Int = 0
        do {
            let realm = try Realm()
            try realm.write {
                for state in self.checkingList {
                    if state {
                        let fileManager: FileManager = FileManager.default
                        let documentPath: URL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        let id = videoList[0].items[checkingIndex].id
                        let video = realm.objects(VideoInfoTable.self).filter("id == %@", id).first
                        let directoryPath: URL = documentPath.appendingPathComponent(video?.video_url ?? "")
                        do {
                            try fileManager.removeItem(at: directoryPath)
                        } catch let e {
                            print(e.localizedDescription)
                        }
                        if let video {
                            realm.delete(video)
                        }
                    }
                    checkingIndex += 1
                }
            }
            self.readDate(selectedDate: self.currentDate)
            self.deleteBottomViewHidden.accept(())
        } catch {
            print("Error deleting video: \\(error)")
        }
    }
    
    
    private func getLatestDate() -> Date? {
        do {
            let realm = try Realm()
            let latestDate = realm.objects(VideoInfoTable.self).sorted(byKeyPath: "created_at",
                                                                       ascending: false).first?.created_at
            if let latestDate = latestDate {
                print("가장 최신 날짜: \(latestDate)")
                return latestDate
            } else {
                print("데이터 없음")
                return nil
            }
        } catch {
            print(error)
            return nil
        }
    }
    
    private func readDate(date: Date = Date(),
                          selectedDate: Date? = nil) {
        let dateString = date.toString(dateFormat: "yyyy-MM-dd'T'HH:mm:ssZ")
        var searchDate = date
        print(dateString)
        
        if let selectedDate {
            self.currentDate = selectedDate
        } else {
            self.currentDate = Date()
        }
        
        if selectedDate == nil {
            if let latestDate = getLatestDate() {
                searchDate = latestDate
            } else {
                searchDate = date
            }
        } else {
            if let selectedDate {
                searchDate = selectedDate
            }
        }

        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: searchDate) // 2023-04-30 00:00:00 +0900
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)! // 2023-05-01 00:00:00 +0900
        self.checkingList = []
        self.videoList = [.init(items: [])]
        do {
            let realm = try Realm()
            try realm.write {
                let videos = realm.objects(VideoInfoTable.self).filter("created_at >= %@ AND created_at < %@", startDate, endDate)
                if videos.count != 0 {
                    videos.forEach { video in
                        let poseData: [PoseData] = video.poseDataList.map { PoseData.init(data: $0.dataArray,
                                                                                          time: $0.time) }
                        let scoreData: [Score] = video.scoreDataList.map { Score(score: $0.score, time: $0.time)}
                        let historyData = HistoryVideoDataModel(id: video.id,
                                                                dance_id: video.dance_id,
                                                                video_url: video.video_url,
                                                                neonVideo_url: video.neonvideo_url,
                                                                created_at: video.created_at,
                                                                dance_name: video.dance_name,
                                                                artist_name: video.artist_name,
                                                                music_url: video.music_url,
                                                                start_time: video.start_time,
                                                                end_time: video.end_time,
                                                                score: video.score,
                                                                sessionId: video.sessionId,
                                                                cover_url: video.cover_url,
                                                                isLiked: video.isLiked,
                                                                poseData: poseData,
                                                                scoreData: scoreData)
                        self.videoList[0].items.append(historyData)
                        self.checkingList.append(false)
                    }
                }
            }
        } catch {
            print("Error updating video: \\(error)")
        }
        self.collectionViewRelay.accept(self.videoList)
        self.input?.navigationView.leftButton.isHidden = false
        self.input?.navigationView.rightButton.isHidden = false
        self.navigationTitleRelay.accept(searchDate.toString(dateFormat: "yyyy.MM.dd"))
    }
    private func readLikeDate() {
        self.checkingList = []
        self.videoList = [.init(items: [])]
        do {
            let realm = try Realm()
            try realm.write {
                let videos = realm.objects(VideoInfoTable.self).filter("isLiked = %@", true)
                if videos.count != 0 {
                    videos.forEach { video in
                        let poseData: [PoseData] = video.poseDataList.map { PoseData.init(data: $0.dataArray,
                                                                                          time: $0.time) }
                        let scoreData: [Score] = video.scoreDataList.map { Score(score: $0.score, time: $0.time)}
                        let historyData = HistoryVideoDataModel(id: video.id,
                                                                dance_id: video.dance_id,
                                                                video_url: video.video_url,
                                                                neonVideo_url: video.neonvideo_url,
                                                                created_at: video.created_at,
                                                                dance_name: video.dance_name,
                                                                artist_name: video.artist_name,
                                                                music_url: video.music_url,
                                                                start_time: video.start_time,
                                                                end_time: video.end_time,
                                                                score: video.score,
                                                                sessionId: video.sessionId,
                                                                cover_url: video.cover_url,
                                                                isLiked: video.isLiked,
                                                                poseData: poseData,
                                                                scoreData: scoreData)
                        self.videoList[0].items.append(historyData)
                        self.checkingList.append(false)
                    }
                }
            }
            self.collectionViewRelay.accept(self.videoList)
            self.input?.navigationView.leftButton.isHidden = true
            self.input?.navigationView.rightButton.isHidden = true
            self.navigationTitleRelay.accept("history_highlight_navigation_title".localized())
        } catch {
            print("Error updating video: \\(error)")
        }
    }
    
    private func addNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didDateSelected(_:)),
            name: NSNotification.Name("History_calendar_selectDate"),
            object: nil
        )
    }
    
    @objc private func didDateSelected(_ sender: NSNotification) {
        let date = sender.object as! Date
        self.currentDate = date
        self.readDate(selectedDate: date)
        self.navigationTitleRelay.accept(date.toString(dateFormat: "YYYY.MM.dd"))
        UIView.animate(withDuration: 0.5) {
            self.input?.calendarView.transform = .identity
        }
    }
    
}

extension HistoryViewModel: UICollectionViewDelegate {}
extension HistoryViewModel: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = ( UIScreen.main.bounds.width - (16)) / 3
        return CGSize(width: width , height: 150.adjusted)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
}
