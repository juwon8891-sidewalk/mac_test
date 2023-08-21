import UIKit
import FSCalendar
import SnapKit
import Then
import RxSwift
import RxRelay

class CalendarView: UIView {
    var disposeBag = DisposeBag()
    private var viewModel: CalendarViewModel?
    
    init() {
        super.init(frame: .zero)
        setLayout()
        setCalendarLayout()
        bindBaseViewModel()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func bindBaseViewModel() {
        self.viewModel = CalendarViewModel(transitionView: self)
        let output = viewModel!.termsTransform(from: .init(bottomHandleScrol: handleAreaView.rx.panGesture().asObservable(),
                                                           calendarView: self.calendarView,
                                                           nextButtonTapped: self.rightButton.rx.tap.asObservable(),
                                                           beforeButtonTapped: self.leftButton.rx.tap.asObservable()),
                                              disposeBag: disposeBag)
        
        output.currentBottomSheetPoint
            .asDriver{ _ in .never() }
            .drive(onNext: { [weak self] position in
                print(position)
            })
            .disposed(by: disposeBag)
        
        output.headerTitleString
            .observe(on: MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] title in
                self?.calendarHeaderTitleLabel.text = title
            })
            .disposed(by: disposeBag)
        
    }
    
    func reloadData() {
        self.viewModel?.loadSelectionDate()
    }
    
    private func setCalendarLayout() {
        self.calendarView.calendarHeaderView.isHidden = true
        self.calendarView.appearance.todayColor = .clear
        self.calendarView.appearance.titleDefaultColor = .stepinWhite100
        self.calendarView.appearance.titleFont = .suitMediumFont(ofSize: 16)
        self.calendarView.appearance.borderRadius = 0.3
        self.calendarView.appearance.selectionColor = .stepinWhite100
        self.calendarView.appearance.titleSelectionColor = .stepinBlack100
        self.calendarView.appearance.weekdayTextColor = .stepinWhite100
        self.calendarView.firstWeekday = 2
        
        self.calendarView.calendarWeekdayView.weekdayLabels.forEach { label in
            label.font = .suitMediumFont(ofSize: 16)
        }

        self.calendarView.calendarWeekdayView.weekdayLabels[0].text = "M"
        self.calendarView.calendarWeekdayView.weekdayLabels[1].text = "T"
        self.calendarView.calendarWeekdayView.weekdayLabels[2].text = "W"
        self.calendarView.calendarWeekdayView.weekdayLabels[3].text = "T"
        self.calendarView.calendarWeekdayView.weekdayLabels[4].text = "F"
        self.calendarView.calendarWeekdayView.weekdayLabels[5].text = "S"
        self.calendarView.calendarWeekdayView.weekdayLabels[6].text = "S"
        self.calendarView.placeholderType = .none
        self.calendarHeaderTitleLabel.text = Date().toString(dateFormat: "YYYY.MM.dd")
        
    }
    
    
    
    
    private func setLayout() {
        self.backgroundColor = .stepinBlack100
        self.calendarHeaderView.addSubviews([calendarHeaderTitleLabel, leftButton, rightButton])
        calendarHeaderTitleLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.height.equalTo(25)
        }
        leftButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalTo(calendarHeaderTitleLabel.snp.leading).inset(ScreenUtils.setWidth(value: 5))
//            $0.centerY.equalTo(calendarHeaderTitleLabel)
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 48))
        }
        rightButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalTo(calendarHeaderTitleLabel.snp.trailing).inset(ScreenUtils.setWidth(value: 5))
//            $0.centerY.equalTo(calendarHeaderTitleLabel)
            $0.width.height.equalTo(ScreenUtils.setWidth(value: 48))
        }
        self.addSubviews([calendarView, handleAreaView, calendarHeaderView])
        calendarHeaderView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(ScreenUtils.setWidth(value: 17))
            $0.leading.trailing.equalToSuperview()
        }
        
        calendarView.snp.makeConstraints {
            $0.top.equalTo(self.calendarHeaderView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.setWidth(value: 34))
            $0.bottom.equalTo(handleAreaView.snp.top)
        }
        
        handleAreaView.addSubview(bottomHandle)
        bottomHandle.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(ScreenUtils.setWidth(value: 7))
            $0.centerX.equalToSuperview()
            $0.width.equalTo(ScreenUtils.setWidth(value: 135))
            $0.height.equalTo(ScreenUtils.setWidth(value: 5))
        }
        handleAreaView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.setWidth(value: 20))
        }
        bottomHandle.layer.cornerRadius = ScreenUtils.setWidth(value: 3)
        self.layer.cornerRadius = ScreenUtils.setWidth(value: 20)
        self.clipsToBounds = true
    }
    
    
    internal var calendarView = FSCalendar()
    private var calendarHeaderView = UIView().then {
        $0.backgroundColor = .stepinBlack100
    }
    private var calendarHeaderTitleLabel = UILabel().then {
        $0.font = .suitExtraBoldFont(ofSize: 20)
        $0.textColor = .stepinWhite100
    }
    private var leftButton = UIButton().then {
        $0.setImage(ImageLiterals.icWhiteArrow, for: .normal)
    }
    private var rightButton = UIButton().then {
        $0.setImage(ImageLiterals.icRightArrow, for: .normal)
    }
    private var handleAreaView = UIView().then {
        $0.backgroundColor = .stepinBlack100
    }
    private var bottomHandle = UIView().then {
        $0.backgroundColor = .stepinWhite100
    }
}
