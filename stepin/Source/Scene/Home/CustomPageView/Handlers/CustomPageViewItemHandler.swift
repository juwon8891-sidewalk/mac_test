import Foundation

class CustomPageViewItemHandler : CustomPageViewItemHandlerProtocol {
    @Published var isInitialized: Bool = false
    
    func initialize(isAutoPlay: Bool) {}
    
    func resize(size: CGSize) {}
    
    func release(isReleaseFromMemory: Bool){}
}

protocol CustomPageViewItemHandlerProtocol {
    var isInitialized: Bool { get set }
    func initialize(isAutoPlay: Bool)
    func resize(size: CGSize)
    func release(isReleaseFromMemory: Bool)
}
