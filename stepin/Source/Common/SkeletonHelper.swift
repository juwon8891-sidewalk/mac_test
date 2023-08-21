import Foundation
import UIKit
import CoreGraphics
import Vision

final class SkeletonHelper {
    private var poseData: [PoseData]
    private var timestampData: [Int] = []
    
    var isVisible: Bool = true
    
    init(data: HistoryVideoDataModel) {
        self.poseData = data.poseData
        self.poseData = self.interpolateValue()
        self.poseData.forEach {
            self.timestampData.append($0.time)
        }
    }
    
    func interpolateValue() -> [PoseData] {
        var newPoseValue: [PoseData] = []
        for poseDataIndex in stride(from: 0, to: poseData.count - 2, by: 1){
            let toPose = poseData[poseDataIndex]
            let fromPose = poseData[poseDataIndex + 1]
            
            let timePadding = fromPose.time - toPose.time //시간 간격
            let devideCount = Int(timePadding / 33)
            
            for index in 0 ... devideCount {
                var poseValue: [Float32] = []
                
                for poseIndex in 0 ... toPose.data.count - 1 {
                    let poseDifference = fromPose.data[poseIndex] - toPose.data[poseIndex]
                    let newPoseValue = toPose.data[poseIndex] + Float32(poseDifference * (Float(index + 1) / Float(devideCount)))
                    poseValue.append(newPoseValue)
                }
                
                newPoseValue.append(.init(data: poseValue,
                                          time: toPose.time + (index * 33)))
            }
        }
        return newPoseValue
    }
    
    func drawSkeleton(view: UIView, currentTime: Int) -> CALayer? {
        if let index = closestIndex(to: currentTime, in: self.timestampData) {
            let layer = self.drawSkeletonLayer(index: index)
            return layer
        } else {
            return nil
        }
    }
    
    func drawSkeletonLayer(index: Int) -> CALayer{
        let poses = self.poseData[index].data
        var newPoses: [Double] = []
        let resultLayer = CALayer()
        for pose in stride(from: 0, to: poses.count - 1, by: 2) {
            let spot = CALayer()
            
            let x = poses[pose]
            let y = poses[pose + 1]
            
            let scaledImageWidth = (375.adjustedH / (256 / 192))
            let leftPadding = (scaledImageWidth - 236.adjusted) / 2
            
            let point = CGPoint(x: CGFloat(x),
                                y: CGFloat(y))
            
            let normalPoint = VNNormalizedPointForImagePoint(point,
                                                             720,
                                                             1280)
            let imagePoint = VNImagePointForNormalizedPoint(normalPoint,
                                                            720,
                                                            1280)
            let normalXPoint = ((imagePoint.x / 192) * scaledImageWidth) - leftPadding
            let normalYPoint = (imagePoint.y / 256) * 375.adjustedH

            newPoses.append(normalXPoint - 10)
            newPoses.append(normalYPoint - 10)
            
            if pose == 8 {
                spot.backgroundColor = UIColor.stepinPink.withAlphaComponent(0.3).cgColor
                spot.borderWidth = 3
                spot.borderColor = UIColor.white.cgColor
                spot.frame = CGRect(origin: CGPoint(x: Int(normalXPoint),
                                                    y: Int(normalYPoint) - 20),
                                    size: CGSize(width: 30, height: 30))
                spot.cornerRadius = 15
            }
            else if pose > 8 {
                spot.backgroundColor = UIColor.stepinPink.withAlphaComponent(0.3).cgColor
                spot.borderWidth = 3
                spot.borderColor = UIColor.white.cgColor
                spot.frame = CGRect(origin: CGPoint(x: Int(normalXPoint - (10)),
                                                    y: Int(normalYPoint - (10))),
                                    size: CGSize(width: 20, height: 20))
                spot.cornerRadius = 10
            }
            
            spot.masksToBounds = false
            resultLayer.addSublayer(spot)
        }
        
        resultLayer.addSublayer(addLine(x1: newPoses[10], y1: newPoses[11], x2: newPoses[12], y2: newPoses[13]))
        resultLayer.addSublayer(addLine(x1: newPoses[10], y1: newPoses[11], x2: newPoses[14], y2: newPoses[15]))
        resultLayer.addSublayer(addLine(x1: newPoses[10], y1: newPoses[11], x2: newPoses[24], y2: newPoses[25]))
        resultLayer.addSublayer(addLine(x1: newPoses[12], y1: newPoses[13], x2: newPoses[22], y2: newPoses[23]))
        resultLayer.addSublayer(addLine(x1: newPoses[12], y1: newPoses[13], x2: newPoses[16], y2: newPoses[17]))
        resultLayer.addSublayer(addLine(x1: newPoses[14], y1: newPoses[15], x2: newPoses[18], y2: newPoses[19]))
        resultLayer.addSublayer(addLine(x1: newPoses[16], y1: newPoses[17], x2: newPoses[20], y2: newPoses[21]))
        resultLayer.addSublayer(addLine(x1: newPoses[22], y1: newPoses[23], x2: newPoses[24], y2: newPoses[25]))
        resultLayer.addSublayer(addLine(x1: newPoses[22], y1: newPoses[23], x2: newPoses[26], y2: newPoses[27]))
        resultLayer.addSublayer(addLine(x1: newPoses[24], y1: newPoses[25], x2: newPoses[28], y2: newPoses[29]))
        resultLayer.addSublayer(addLine(x1: newPoses[26], y1: newPoses[27], x2: newPoses[30], y2: newPoses[31]))
        resultLayer.addSublayer(addLine(x1: newPoses[28], y1: newPoses[29], x2: newPoses[32], y2: newPoses[33]))
        
        return resultLayer
    }
    
    func closestIndex(to target: Int, in array: [Int]) -> Int? {
        guard !array.isEmpty else {
            return nil
        }

        var closestIndex: Int?
        var minDifference = Int.max

        for (index, value) in array.enumerated() {
            let difference = abs(value - target)

            if difference < minDifference {
                minDifference = difference
                closestIndex = index
            }
        }

        return closestIndex
    }
    
    private func addLine(x1: Double, y1: Double, x2: Double, y2: Double) -> CAShapeLayer {
        let dx = x2 - x1
        let dy = y2 - y1
        let length = sqrt(dx * dx + dy * dy)
        let unitDx = dx / length
        let unitDy = dy / length
        let newLength = length - 10
        
        let newLeft = x1 + unitDx * 10
        let newTop = y1 + unitDy * 10
        let newRight = x1 + unitDx * newLength
        let newBottom = y1 + unitDy * newLength
        
        let linePath = UIBezierPath()
        
        linePath.move(to: .init(x: CGFloat(newLeft + 10), y: CGFloat(newTop + 10)))
        linePath.addLine(to: .init(x: CGFloat(newRight + 10), y: CGFloat(newBottom + 10)))
        
        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.lineWidth = 3.0
        lineLayer.strokeColor = UIColor.stepinWhite100.cgColor
        
        return lineLayer
    }
}

    
