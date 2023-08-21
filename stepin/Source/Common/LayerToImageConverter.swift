import UIKit

class LayerToImageConverter {
    var view: UIView?
    init(view: UIView) {
        self.view = view
    }
    
    func getPresetPath(stepinId: String,
                       score: String = "") -> URL? {
        if let view = view {
            view.backgroundColor = .clear
            let scale = max(720 / UIScreen.main.bounds.width, 1280 / UIScreen.main.bounds.height)
            
            //텍스트 추가
            let textLayer = CATextLayer()
            textLayer.frame = .init(origin: .init(x: 0,
                                                  y: 25 * scale), size: .init(width: 720,
                                                                      height: 100))
            textLayer.string = stepinId
            textLayer.foregroundColor = UIColor.stepinWhite100.cgColor
            textLayer.fontSize = 20 * scale
            textLayer.alignmentMode = .center
            textLayer.font = CTFontCreateWithName("SUIT-ExtraBold" as CFString, 20 * scale, nil)
            
            view.layer.addSublayer(textLayer)
            
            //바텀 이미지 추가
            let image = ImageLiterals.icSaveVideoLogo
            let imageLayer = CALayer()
            let xPosition = 720 / 2.0 - (50 * scale)
            let yPosition = 1280 - (45 * scale)
            imageLayer.frame = .init(origin: .init(x: xPosition,
                                                   y: yPosition),
                                     size: .init(width: 100 * scale, height: 25 * scale))
            imageLayer.contents = image.cgImage
            view.layer.addSublayer(imageLayer)
            
            //점수 표시 추가
            if score != "" {
                let scoreView = ScoreView(frame: .init(origin: .zero,
                                                       size: .init(width: 72 * scale,
                                                                   height: 72 * scale)))
                scoreView.isOpaque = false
                var doubleScore: Double = Double(score)! * 0.01
                scoreView.setPercent(value: Double(score)!, scale: scale)
                scoreView.setprogressValue(value: doubleScore)
                
                print(score, doubleScore)
                
                if let scoreViewImage = scoreView.captureAsImage() {
                    let imageLayer = CALayer()
                    imageLayer.frame = .init(origin: .init(x: 12 * scale,
                                                                   y: 85 * scale),
                                                     size: .init(width: 72 * scale,
                                                                 height: 72 * scale))
                    imageLayer.contents = scoreViewImage.cgImage
                    view.layer.addSublayer(imageLayer)
                }
            }
            
            
            
            //해당 레이어를 이미지로 변환해서 저장
            let layerToConvert = view.layer
            UIGraphicsBeginImageContextWithOptions(layerToConvert.bounds.size, layerToConvert.isOpaque, 0.0)
            layerToConvert.render(in: UIGraphicsGetCurrentContext()!)
            let convertedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            // 변환된 이미지를 사용합니다.
            var url: URL?
            if let image = convertedImage {
                url = UIImage.saveToDisk(image: image, withName: "watermark.png")
            }
            return url
        } else {
            return URL(string: "")!
        }
    }
    
}
