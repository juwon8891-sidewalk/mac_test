import AVFoundation
import UIKit
import Foundation
import ffmpegkit
import Photos

class FfmpegHandler {

    static func combineVideoAudio(videoUrl: String,
                                  audioUrl: String,
                                  startPosition: Float,
                                  endPosition: Float) -> String {
        let docFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let videoName: String = "/STEPIN-\(Int(Date().timeIntervalSince1970)).mp4"
        let outPutPath = docFolder.appending(videoName)
        print(outPutPath)
        
        print(FFmpegHelper.floatToTimeString(startPosition))
        print(FFmpegHelper.floatToTimeString(endPosition))
        
        let command: String = "-ss 00:00:00 -i \(videoUrl) -ss \(FFmpegHelper.floatToTimeString(startPosition)) -t \(FFmpegHelper.floatToTimeString(endPosition - startPosition)) -i \(audioUrl) -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 -shortest \(outPutPath)"
        
        let ssesion = FFmpegKit.execute(command)

        
        return videoName
    }
    
    
    static func floatToTimeString(_ value: Float) -> String {
        let hours = Int(value) / 3600
        let minutes = Int(value) / 60 % 60
        let seconds = Int(value) % 60
        let milliseconds = Int((value.truncatingRemainder(dividingBy: 1)) * 1000)
        return String(format: "%02d:%02d:%02d.%03d", hours, minutes, seconds, milliseconds)
    }
    
//    static func saveUserVideo(videoUrl: String,
//                              score: String,
//                              stepinId: String) {
//        let docFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
//        let videoName: String = "/STEPIN-\(Int(Date().timeIntervalSince1970)).mp4"
//        let outPutPath = docFolder.appending(videoName)
//        DispatchQueue.main.async {
//            let converter = LayerToImageConverter(view: UIView(frame: .init(origin: .zero,
//                                                                            size: .init(width: 720,
//                                                                                        height: 1280))))
//            let imagePath = converter.getPresetPath(stepinId: stepinId, score: score)
//            let imageStringPath = docFolder.appending("/watermark.png")
//            let command: String = "-i \(videoUrl) -i \(imageStringPath) -filter_complex \"[1][0]scale2ref=oh*mdar:ih[logo][video];[video][logo]overlay=(main_w-overlay_w):(main_h-overlay_h)\" \(outPutPath)"
//            
//            let ssesion = FFmpegKit.execute(command)
//            if let outputPath = URL(string: outPutPath) {
//                print(outputPath)
//                FFmpegHelper.saveVideoToLibrary(videoURL: outputPath)
//            }
//        }
//    }
    
    static func saveVideoToLibrary(videoURL: URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
        }) { (success, error) in
            if let error = error {
                print("동영상을 저장할 수 없습니다: \(error.localizedDescription)")
            } else {
                print("동영상이 사진첩에 저장되었습니다.")
            }
        }
    }
    
    
}
