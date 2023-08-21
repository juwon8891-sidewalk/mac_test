import Foundation
import AVFoundation

protocol MusicPlayerProtocol: NSObject {
    /**현재 플레이되고 있는 음악 시간 반환**/
    func getCurrentMusicTime(_ time: CGFloat)
}
