import Foundation

class CustomPageViewHandler: CustomPageViewHandlerInterface, ObservableObject {
    var pageIndex: Int = 1
    var isInitialized: Bool = false
    var isLoading: Bool = false
    
    var defaultProps: CustomPageViewProps
    
    @Published var props: CustomPageViewProps
    @Published var itemIndex: Int = 0
    @Published var isFullScreen: Bool
    @Published var isFullSuccess: Bool = false
    @Published var itemViewList: [CustomPageItemView] = []
    @Published var itemHandlerList: [CustomPageViewItemHandler] = []
    @Published var currentOffset: CGFloat = 0
    
    
    
    init(direction: Direction, isFullScreen: Bool, itemWidth: CGFloat, itemHeight: CGFloat, itemOffset: CGFloat) {
        self.isFullScreen = isFullScreen
        self.isFullSuccess = isFullScreen
        let props = CustomPageViewProps(direction: direction, itemWidth: itemWidth, itemHeight: itemHeight)
        self.currentOffset = props.itemOffset
        
        self.defaultProps = props
        self.props = props
    }
    
    func onAppeared() {}
    
    func onDisappeared() {}
    
    func loadNextPage() {}
    
    func setFullScreen(isFullScreen: Bool) {
        self.isFullScreen = isFullScreen
    }
    
    func itemTapCallback() { }
    
    func changeItemsState() {
        if isLoading { return }
        if self.itemIndex + 3 > (pageIndex - 1) * 10 {
            self.loadNextPage()
        }
    }
    
    func jumpToPage(page: Int) {
        currentOffset = CGFloat(-page) * props.itemWidth + props.itemOffset
        itemIndex = page
    }
    
    func release() {}
    
    
}

protocol CustomPageViewHandlerInterface {
    // CustomPageViewHandler 초기화 여부
    var isInitialized: Bool { get set }
    
    // 네트워크 콜 시 사용할 페이지의 인덱스
    var pageIndex: Int { get set }
    
    // 뷰 아이템들의 인덱스
    var itemIndex: Int { get set }
    
    // View의 Props
    var props: CustomPageViewProps { get set }
    
    // CustomPageView가 나타났을 때 호출해주어야 함
    func onAppeared()
    
    // CustomPageView가 사라졌을 때 호출해주어야 함
    func onDisappeared()
    
    // 다음 페이지를 호출하는 함수
    func loadNextPage()
    
    func itemTapCallback()
    
    // 전체 화면으로의 전환 시 호출하는 함수
    func setFullScreen(isFullScreen: Bool)
    
    // CustomPageViewItem의 상태를 변경하는 함수
    func changeItemsState()
    
    // 핸들러를 할당 해제할 때 반드시 호출해야하는 함수.
    // 객체 참조 제거 필수
    func release()
}

enum Direction{
    case Horizontal
    case Vertical
}

struct CustomPageViewProps {
    var itemWidth: CGFloat
    var itemHeight: CGFloat
    var frameWidth: CGFloat
    var frameHeight: CGFloat
    var itemOffset: CGFloat
    var windowedScale: CGFloat = 0.6
    var direction: Direction
    
    init(direction: Direction, itemWidth: CGFloat, itemHeight: CGFloat) {
        self.itemWidth = itemWidth
        self.itemHeight = itemHeight
        self.direction = direction
        
        self.frameWidth = itemWidth
        self.frameHeight = itemHeight
        
        if direction == .Horizontal {
            self.itemOffset = (UIScreen.main.bounds.width - itemWidth) * 0.5
        }
        else {
            self.itemOffset = (UIScreen.main.bounds.height - itemHeight) * 0.5
        }
    }
}
