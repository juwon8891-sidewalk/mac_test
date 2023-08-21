import Foundation
import RxCocoa
import RxSwift

final class BirthDateViewModel {
    weak var coordinator: BirthDateCoordinator?
    private var signUpRepository: AuthRepository?
    private var isFirstLoad: Bool = true
    private var isComplete: Bool = false

    struct Input {
        let datePickerSelected: Observable<Date>
        let nextButtonDidTap: Observable<Void>
    }
    
    struct Output {
        var ageRestrictionInfo = BehaviorRelay<Bool>(value: false)
        var selectedDate = BehaviorRelay<String>(value: "")
        var selectedComplete = BehaviorRelay<Bool>(value: false)
    }
    
    init(coordinator: BirthDateCoordinator, signUpRepository: AuthRepository) {
        self.coordinator = coordinator
        self.signUpRepository = signUpRepository
    }
    
    func getBirthdayTransform(from input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        input.datePickerSelected
            .subscribe(onNext: { [weak self] date in
                let dateStr = date.toString(dateFormat: "MMMM d, yyyy")
                output.ageRestrictionInfo.accept(self!.isFirstLoad ? true: self!.dateCompare(date: date))
                output.selectedDate.accept(self!.isFirstLoad ? "auth_birthDate_placeholder".localized(): dateStr)
                if !self!.isFirstLoad && self!.dateCompare(date: date) {
                    self?.isComplete = true
                    UserDefaults.standard.set(date.toString(dateFormat: "yyyy-MM-dd"),
                                              forKey: UserDefaultKey.birthDate)
                    output.selectedComplete.accept(true)
                } else {
                    self?.isComplete = false
                    output.selectedComplete.accept(false)
                }
                
                self?.isFirstLoad = false
            })
            .disposed(by: disposeBag)
        input.nextButtonDidTap
            .subscribe(onNext: { [weak self] in
                if self!.isComplete {
                    HapticService.shared.playFeedback()
                    self?.coordinator?.pushToNextView()
                }
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
    func calculateAge(birthDate: Date) -> Int {
        let calendar = Calendar.current
        let today = Date()
        
        let birthDateComponents = calendar.dateComponents([.year, .month, .day], from: birthDate)
        let currentDateComponents = calendar.dateComponents([.year, .month, .day], from: today)
        
        var age = currentDateComponents.year! - birthDateComponents.year!
        
        // 생일이 지나지 않았을 경우, 나이에서 1을 빼줍니다.
        if (currentDateComponents.month! < birthDateComponents.month!) ||
            (currentDateComponents.month! == birthDateComponents.month! && currentDateComponents.day! < birthDateComponents.day!) {
            age -= 1
        }
        
        return age
    }

    
    func dateCompare(date: Date) -> Bool {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
////        let specificDate = dateFormatter.string(from: date)
        let currentDate = Date()
        let age = self.calculateAge(birthDate: date)
        
        
        if Locale.current.region == "KR" {
            if age >= 14 {
                return true
            } else {
                return false
            }
        } else { //한국 아닐때
            if age >= 13 {
                return true
            } else {
                return false
            }
        
        }
        
    }
    
    
}
