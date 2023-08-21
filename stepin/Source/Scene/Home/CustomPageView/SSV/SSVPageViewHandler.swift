import Foundation
import SwiftUI

class SSVPageViewHandler : CustomPageViewHandler {
    private weak var homeViewModel: HomeViewModel?
    
    init(direction: Direction, isFullScreen: Bool, itemWidth: CGFloat, itemHeight: CGFloat, itemOffset: CGFloat, homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
        
        super.init(direction: direction, isFullScreen: isFullScreen, itemWidth: itemWidth, itemHeight: itemHeight, itemOffset: itemOffset)
    }
    
    
    var setFullScreenCallback: ((Bool) -> Void)?
    
    override func onAppeared() {
        self.loadNextPage()
    }
    
    override func onDisappeared() {}
    
    override func loadNextPage() {
        if(isLoading) { return }
        isLoading = true
        if let viewModel = self.homeViewModel {
            if let homeRepository = viewModel.homeRepository {
                viewModel.authRepository.postRefreshToken()
                    .withUnretained(self)
                    .flatMap { (handler, _) in (homeRepository.getShortForm(page: handler.pageIndex)) }
                    .withUnretained(self)
                    .subscribe(onNext: { (handler, result) in
                        handler.isLoading = false
                        self.pageIndex += 1
                        handler.loadSSVInfoList(handler: handler, result: result)
                    })
                    .disposed(by: viewModel.disposeBag)
            }
        }
    }
    
    private func loadSSVInfoList(handler: SSVPageViewHandler, result: SuperShortFormCollectionViewDataSection) {
        var itemHandlerList = [SSVPageViewItemHandler]()
        var itemViewList = [CustomPageItemView]()
        for index in 0 ... result.items.count - 1 {
            let itemHandler = SSVPageViewItemHandler(itemInfo: result.items[index])
            let view = CustomPageItemView(pageViewHandler: self, index: self.itemViewList.count + index, childView: AnyView(SSSVItemView(itemHandler: itemHandler)))
            itemHandlerList.append(itemHandler)
            itemViewList.append(view)
        }
        
        DispatchQueue.main.async {
            handler.itemHandlerList.append(contentsOf: itemHandlerList)
            handler.itemViewList.append(contentsOf: itemViewList)
            
            handler.objectWillChange.send()
            
            
            if !self.isInitialized {
                self.isInitialized = true
                self.jumpToPage(page: 1)
                self.isFullSuccess = false
                self.changeItemsState()
                
            }
        }
    }
    
    override func setFullScreen(isFullScreen: Bool) {
        setFullScreenCallback?(isFullScreen)
        super.setFullScreen(isFullScreen: isFullScreen)
    }
    
    override func itemTapCallback() {
        setFullScreen(isFullScreen: !isFullScreen)
    }
    
    override func changeItemsState() {
        for (index, handler) in self.itemHandlerList.enumerated() {
            if(index >= self.itemIndex - 2 && index <= self.itemIndex + 2) {
//                if(index == self.itemIndex) {
                if(index == self.itemIndex) {
                    handler.initialize(isAutoPlay: true)
                    (handler as! SSVPageViewItemHandler).videoLoopCallback = self.videoLoopCallback
                }
                else{
                    handler.initialize(isAutoPlay: false)
                    (handler as! SSVPageViewItemHandler).videoLoopCallback = nil
                }
            }
            else{
                (handler as! SSVPageViewItemHandler).videoLoopCallback = nil
                handler.release(isReleaseFromMemory: false)
            }
        }
        
        super.changeItemsState()
    }
    
    private func videoLoopCallback() {
        setStepinButton()
    }
    
    func setStepinButton() {
        let info = (itemHandlerList[itemIndex] as! SSVPageViewItemHandler).currentVideoInfo
        self.homeViewModel?.setDanceIdInSwiftUI(danceId: info.danceID, coverURL: info.coverURL)
    }

    override func release() {}
}
