import Foundation
import RxSwift
import RxRelay
import RxDataSources

final class NeonColorSelectButtonViewModel  {
    private var selectedColor: UIColor = .white

    internal func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        var output = Output()
        
        input.defualtButton.rx.tap.asObservable()
            .subscribe(onNext: {
                output.didSelecteViewhidden.accept(false)
            })
            .disposed(by: disposeBag)
        
        input.selectButton1.rx.tap.asObservable()
            .withUnretained(self)
            .subscribe(onNext: { (view) in
                self.selectedColor = input.selectButton1.backgroundColor!
                output.selectedColor.accept(self.selectedColor)
                output.didSelecteViewhidden.accept(true)
            })
            .disposed(by: disposeBag)
        
        input.selectButton2.rx.tap.asObservable()
            .withUnretained(self)
            .subscribe(onNext: { (view) in
                self.selectedColor = input.selectButton2.backgroundColor!
                output.selectedColor.accept(self.selectedColor)
                output.didSelecteViewhidden.accept(true)
            })
            .disposed(by: disposeBag)
        
        input.selectButton3.rx.tap.asObservable()
            .withUnretained(self)
            .subscribe(onNext: { (view) in
                self.selectedColor = input.selectButton3.backgroundColor!
                output.selectedColor.accept(self.selectedColor)
                output.didSelecteViewhidden.accept(true)
            })
            .disposed(by: disposeBag)
        
        input.selectButton4.rx.tap.asObservable()
            .withUnretained(self)
            .subscribe(onNext: { (view) in
                self.selectedColor = input.selectButton4.backgroundColor!
                output.selectedColor.accept(self.selectedColor)
                output.didSelecteViewhidden.accept(true)
            })
            .disposed(by: disposeBag)
        
        input.selectButton5.rx.tap.asObservable()
            .withUnretained(self)
            .subscribe(onNext: { (view) in
                self.selectedColor = input.selectButton5.backgroundColor!
                output.selectedColor.accept(self.selectedColor)
                output.didSelecteViewhidden.accept(true)
            })
            .disposed(by: disposeBag)
        
        input.selectButton6.rx.tap.asObservable()
            .withUnretained(self)
            .subscribe(onNext: { (view) in
                self.selectedColor = input.selectButton6.backgroundColor!
                output.selectedColor.accept(self.selectedColor)
                output.didSelecteViewhidden.accept(true)
            })
            .disposed(by: disposeBag)

        return output
    }
    

    struct Input {
        let defualtButton: UIButton
        let selectButton1: UIButton
        let selectButton2: UIButton
        let selectButton3: UIButton
        let selectButton4: UIButton
        let selectButton5: UIButton
        let selectButton6: UIButton
    }
    struct Output {
        var didSelecteViewhidden = PublishRelay<Bool>()
        var selectedColor = PublishRelay<UIColor>()
    }

}

