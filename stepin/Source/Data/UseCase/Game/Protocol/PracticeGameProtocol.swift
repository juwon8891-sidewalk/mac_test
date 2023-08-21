import Foundation

protocol PracticeGameProtocol: NSObject {
    func getPreviewImage(buffer: CVPixelBuffer)
    func getMusicTime(time: Float,
                      startTime: Float,
                      endTime: Float)
    func getGameState(state: GameState)
    func getBodyZoomRect(rect: CGRect)
    
    /**debuging**/
    func getNeonHandler(handler: NeonPlayHandler)
    func getCountDownValue(count: Int)
}
