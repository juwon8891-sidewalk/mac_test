import Foundation

enum TabBarPage: String, CaseIterable {
    case home, boogie, play, history, myPage
    
    init?(index: Int) {
        switch index {
        case 0: self = .home
        case 1: self = .boogie
        case 2: self = .play
        case 3: self = .history
        case 4: self = .myPage
        default: return nil
        }
    }
    
    func pageOrderNumber() -> Int {
        switch self {
        case .home: return 0
        case .boogie: return 1
        case .play: return 2
        case .history: return 3
        case .myPage: return 4
        }
    }
    
    func tabIconName() -> String {
        return self.rawValue
    }
}
