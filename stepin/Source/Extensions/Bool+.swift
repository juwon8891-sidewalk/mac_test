import Foundation

extension Bool {
    func changeIntState() -> Int {
        if self {
            return 1
        } else {
            return 0
        }
    }
}
