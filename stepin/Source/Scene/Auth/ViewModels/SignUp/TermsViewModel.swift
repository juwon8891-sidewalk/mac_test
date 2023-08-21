import Foundation
import RxCocoa
import RxSwift

final class TermsViewModel {
    weak var coordinator: TermsCoordinator?
    private var signUpRepository: AuthRepository?
    
    private var allSelected: Bool = false
    private var temrsModel: [Bool] = [false, false, false]
    private var selectPresent: Bool = false
    
    var termSelectedRelay = PublishRelay<Int>()
    
    

    struct TermsInput {
        let agreeAllButtonDidTap: Observable<Void>
        let temrs1ButtonDidTap: TermsButton
        let temrs2ButtonDidTap: TermsButton
        let temrs3ButtonDidTap: TermsButton
//        let temrs4ButtonDidTap: Observable<Void>
//        let temrs5ButtonDidTap: Observable<Void>
        let nextButtonDidTap: Observable<Void>
        let backButtonDidTap: Observable<Void>
        let didTermsConditionButtonTapped: Observable<Void>
    }
    
    struct TermsOutput {
        var termsSelectedArray = PublishRelay<[Bool]>()
        var termsAllSelected = PublishRelay<Bool>()
    }
    
    init(coordinator: TermsCoordinator, signUpRepository: AuthRepository) {
        self.coordinator = coordinator
        self.signUpRepository = signUpRepository
    }
    
    private func termsAllSelected() {
        if self.allSelected { self.allSelected = false}
        else { self.allSelected = true}
        
        for index in 0 ... self.temrsModel.count - 1 {
            if self.allSelected {
                self.temrsModel[index] = true
            } else {
                self.temrsModel[index] = false
            }
        }
    }
    
    private func isTermsAllSelected() -> Bool {
        var trueCnt = 0
        self.temrsModel.forEach {
            if $0 { trueCnt += 1}
        }
        if trueCnt == 2 {
            if self.temrsModel[2] == false {
                return true
            }
        }
        else if trueCnt == self.temrsModel.count { return true }
        else { return false }
        return false
    }
    
    internal func setTermsArray(index: Int) {
        if self.temrsModel[index] {
            temrsModel[index] = false
        } else {
            temrsModel[index] = true
        }
        self.allSelected = isTermsAllSelected()
    }
    
    
    func termsTransform(from input: TermsInput, disposeBag: DisposeBag) -> TermsOutput {
        let output = TermsOutput()
        
        input.agreeAllButtonDidTap
            .subscribe(onNext: { [weak self] _ in
                HapticService.shared.playFeedback()
                self?.termsAllSelected()
                output.termsSelectedArray.accept(self!.temrsModel)
                output.termsAllSelected.accept(self!.allSelected)
            })
            .disposed(by: disposeBag)
        
        self.termSelectedRelay
            .withUnretained(self)
            .bind(onNext: { (viewModel, index) in
                output.termsSelectedArray.accept(self.temrsModel)
                output.termsAllSelected.accept(self.allSelected)
                if index == 0 {
                    input.temrs1ButtonDidTap.isSelected = true
                } else {
                    input.temrs2ButtonDidTap.isSelected = true
                }
            })
            .disposed(by: disposeBag)
        
        
        input.temrs1ButtonDidTap.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                HapticService.shared.playFeedback()
                if !(self?.temrsModel[0])! {
                    self?.coordinator?.pushToUserLicense()
                } else {
                    self?.setTermsArray(index: 0)
                    output.termsSelectedArray.accept(self!.temrsModel)
                    output.termsAllSelected.accept(self!.allSelected)
                }
            })
            .disposed(by: disposeBag)
        
        
        input.temrs2ButtonDidTap.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                HapticService.shared.playFeedback()
                if !(self?.temrsModel[1])! {
                    self?.coordinator?.pushToPersonalInformation()
                } else {
                    self?.setTermsArray(index: 1)
                    output.termsSelectedArray.accept(self!.temrsModel)
                    output.termsAllSelected.accept(self!.allSelected)
                }
            })
            .disposed(by: disposeBag)
        
        input.temrs3ButtonDidTap.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.setTermsArray(index: 2)
                output.termsSelectedArray.accept(self!.temrsModel)
                output.termsAllSelected.accept(self!.allSelected)
            })
            .disposed(by: disposeBag)

        input.didTermsConditionButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { _ in 
                self.coordinator?.pushToTerms()
            })
            .disposed(by: disposeBag)


//
//        input.temrs4ButtonDidTap
//            .subscribe(onNext: { [weak self] _ in
//                HapticService.shared.playFeedback()
//                self?.setTermsArray(index: 3)
//                output.termsSelectedArray.accept(self!.temrsModel)
//                output.termsAllSelected.accept(self!.allSelected)
//            })
//            .disposed(by: disposeBag)
//
//        input.temrs5ButtonDidTap
//            .subscribe(onNext: { [weak self] _ in
//                HapticService.shared.playFeedback()
//                self?.setTermsArray(index: 4)
//                output.termsSelectedArray.accept(self!.temrsModel)
//                output.termsAllSelected.accept(self!.allSelected)
//            })
//            .disposed(by: disposeBag)
        
        input.nextButtonDidTap
            .subscribe(onNext: { [weak self] _ in
                if self!.allSelected {
                    HapticService.shared.playFeedback()
                    self?.selectPresent = AuthLoginInfo.isSocialLogin
                    self?.coordinator?.didTapNextButton(boolValue: self?.selectPresent ?? false)
                }
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
    
}
