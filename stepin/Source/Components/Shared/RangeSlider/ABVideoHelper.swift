//
//  ABVideoHelper.swift
//  selfband
//
//  Created by Oscar J. Irun on 27/11/16.
//  Copyright © 2016 appsboulevard. All rights reserved.
//

import UIKit
import AVFoundation
import Sentry

class ABVideoHelper: NSObject {

    static func thumbnailFromVideo(videoUrl: URL, time: CMTime) -> UIImage{
        let asset: AVAsset = AVAsset(url: videoUrl) as AVAsset
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        do{
            let cgImage = try imgGenerator.copyCGImage(at: time, actualTime: nil)
            let uiImage = UIImage(cgImage: cgImage)
            return uiImage
        }catch{
            SentrySDK.capture(error: error)
        }
        return UIImage()
    }
    
    static func videoDuration(videoURL: URL)-> Float64 {
        let asset = AVAsset(url: videoURL)
        return CMTimeGetSeconds(asset.duration)
    }
    
    
    
}
