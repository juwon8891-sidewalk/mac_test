import Foundation
import RxCocoa
import RxSwift
import FSCalendar
import RealmSwift

final class CalendarViewModel: NSObject {
    private var transitionView: UIView = UIView()
    private var viewTranslation = CGPoint(x: 0, y: 0)
    private var viewMaxTranslation = CGPoint(x: 0, y: 0)
    private var viewVelocity = CGPoint(x: 0, y: 0)
    private var isEnableGesture: Bool = true
    
    private var selectedDate: [HistoryVideoDataModel] = []
    
    private var titleLabelRealay = PublishRelay<String>()
    
    private var input: Input?
    
    struct Input {
        let bottomHandleScrol: Observable<UIPanGestureRecognizer>
        let calendarView: FSCalendar
        let nextButtonTapped: Observable<Void>
        let beforeButtonTapped: Observable<Void>
    }
    
    struct Output {
        var currentBottomSheetPoint = BehaviorRelay<CGPoint>(value: .init())
        var headerTitleString = PublishRelay<String>()
        var deselcteDate = PublishRelay<[Date]>()
    }
    
    init(transitionView: UIView) {
        self.transitionView = transitionView
    }
    
    func termsTransform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        self.input = input
        self.loadSelectionDate()
        input.bottomHandleScrol
            .subscribe(onNext: { [weak self] gesture in
                self?.didModalViewScrolled(sender: gesture)
            })
            .disposed(by: disposeBag)
        
        input.calendarView.delegate = self
        
        titleLabelRealay
            .observe(on: MainScheduler.asyncInstance)
            .bind(onNext: {[weak self] title in
                output.headerTitleString.accept(title)
            })
            .disposed(by: disposeBag)
        
        input.nextButtonTapped
            .observe(on: MainScheduler.asyncInstance)
            .withUnretained(self)
            .subscribe(onNext: { _ in
                let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: input.calendarView.currentPage)
                input.calendarView.setCurrentPage(nextMonth!, animated: true)
            })
            .disposed(by: disposeBag)
        
        input.beforeButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { _ in
                let beforeMonth = Calendar.current.date(byAdding: .month, value: -1, to: input.calendarView.currentPage)
                input.calendarView.setCurrentPage(beforeMonth!, animated: true)
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
    func didModalViewScrolled(sender: UIPanGestureRecognizer) {
        viewTranslation = sender.translation(in: self.transitionView)
        viewVelocity = sender.translation(in: self.transitionView)
        print(viewTranslation.y)
            switch sender.state {
            case .changed:
                //최대높이보다 적게 움직일때만 움직이게
                if self.viewTranslation.y < 0 {
                    self.transitionView.transform = CGAffineTransform(translationX: 0, y: viewTranslation.y + self.transitionView.frame.height)
                }
            case .ended:
                //반 이상 올라가면 위로 올라가게
                if self.viewTranslation.y <= -(self.transitionView.frame.height / 3) {
                    UIView.animate(withDuration: 0.5, delay: 0) {
                        self.transitionView.transform = .identity
                        NotificationCenter.default.post(name: NSNotification.Name("calendar_view_removed"),
                                                        object: nil,
                                                        userInfo: nil)
                    }
                } else {
                    UIView.animate(withDuration: 0.5, delay: 0) {
                        self.transitionView.transform = CGAffineTransform(translationX: 0, y: ScreenUtils.setWidth(value: 405))
                    }
                }
                break
            default:
                break
            }
    }
    
}
extension CalendarViewModel: FSCalendarDelegate {
    func loadSelectionDate() {
        do {
            let calendar = Calendar.current
            let startDate = calendar.startOfDay(for: Date())
            let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
            
            let realm = try Realm()
            self.selectedDate = []
            try realm.write {
//                let videos = realm.objects(VideoInfoTable.self).filter("created_at >= %@ AND created_at < %@", startDate, endDate)
                let videos = realm.objects(VideoInfoTable.self)
                if videos.count != 0 {
                    videos.forEach { video in
                        let poseData: [PoseData] = video.poseDataList.map { PoseData.init(data: $0.dataArray,
                                                                                               time: $0.time) }
                        let scoreData: [Score] = video.scoreDataList.map { Score(score: $0.score, time: $0.time)}
                        print(poseData)
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
                        self.selectedDate.append(historyData)
                    }
                }
            }
            input?.calendarView.reloadData()
        } catch {
            print("Error updating video: \\(error)")
        }
    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        NotificationCenter.default.post(name: NSNotification.Name("History_calendar_selectDate"),
                                        object: date,
                                        userInfo: nil)
        titleLabelRealay.accept(date.toString(dateFormat: "YYYY.MM.dd"))
        
    }
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        titleLabelRealay.accept(calendar.currentPage.toString(dateFormat: "YYYY.MM.dd"))
    }
}
extension CalendarViewModel: FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date) // 2023-04-30 00:00:00 +0900
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)! // 2023-05-01 00:00:00 +0900
        
        var containData = self.selectedDate.filter { $0.created_at >= startDate && $0.created_at <= endDate }
        if containData.isEmpty {
            return .stepinWhite40
        } else {
            return .stepinWhite100
        }
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date) // 2023-04-30 00:00:00 +0900
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)! // 2023-05-01 00:00:00 +0900
        
        let containData = self.selectedDate.filter { $0.created_at >= startDate && $0.created_at < endDate}
        if containData.isEmpty {
            return false
        } else {
            return true
        }
    }
}
