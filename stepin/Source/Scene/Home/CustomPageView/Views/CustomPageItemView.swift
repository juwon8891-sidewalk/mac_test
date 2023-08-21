import SwiftUI

struct CustomPageItemView: View {
    @ObservedObject var pageViewHandler: CustomPageViewHandler
    
    var index: Int
    var childView: AnyView
    
    @State var scaleFactor: CGFloat = 1
    @State var isResizing : Bool = false
    
    var body: some View {
        ZStack {
            isHighlight() ? getShadowView() : nil
            childView
                .setItemFrame(props: pageViewHandler.props)
                .clip(isFullScreen: pageViewHandler.isFullScreen)
                .drawItemOutline(props: pageViewHandler.props, isDraw: isHighlight())
        }
        .setItemFrame(props: pageViewHandler.props)
        .scaleEffect(isResizing || pageViewHandler.isFullScreen ? scaleFactor : getScaleFactor())
        .onTapGesture {
            if isResizing { return }
            scaleFactor = getScaleFactor()
            isResizing = true
            
            pageViewHandler.itemTapCallback()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                isResizing = false
            }
        }
        .onReceive(pageViewHandler.$isFullScreen) { isFullScreen in
            self.changeScaleFactor(isFullScreen: isFullScreen)
        }
        
    }
    
    private func isHighlight() -> Bool {
        return (!pageViewHandler.isFullScreen &&
        pageViewHandler.itemIndex == index &&
        !pageViewHandler.isFullSuccess)
    }
    
    private func getShadowView() -> some View {
        return RoundedRectangle(cornerRadius: 20)
            .foregroundColor(.clear)
            .frame(width: pageViewHandler.defaultProps.itemWidth, height: pageViewHandler.defaultProps.itemHeight)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: pageViewHandler.defaultProps.itemWidth, height: pageViewHandler.defaultProps.itemHeight)
                    .foregroundColor(Color(UIColor.white))
                    .shadow(color: Color(UIColor.stepinWhite50), radius: 20, x: 0, y: 1)
                )
    }
    
    private func getScaleFactor() -> CGFloat {
        if pageViewHandler.props.direction == .Horizontal {
            let targetOffset = CGFloat(self.index) * (pageViewHandler.props.itemWidth) - pageViewHandler.props.itemOffset
            let centerFactor = abs(targetOffset + pageViewHandler.currentOffset) / UIScreen.main.bounds.width * 0.3
            return CGFloat(1 - min(centerFactor, 0.6))
        }
        else{
            let targetOffset = CGFloat(self.index) * (pageViewHandler.props.itemHeight) - pageViewHandler.props.itemOffset
            let centerFactor = abs(targetOffset + pageViewHandler.currentOffset) / UIScreen.main.bounds.height * 0.3
            return CGFloat(1 - min(centerFactor, 0.6))
        }
        
    }
    
    private func changeScaleFactor(isFullScreen: Bool) {
        DispatchQueue.main.async {
            if isFullScreen {
                pageViewHandler.itemHandlerList[self.index].resize(size: UIScreen.main.bounds.size)
                scaleFactor = getScaleFactor()
                withAnimation(.spring(response: 0.3)) {
                    scaleFactor = 1
                }
            }
            else {
                pageViewHandler.itemHandlerList[self.index].resize(size: CGSize(width: pageViewHandler.defaultProps.itemWidth, height: pageViewHandler.defaultProps.itemHeight))
                scaleFactor = 1
                withAnimation(.spring(response: 0.3)) {
                    scaleFactor = getScaleFactor()
                }
            }
        }
    }
}

extension View {
    func setItemFrame(props: CustomPageViewProps) -> some View {
        self.frame(width: props.itemWidth, height: props.itemHeight, alignment: .center)
    }
    
    func clip(isFullScreen: Bool) -> some View {
        self.clipShape(!isFullScreen ? RoundedRectangle(cornerRadius: 20) : RoundedRectangle(cornerRadius: 0))
    }
    
    func drawItemOutline(props: CustomPageViewProps, isDraw: Bool) -> some View {
        self.overlay (
            isDraw ?
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(UIColor.stepinWhite100), lineWidth: 1)
                    .frame(width: props.itemWidth, height: props.itemHeight, alignment: .center)
            : nil
        )
    }
}
