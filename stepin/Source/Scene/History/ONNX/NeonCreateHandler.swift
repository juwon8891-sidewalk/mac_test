import Accelerate
import AVFoundation
import CoreImage
import Darwin
import Foundation
import UIKit
import onnxruntime_objc
import CoreML
import Vision
import Sentry

class NeonCreateHandler: NSObject {
    // MARK: - Inference Properties
    private var asset: AVAsset?
    var infrenceTime: Double = 0
    
    internal var isPredicting: Bool = false
    
    private let colors = [
        UIColor.red,
        UIColor(displayP3Red: 90.0 / 255.0, green: 200.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0),
        UIColor.green,
        UIColor.orange,
        UIColor.blue,
        UIColor.purple,
        UIColor.magenta,
        UIColor.yellow,
        UIColor.cyan,
        UIColor.brown
    ]
    
    private var session: ORTSession?
    private var env: ORTEnv?
    private let opencvWrapper: OpenCVWrapper = OpenCVWrapper()
    private var generator: AVAssetImageGenerator?
    
    private var r1o: ORTValue? = nil
    private var r2o: ORTValue? = nil
    private var r3o: ORTValue? = nil
    private var r4o: ORTValue? = nil
    private var color: CIColor
    
    private var assetWriter: AVAssetWriter?
    private var assetWriterInput: AVAssetWriterInput?
    
    init?(color: CIColor){
        self.color = color
        
        super.init()
        
        self.loadNeonModel()
    }
    
    func setNeonColor(ciColor: CIColor) {
        self.color = ciColor
    }
    
    func getTotalFrame() -> Int {
        return 0
    }
    
    func getCurrentFrame() -> Int {
        return 0
    }
    
    func loadNeonModel() {
        do {
            let modelPath = Bundle.main.path(forResource: "neon_ai", ofType: "ort")
            
            env = try ORTEnv(loggingLevel: ORTLoggingLevel.fatal)
            let options = try ORTSessionOptions()
            try options.setIntraOpNumThreads(2)
            session = try ORTSession(env: env!, modelPath: modelPath!, sessionOptions: options)
        }
        catch let error{
            SentrySDK.capture(error: error)
            print(error)
        }
    }
    
    func loadVideoFrame(image: UIImage) throws -> UIImage {
        self.isPredicting = true
        var resultImage: UIImage?
        
        DispatchQueue.global().sync {
            autoreleasepool{
                do {
                    resultImage = try self.runModel(onFrame: image)
                } catch {
                    resultImage = UIImage()
                }
            }
        }
        return resultImage!
    }
    
    // This method preprocesses the image, runs the ort inferencesession and returns the inference result
    func runModel(onFrame image: UIImage) throws -> UIImage{
        let startDate = Date()
        
        let imageValue = opencvWrapper.uiImage(toData: image, red: color.red, green: color.green, blue: color.blue)
        var srcValue: ORTValue? = try ORTValue(tensorData: imageValue, elementType: ORTTensorElementDataType.float, shape: [1, 1280, 720, 3])
        
        var r1i: ORTValue?
        var r2i: ORTValue?
        var r3i: ORTValue?
        var r4i: ORTValue?
        
        if(r1o != nil){
            r1i = r1o
            r2i = r2o
            r3i = r3o
            r4i = r4o
        }
        else{
            r1i = try! ORTValue(tensorData: getDefaultRi(dataLength: 1 * 16 * 240 * 135), elementType: ORTTensorElementDataType.float, shape: [1, 16, 240, 135])
            r2i = try! ORTValue(tensorData: getDefaultRi(dataLength: 1 * 20 * 120 * 68), elementType: ORTTensorElementDataType.float, shape: [1, 20, 120, 68])
            r3i = try! ORTValue(tensorData: getDefaultRi(dataLength: 1 * 40 * 60 * 34), elementType: ORTTensorElementDataType.float, shape: [1, 40, 60, 34])
            r4i = try! ORTValue(tensorData: getDefaultRi(dataLength: 1 * 64 * 30 * 17), elementType: ORTTensorElementDataType.float, shape: [1, 64, 30, 17])
        }
        
        let downsample = try! ORTValue(tensorData: getDownsampleRatio(), elementType: ORTTensorElementDataType.float, shape: [1])
        
        do {
            let outputs = try session!.run(withInputs: ["src": srcValue!, "r1i": r1i!, "r2i": r2i!, "r3i": r3i!, "r4i": r4i!, "downsample_ratio": downsample],
                                                  outputNames: ["fgr_human", "pha_human", "fgr_cloth", "pha_cloth", "fgr_hair", "pha_hair", "r1o", "r2o", "r3o", "r4o"],
                                                  runOptions: nil)
            
            srcValue = nil
            
            r1o = outputs["r1o"]
            r2o = outputs["r2o"]
            r3o = outputs["r3o"]
            r4o = outputs["r4o"]
            
            let humanData = try outputs["pha_human"]!.tensorData()
            let clothData = try outputs["pha_cloth"]!.tensorData()
            let hairData = try outputs["pha_hair"]!.tensorData()
            
            let result = opencvWrapper.createNeonImage(0, humanData: humanData, clothData: clothData, hairData: hairData)
        
            
            let interval = Date().timeIntervalSince(startDate) * 1000
            self.infrenceTime = interval
            print(interval)
            return result
            
        } catch {
            SentrySDK.capture(error: error)
            print(error)
            return UIImage()
        }
        
        
    }
    
    func getDefaultRi(dataLength: Int) -> NSMutableData {
        let data = NSMutableData(length: dataLength * MemoryLayout<Float>.stride)!
        let dataPointer = data.mutableBytes.assumingMemoryBound(to: Float.self)
        memset(dataPointer, 0, dataLength * MemoryLayout<Float>.stride)
        
        return data
    }
    
    func getDownsampleRatio() -> NSMutableData {
        let array: [Float] = [0.375]
        let data = Data(bytes: array, count: MemoryLayout<Float>.size * array.count)
        let mutableData = NSMutableData(data: data)
        return mutableData
    }}
