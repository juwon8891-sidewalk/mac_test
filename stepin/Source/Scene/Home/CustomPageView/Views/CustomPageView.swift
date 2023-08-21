import Foundation
import SwiftUI

struct CustomPageView: View {
    
    @ObservedObject var pageViewHandler: CustomPageViewHandler
    @State var offset = CGFloat.zero
//    @State var topPadding = CGFloat.zero
//    @State var bottomPadding = CGFloat.zero
    @State var isScrolling = false
    
    init(pageViewHandler: CustomPageViewHandler) {
        self.pageViewHandler = pageViewHandler
    }
    
    var body: some View {
        
        Group {
            if pageViewHandler.props.direction == .Horizontal {
                LazyHStack(spacing: 0) {
                    ForEach(0..<self.pageViewHandler.itemViewList.count, id: \.self) { idx in
                        self.pageViewHandler.itemViewList[idx]
                            .setPropsFrame(props: pageViewHandler.props)
                    }
                }
                .offset(x: pageViewHandler.currentOffset)
                .frame(width: pageViewHandler.props.itemWidth, height: pageViewHandler.props.itemHeight, alignment: .leading)
                .background(.clear)
            }
            else {
                LazyVStack(spacing: 0) {
                    ForEach(0..<self.pageViewHandler.itemViewList.count, id: \.self) { idx in
                        self.pageViewHandler.itemViewList[idx]
                            .setPropsFrame(props: self.pageViewHandler.props)
                        
                    }
                }
                .offset(y: pageViewHandler.currentOffset)
                .frame(width: pageViewHandler.props.itemWidth, height: pageViewHandler.props.itemHeight, alignment: .top)
                
            }
        }.gesture(DragGesture()
            .onChanged { value in
                onGesture(value: value)
            }
            .onEnded { value in
                onGestureEnded(value: value)
            })
        .setFullScreenFrame(isHorizontal: pageViewHandler.props.direction == .Horizontal)
        .onAppear {
            pageViewHandler.onAppeared()
        }
        .onDisappear{
            pageViewHandler.onDisappeared()
        }
        // 전체화면 변경
        .onReceive(pageViewHandler.$isFullScreen) { isFullScreen in
            setFullScreen(isFullScreen: isFullScreen)
        }
        .onReceive(pageViewHandler.$itemIndex) { index in
            pageViewHandler.changeItemsState()
            
        }
    }
    
    private func setFullScreen(isFullScreen: Bool) {
        if isFullScreen {
            
            pageViewHandler.currentOffset = CGFloat(-pageViewHandler.itemIndex) * (pageViewHandler.props.direction == .Horizontal ? UIScreen.main.bounds.width : UIScreen.main.bounds.height)
            
            print(CGFloat(-pageViewHandler.itemIndex) * (pageViewHandler.props.direction == .Horizontal ? UIScreen.main.bounds.width : UIScreen.main.bounds.height))
            pageViewHandler.props.frameWidth = UIScreen.main.bounds.width
            pageViewHandler.props.frameHeight = UIScreen.main.bounds.height
            pageViewHandler.isFullSuccess = true
            
            withAnimation(.spring(response: 0.3)) {
                
                pageViewHandler.props.itemWidth = UIScreen.main.bounds.width
                pageViewHandler.props.itemHeight = UIScreen.main.bounds.height
                
                pageViewHandler.props.itemOffset = 0
                
            }
        }
        else {
            withAnimation(.spring(response: 0.3)) {
                pageViewHandler.props = pageViewHandler.defaultProps
                pageViewHandler.currentOffset = pageViewHandler.defaultProps.itemOffset + CGFloat(-pageViewHandler.itemIndex) * (pageViewHandler.props.direction == .Horizontal ? pageViewHandler.defaultProps.itemWidth : pageViewHandler.defaultProps.itemHeight)
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                pageViewHandler.isFullSuccess = false
            }
        }
    }
    
    private func onGesture(value: DragGesture.Value) {
//        if(!pageViewHandler.itemHandlerList[pageViewHandler.itemIndex].isInitialized || isScrolling) {
//            return
//        }
        
        if(isScrolling) {
            return
        }
        
        let props = pageViewHandler.props
        offset = pageViewHandler.props.direction == .Horizontal ? value.translation.width : value.translation.height
        
        let itemSize = pageViewHandler.props.direction == .Horizontal ? props.itemWidth : props.itemHeight
        pageViewHandler.currentOffset = props.itemOffset + CGFloat(-pageViewHandler.itemIndex) * (itemSize) + offset
    }
    
    private func onGestureEnded(value: _ChangedGesture<DragGesture>.Value) {
        if isScrolling { return }
        isScrolling = true
        
        withAnimation(.spring(response: 0.3)) {
            let props = pageViewHandler.props
            let transitionValue = props.direction == .Horizontal ? value.predictedEndTranslation.width : value.predictedEndTranslation.height
        
            let direction = transitionValue > 0 ? 1.0 : -1.0
            
            let itemSize = props.direction == .Horizontal ? props.itemWidth : props.itemHeight
            offset = min(abs(transitionValue), itemSize) * direction
            var itemIndex = pageViewHandler.itemIndex
            itemIndex -= Int((offset / itemSize).rounded())
            pageViewHandler.itemIndex = max(0, min(itemIndex, pageViewHandler.itemHandlerList.count - 1))
            offset = 0
            
            pageViewHandler.currentOffset = props.itemOffset + CGFloat(-pageViewHandler.itemIndex) * (itemSize) + offset
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            isScrolling = false
        }
    }
    
}

extension View {
    func setFullScreenFrame(isHorizontal: Bool) -> some View {
        self.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: isHorizontal ? .leading : .top)
            .background(.clear)
    }
    
    func setPropsFrame(props: CustomPageViewProps) -> some View {
        self.frame(width: props.frameWidth, height: props.frameHeight, alignment: .center).background(.clear)
    }
}
