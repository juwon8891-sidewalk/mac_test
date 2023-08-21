import Foundation
import RxSwift
import RxRelay
import RxDataSources

final class SuperShortFormViewModel {
    internal func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        var output = Output()
        
        return output
    }
    
    struct Input {
        
    }
    struct Output {
        var isCurrentVideoHidden = PublishRelay<Bool>()
    }
}
 
