import Foundation
import UIKit

protocol ChallengeGameProtocol: NSObject {
    func getPreviewImage(buffer: CVPixelBuffer)
    func getGameState(state: GameState)
    func getBodyZoomRect(rect: CGRect)
    func getScore(score: Float)
    func getAverageScore(avgScore: Float)
    func getTotalScore(score: [Score])
    
    /**debuging**/
    func getBboxLayer(layer: CALayer)
    func getNeonHandler(handler: NeonPlayHandler)
    func getCountDownValue(count: Int)
    func getBodyPoseData(pose: CALayer)
}

