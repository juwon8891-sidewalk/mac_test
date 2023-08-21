import Foundation
import SwiftUI

class SSVPageViewItemHandler: CustomPageViewItemHandler {
    var itemInfo: SuperShortform
    var videoHandler: VideoHandler?
    var currentVideoInfo: Video
    var currentVideoIndex: Int = 0
    var videoLoopCallback: (() -> Void)? = nil
    
    init(itemInfo: SuperShortform) {
        self.itemInfo = itemInfo
        self.videoHandler = VideoHandler(videoPath: URL(filePath: self.itemInfo.videoUrl))
        self.currentVideoInfo = itemInfo.video[0]
        super.init()
        if let handler = self.videoHandler {
            handler.videoLoopCallback = self.ssvVLoopCallback
            handler.initializedCallback = self.initializeCallback
            handler.releasedCallback = self.releasedCallback
        }
    }
    
    func ssvVLoopCallback() -> Void {
        currentVideoInfo = getCurrentItemInfo()
        self.videoLoopCallback?()
    }
    
    func initializeCallback() -> Void {
        self.isInitialized = true
    }
    
    func releasedCallback() -> Void {
        self.isInitialized = false
    }
    
    func getCurrentItemInfo() -> Video{
        for index in 0 ... self.itemInfo.section.count - 1 {
            let endTime = self.itemInfo.section[index].end
            
            if let handler = self.videoHandler {
                if(handler.currentVideoTime < endTime) {
                    self.currentVideoIndex = index
                    break
                }
            }
        }
        
        return self.itemInfo.video[currentVideoIndex]
    }
    
    override func initialize(isAutoPlay: Bool) {
        if let handler = self.videoHandler {
            handler.reinitialize(isAutoPlay: isAutoPlay)
        }
    }
    
    override func resize(size: CGSize) {
        self.videoHandler?.resize(size: size)
    }
    
    override func release(isReleaseFromMemory: Bool) {
        if let handler = self.videoHandler {
            handler.release()
        }
        if isReleaseFromMemory {
            self.videoHandler = nil
        }
    }
}
