import Foundation
import SwiftSVG

final class NeonPlayHandler: NSObject {
    weak var delegate: NeonPlayProtocol?
    var isNeonLoadingComplete: Bool = false
    
    private var svgData: [String] = []
    private var pathArr: [[String]] = []
    
    private var frameWidth: String = ""
    private var frameHeight: String = ""
    private var neonLineColor: UIColor!
    private var neonBlurColor: UIColor!
    
    init(neonPath: String,
         neonLineColor: UIColor,
         neonBlurColor: UIColor) {
        super.init()
        self.neonLineColor = neonLineColor
        self.neonBlurColor = neonBlurColor
        self.setPath(url: neonPath)
    }
    
    deinit {
        self.svgData = []
        self.pathArr = []
        print("deinit neon")
    }
    
    func getRatio() -> [CGFloat] {
        let widthScale = UIScreen.main.bounds.width / CGFloat(NSString(string: self.frameWidth).floatValue)
        let heightScale = UIScreen.main.bounds.height / CGFloat(NSString(string: self.frameHeight).floatValue)
        
        return [widthScale, heightScale]
    }
    
    /**네온 색 변환시 진행**/
    func changeNeonBlurColor(color: UIColor) {
        self.neonBlurColor = color
        if neonBlurColor == .clear {
            self.drawNeon(path: self.pathArr[0],
                          neonLineColor: UIColor.clear.cgColor)
        } else {
            self.drawNeon(path: self.pathArr[0],
                          neonLineColor: self.neonLineColor.cgColor)
        }
    }
    
    func getNeonBlurColor() -> UIColor {
        return self.neonBlurColor
    }
    
    func setIndex(index: Int) {
        if index < pathArr.count {
            self.drawNeon(path: pathArr[index], neonLineColor: self.neonLineColor.cgColor)
        }
    }
    
    func drawFirstFrame() {
        self.drawNeon(path: pathArr[0], neonLineColor: self.neonLineColor.cgColor)
    }
    
    func drawNeon(path: [String],
                  neonLineColor: CGColor) {
        let ratio: [CGFloat] = self.getRatio()
        let drawingLayer = SVGLayer()
        
        path.forEach { [weak self] path in
            guard let strongSelf = self else {return}
            if path != "end" {
                let layer = SVGLayer(pathString: path)
                layer.fillColor = UIColor.clear.cgColor
                layer.lineWidth = 4
                layer.strokeColor = neonLineColor
                layer.lineCap = .round
                layer.lineJoin = .round
                
                layer.transform = CATransform3DMakeScale(ratio[0], ratio[1], 1.0)
                drawingLayer.addSublayer(layer)
            }
        }
        drawingLayer.shadowOffset = .zero
        drawingLayer.shadowColor = self.neonBlurColor.cgColor
        drawingLayer.shadowRadius = 3
        drawingLayer.shadowOpacity = 1
        
        self.delegate?.getCurrentPlayLayer(layer: drawingLayer)
    }

    func setPath(url: String) {
        var parser: XMLParser
        guard let url = URL(string: url) else {return}
        parser = XMLParser(contentsOf: url)!
        parser.delegate = self
        parser.parse()
        self.isNeonLoadingComplete = true
    }
}
extension NeonPlayHandler: XMLParserDelegate {
    func splitToSVGPath(pathArr: [String]) -> [[String]] {
        var resultPath: [[String]] = []
        var framePath: [String] = []
        pathArr.forEach { [weak self] path in
            if path != "end" {
                framePath.append(path)
            } else {
                resultPath.append(framePath)
                framePath = []
            }
        }
        return resultPath
    }
    
    public func parser(_ parser: XMLParser,
                       didStartElement elementName: String,
                       namespaceURI: String?,
                       qualifiedName qName: String?,
                       attributes attributeDict: [String : String] = [:]) {
        if elementName == "svg" {
            self.frameHeight = attributeDict["height"] ?? "1054"
            self.frameWidth = attributeDict["width"] ?? "540"
        }
        if elementName == "path"{
            svgData.append(attributeDict["d"] ?? "none")
        }

    }
    public func parser(_ parser: XMLParser,
                       didEndElement elementName: String,
                       namespaceURI: String?,
                       qualifiedName qName: String?) {
        if elementName == "g" {
            svgData.append("end")
        }
        
    }
    public func parserDidEndDocument(_ parser: XMLParser) {
        pathArr = splitToSVGPath(pathArr: svgData)
        self.drawNeon(path: pathArr[0],
                      neonLineColor: UIColor.white.cgColor)
    }
}
