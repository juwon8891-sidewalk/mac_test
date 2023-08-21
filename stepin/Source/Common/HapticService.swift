import UIKit
import Foundation

class HapticService {
    private var feedbackGenerator: UINotificationFeedbackGenerator?
    static let shared = HapticService()
    private init() {}
    
    public func playFeedback() {
        self.feedbackGenerator = UINotificationFeedbackGenerator()
        self.feedbackGenerator?.prepare()
        self.feedbackGenerator?.notificationOccurred(.success)
    }
}
