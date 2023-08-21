import UIKit
import AVFoundation
import CoreGraphics
import VideoToolbox
import Sentry

extension UIImage {
    static func load(name: String) -> UIImage {
        guard let image = UIImage(named: name, in: nil, compatibleWith: nil) else {
            return UIImage()
        }
        image.accessibilityIdentifier = name
        return image
    }
    
    var roundedImage: UIImage {
        let rect = CGRect(origin:CGPoint(x: 0, y: 0), size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: self.size.height
        ).addClip()
        self.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    func resizeToCenter(_ size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            let widthRatio = size.width / self.size.width
            let heightRatio = size.height / self.size.height
            let scale = min(widthRatio, heightRatio)
            let newWidth = self.size.width * scale
            let newHeight = self.size.height * scale
            let x = (size.width - newWidth) / 2
            let y = (size.height - newHeight) / 2
            let rect = CGRect(x: x, y: y, width: newWidth, height: newHeight)
            self.draw(in: rect)
        }
    }
    
    public func resizedImage(width: CGFloat, height: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: height)
        let widthRatio = width / self.size.width
        let heightRatio = height / self.size.height
        
        let newSize = widthRatio > heightRatio ?
        CGSize(width: self.size.width * widthRatio, height: self.size.height * widthRatio):
        CGSize(width: self.size.width * heightRatio, height: self.size.height * heightRatio)
        
        UIGraphicsBeginImageContextWithOptions(canvasSize,
                                               false,
                                               1.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
    func addBlurredImage(radius: CGFloat) -> UIImage {
        let context = CIContext()
        guard let ciImage = CIImage(image: self),
              let clampFilter = CIFilter(name: "CIAffineClamp"),
              let blurFilter = CIFilter(name: "CIGaussianBlur") else {
            return self
        }
        
        clampFilter.setValue(ciImage, forKey: kCIInputImageKey)
        
        blurFilter.setValue(clampFilter.outputImage, forKey: kCIInputImageKey)
        blurFilter.setValue(radius, forKey: kCIInputRadiusKey)
        guard let output = blurFilter.outputImage,
              let cgimg = context.createCGImage(output, from: ciImage.extent) else {
            return self
        }
        return UIImage(cgImage: cgimg)
    }
    
    func cropped(to rect: CGRect, imageSize: CGSize) -> UIImage {
        // a UIImage is either initialized using a CGImage, a CIImage, or nothing
        if let cgImage = self.cgImage {
            // CGImage.cropping(to:) is magnitudes faster than UIImage.draw(at:)
            let widthRatio = imageSize.width / rect.width
            let heightRatio = imageSize.height / rect.height
            
            let newRect = widthRatio > heightRatio ?
            CGRect(x: rect.minX - (rect.width * heightRatio - rect.width) / 2,
                   y: rect.minY - (rect.height * heightRatio - rect.height) / 2,
                   width: rect.width * heightRatio,
                   height: rect.height * heightRatio):
            CGRect(x: rect.minX - (rect.width * widthRatio - rect.width) / 2,
                   y: rect.minY - (rect.height * widthRatio - rect.height) / 2,
                   width: rect.width * widthRatio,
                   height: rect.height * widthRatio)
            
            if let cgCroppedImage = cgImage.cropping(to: newRect) {
                return UIImage(cgImage: cgCroppedImage)
            }
        } else {
            return self
        }
        if let ciImage = self.ciImage {
            // Core Image's coordinate system mismatch with UIKit, so rect needs to be mirrored.
            var ciRect = rect
            ciRect.origin.y = ciImage.extent.height - ciRect.origin.y - ciRect.height
            let ciCroppedImage = ciImage.cropped(to: ciRect)
            return UIImage(ciImage: ciCroppedImage)
        } else {
            return self
        }
    }
    
    func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage?
    {
        let imageViewScale = max(inputImage.size.width / viewWidth,
                                 inputImage.size.height / viewHeight)
        
        // Scale cropRect to handle images larger than shown-on-screen size
        let cropZone = CGRect(x:cropRect.origin.x * imageViewScale,
                              y:cropRect.origin.y * imageViewScale,
                              width:cropRect.size.width * imageViewScale,
                              height:cropRect.size.height * imageViewScale)
        
        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropZone)
        else {
            return nil
        }
        
        // Return image to UIImage
        let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
        return croppedImage
    }
    /**
     Make Uiimage use CVPixelBuffer
     */
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        
        guard let cgImage = cgImage else {
            return nil
        }
        
        self.init(cgImage: cgImage)
    }
    
    /**
     Resize Image and flipHorizontally
     */
    public func resizedFlipImage(width: CGFloat, height: CGFloat) -> UIImage? {
        //Calculate image Scale
        let imageSize = CGSize(width: width, height: CGFloat(ceil(width / self.size.width * self.size.height)))
        //        let canvasSize = CGSize(width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(imageSize,
                                               false,
                                               1)
        let context = UIGraphicsGetCurrentContext()!
        //Flip the image
        context.translateBy(x: width / 2, y: height / 2)
        context.scaleBy(x: -1.0, y: 1.0)
        context.translateBy(x: -width / 2, y: -height / 2)
        
        self.draw(in: CGRect(origin: .zero, size: imageSize))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    public func flipHorizontalyImage(width: CGFloat, height: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size,
                                               false,
                                               0.8)
        let context = UIGraphicsGetCurrentContext()!
        //Flip the image
        context.translateBy(x: width / 2, y: height / 2)
        context.scaleBy(x: -1.0, y: 1.0)
        context.translateBy(x: -width / 2, y: -height / 2)
        
        self.draw(in: CGRect(origin: .zero, size: self.size))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    public func getImageRatioRect(rect: CGRect) -> CGRect{
        let paddedRect = CGRect(origin: CGPoint(x: rect.minX - 25,
                                               y: rect.minY - 45),
                               size: CGSize(width: (rect.maxX - rect.minX) + 50,
                                            height: (rect.maxY - rect.minY) + 90))
        
        let centerX = (paddedRect.minX + paddedRect.maxX) / 2.0
        let centerY = (paddedRect.minY + paddedRect.maxY) / 2.0
        let width = (paddedRect.maxX - paddedRect.minX)
        let height = (paddedRect.maxY - paddedRect.minY)
        
        var resultMinX: CGFloat = 0
        var resultMinY: CGFloat = 0
        var resultMaxX: CGFloat = 0
        var resultMaxY: CGFloat = 0
        
        //width가 더 크니까 height을 width에 맞춰야 함
        if width / height > self.size.width / self.size.height {
            var targetHeight = self.size.height / self.size.width * width
            var halfWidth = width / 2.0
            var halfHeight = targetHeight / 2.0
            
            resultMinX = centerX - halfWidth
            resultMinY = centerY - halfHeight
            resultMaxX = centerX + halfWidth
            resultMaxY = centerY + halfHeight
            
            
            if resultMaxY > self.size.height {
                let factor = resultMaxY - self.size.height
                resultMaxY -= factor
                resultMinY -= factor
            }
            
            if (resultMaxY - resultMinY) > self.size.height {
                resultMinX = 0
                resultMinY = 0
                resultMaxX = self.size.width
                resultMaxY = self.size.height
            }
            
        } else {
            var targetWidth = self.size.width / self.size.height * height
            var halfWidth = targetWidth / 2.0
            var halfHeight = height / 2.0
            
            resultMinX = centerX - halfWidth
            resultMinY = centerY - halfHeight
            resultMaxX = centerX + halfWidth
            resultMaxY = centerY + halfHeight
            
            
            if resultMaxX > self.size.width {
                let factor = resultMaxX - self.size.width
                resultMaxX -= factor
                resultMinX -= factor
            }
            
            if (resultMaxX - resultMinX) > self.size.width {
                resultMinX = 0
                resultMinY = 0
                resultMaxX = self.size.width
                resultMaxY = self.size.height
            }
        }
        
        return CGRect(x: resultMinX,
                      y: resultMinY,
                      width: resultMaxX - resultMinX,
                      height: resultMaxY - resultMinY)
    }
    
    
    /**
     Conver UIimage to CVPixeltBuffer
     */
    public func buffer() -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData,
                                width: Int(self.size.width),
                                height: Int(self.size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    func resizeImage(image: UIImage) -> UIImage? {
        let newSize = CGSize(width: 640, height: 640)
        let canvas = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        UIColor.white.setFill()
        UIRectFill(canvas)
        let size = image.size
        let widthRatio  = newSize.width / size.width
        let heightRatio = newSize.height / size.height
        let scale = min(widthRatio, heightRatio)
        let newWidth = size.width * scale
        let newHeight = size.height * scale
        let x = (newSize.width - newWidth) / 2.0
        let y = (newSize.height - newHeight) / 2.0
        let rect = CGRect(x: x, y: y, width: newWidth, height: newHeight)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    static func saveToDisk(image: UIImage, withName name: String) -> URL? {
        guard let data = image.pngData() else {
            return nil
        }
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(name)
        
        do {
            // 기존 파일이 존재하는 경우 삭제
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
            
            try data.write(to: fileURL)
            return fileURL
        } catch {
            SentrySDK.capture(error: error)
            print("이미지를 저장하는 데 실패했습니다:", error)
            return nil
        }
    }
    
    
}
