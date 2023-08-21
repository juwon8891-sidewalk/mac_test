import Foundation
import RxSwift
import RxRelay
import RxDataSources

final class VideoMoreViewModel: NSObject {
    var coordinator: VideoMoreCoordinator?
    
    internal func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        var output = Output()
        
        return output
    }
    
    init(coordinator: VideoMoreCoordinator) {
        self.coordinator = coordinator
    }
    
    struct Input {
        let videoBottomSheet: MyVideoBottomSheet
        let otherVideoBottomSheet: VideoBottomSheet
    }
    
    struct Output {
        
    }
    
    
}
