import Foundation
import AVFoundation

protocol GameProtocol: NSObject {
    /**게임뷰에 보여줄 프리뷰 이미지 */
    func getPixelBuffer(pixelBuffer: CVPixelBuffer, timeStamp: CMTime)
    /**포즈값 */
    func getCountDownValue(count: Int)
    func getGameState(state: GameState)
    /**디버깅용 포즈 좌표 정보**/
    func getBodyPose(pose: [CGPoint], poseValue: [Float32], timeStamp: CMTime)
    //bodyzoom rect
    func getBodyZoomRect(rect: CGRect)
    //MusicTime
    func getMusicDuration(time: Float, startTime: Float, endTime: Float)
}
