//
//  SSVItemView.swift
//  stepin
//
//  Created by 김경현 on 2023/08/14.
//

import SwiftUI

struct SSSVItemView: View {
    private weak var itemHandler: SSVPageViewItemHandler?
    
    init(itemHandler: SSVPageViewItemHandler) {
        self.itemHandler = itemHandler
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                isVideoViewReady() ? PlayerContainerView(videoHandler: self.itemHandler!.videoHandler!, size: geo.size)
                : nil
            }
        }.onDisappear {
            if let handler = self.itemHandler {
                handler.release(isReleaseFromMemory: true)
            }
        }
    }
    
    private func isVideoViewReady() -> Bool {
        return self.itemHandler != nil && self.itemHandler!.videoHandler != nil
    }
}
