//
//  VideoRangeSlider.swift
//  VideoRangeSlider
//
//  Created by Dave on 4/26/21. 
//  Copyright © 2016 appsboulevard. All rights reserved.

import UIKit
import SDSKit

public enum VideoSliderType {
    case normal
    case neon
    case music
}

@objc public protocol VideoRangeSliderDelegate: class {
    func didChangeValue(videoRangeSlider: VideoRangeSlider, startTime: Float64, endTime: Float64)
    func indicatorDidChangePosition(videoRangeSlider: VideoRangeSlider, position: Float64)
    
    @objc optional func sliderGesturesBegan()
    @objc optional func sliderGesturesEnded()
    @objc optional func tapGesture(position: Float64)
    @objc optional func resetPosition()
}

public class VideoRangeSlider: UIView, UIGestureRecognizerDelegate {
    
    private enum DragHandleChoice {
        case start
        case end
    }
    
    public weak var delegate: VideoRangeSliderDelegate? = nil
    
    private var videoType: VideoSliderType = .normal
    private let gradienImageView = UIImageView(image: ImageLiterals.neonSliderBackground)
    
    var startIndicator      = UIView()
    var endIndicator        = UIView()
    var progressIndicator   = ABProgressIndicator()
    var progressBackgroundView = UIView()
    var draggableView       = UIView()
    
    let thumbnailsManager   = ABThumbnailsManager()
    var duration: Float64   = 0.0
    var videoURL            = URL(fileURLWithPath: "")
    
    var progressPercentage: CGFloat = 0         // Represented in percentage
    var startPercentage: CGFloat    = 0         // Represented in percentage
    var endPercentage: CGFloat      = 100       // Represented in percentage
    
    let topBorderHeight: CGFloat      = 5
    let bottomBorderHeight: CGFloat   = 5
    
    let indicatorWidth: CGFloat = 20.0
    
    public var minSpace: Float = 1              // In Seconds
    public var maxSpace: Float = 0              // In Seconds
    
    public var isProgressIndicatorSticky: Bool = false
    public var isProgressIndicatorDraggable: Bool = true
    
    var isUpdatingThumbnails = false
    var isReceivingGesture: Bool = false
    
    public enum ABTimeViewPosition{
        case top
        case bottom
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setup(){
        self.isUserInteractionEnabled = true
        
        // Setup Start Indicator
        
        startIndicator = UIView(frame: CGRect(x: 0,
                                              y: -topBorderHeight,
                                              width: 20,
                                              height: self.frame.size.height + bottomBorderHeight + topBorderHeight))
        startIndicator.layer.anchorPoint = CGPoint(x: 1, y: 0.5)
        
        // Setup End Indicator
        
        
        endIndicator = UIView(frame: CGRect(x: 0,
                                            y: -topBorderHeight,
                                            width: indicatorWidth,
                                            height: self.frame.size.height + bottomBorderHeight + topBorderHeight))
        endIndicator.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        
        // Setup Progress Indicator
        
        let progressDrag = UIPanGestureRecognizer(target:self,
                                                  action: #selector(progressDragged(recognizer:)))
        
        let viewDrag = UIPanGestureRecognizer(target:self,
                                                  action: #selector(viewDragged(recognizer:)))
        
        let viewTap = UITapGestureRecognizer(target: self,
                                             action: #selector(viewTapped(recognizer:)))
        
        progressIndicator = ABProgressIndicator(frame: CGRect(x: 0,
                                                              y: 0,
                                                              width: 24,
                                                              height: ScreenUtils.setWidth(value: 32)))
        progressIndicator.backgroundColor = .clear
        progressIndicator.layer.cornerRadius = ScreenUtils.setWidth(value: 4)
        
        
        
        //setup background
        progressBackgroundView.backgroundColor = .clear
        
        self.addSubview(progressBackgroundView)
        self.addSubview(progressIndicator)
        
        // Setup Draggable View
        // 이거 왜 필요하지?
        // david : 이게 필요합니다
        self.addGestureRecognizer(viewDrag)
        self.addGestureRecognizer(viewTap)
        
        //        let viewDrag = UIPanGestureRecognizer(target:self,
        //                                              action: #selector(viewDragged(recognizer:)))
        //
        //        draggableView.addGestureRecognizer(viewDrag)
        //        self.draggableView.backgroundColor = .clear
        //        self.addSubview(draggableView)
        //        self.sendSubviewToBack(draggableView)
        
        //layout fix
        let leftPaddingView = UIView()
        leftPaddingView.backgroundColor = .PrimaryWhiteNormal
        let rightPaddingView = UIView()
        rightPaddingView.backgroundColor = .PrimaryWhiteNormal
        
        self.addSubviews([leftPaddingView, rightPaddingView])
        leftPaddingView.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
            $0.width.equalTo(8)
        }
        rightPaddingView.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview()
            $0.width.equalTo(8)
        }
        
    }
    
    // MARK: Public functions
    public func setAlphaBackgroundView() {
        self.videoType = .music
        self.backgroundColor = .stepinBlack70
        progressBackgroundView.backgroundColor = .stepinWhite100
        self.progressIndicator.drawShadow(color: .stepinBlack100,
                                          opacity: 0.5,
                                          offset: progressIndicator.frame.size,
                                          radius: 1)
    }
    
    public func setBackgroundGradient() {
        self.videoType = .neon
        self.progressBackgroundView.backgroundColor = .clear
        self.insertSubview(gradienImageView, belowSubview: self.progressBackgroundView)
        gradienImageView.frame = CGRect(origin: .zero,
                                        size: .init(width: self.frame.width,
                                                    height: self.frame.height))

    }
    
    public func setDefaultBackgroundView() {
        self.gradienImageView.removeFromSuperview()
        self.progressBackgroundView.backgroundColor = .PrimaryWhiteNormal
        self.backgroundColor = .stepinBlack70
        self.videoType = .normal
    }
    
    public func setProgressIndicatorImage(image: UIImage){
        //        self.progressIndicator.imageView.image = image
    }
    
    public func hideProgressIndicator(){
        self.progressIndicator.isHidden = true
    }
    
    public func showProgressIndicator(){
        self.progressIndicator.isHidden = false
    }
    
    public func updateProgressIndicator(seconds: Float64){
        if !isReceivingGesture {
            let endSeconds = secondsFromValue(value: self.endPercentage)
            
            if seconds >= endSeconds {
                self.resetProgressPosition()
            } else {
                self.progressPercentage = self.valueFromSeconds(seconds: Float(seconds))
                if self.videoType == .normal {
                    self.setDrageBackground(width: self.progressPercentage * 0.01 * self.frame.width)
                }
                else if self.videoType == .music {
                    self.setDrageBackground(width: self.progressPercentage * 0.01 * self.frame.width)
                }
            }
            
            layoutSubviews()
        }
    }
    
    public func setVideoURL(videoURL: URL) {
        self.duration = ABVideoHelper.videoDuration(videoURL: videoURL)
        self.videoURL = videoURL
        self.superview?.layoutSubviews()
        self.updateThumbnails()
    }
//    
//    public func setMusicURL(duration: Float64) {
//        self.duration = duration
//        self.superview?.layoutSubviews()
//        self.updateThumbnails()
//    }
    
    public func setDuration(duration: Float64) {
        self.duration = duration
    }
    
    public func updateThumbnails(){
        if !isUpdatingThumbnails{
            self.isUpdatingThumbnails = true
            let backgroundQueue = DispatchQueue(label: "com.app.queue", qos: .background, target: nil)
            backgroundQueue.async {
                _ = self.thumbnailsManager.updateThumbnails(view: self, videoURL: self.videoURL, duration: self.duration)
                self.isUpdatingThumbnails = false
            }
        }
    }
    
    public func setStartPosition(seconds: Float){
        self.startPercentage = self.valueFromSeconds(seconds: seconds)
        layoutSubviews()
    }
    
    public func setEndPosition(seconds: Float){
        self.endPercentage = self.valueFromSeconds(seconds: seconds)
        layoutSubviews()
    }
    
    private func processHandleDrag(
        recognizer: UIPanGestureRecognizer,
        drag: DragHandleChoice,
        currentPositionPercentage: CGFloat,
        currentIndicator: UIView
    ) {
        
        self.updateGestureStatus(recognizer: recognizer)
        
        let translation = recognizer.translation(in: self)
        
        var position: CGFloat = positionFromValue(value: currentPositionPercentage) // self.startPercentage or self.endPercentage
        
        position = position + translation.x
        
        if position < 0 { position = 0 }
        
        if position > self.frame.size.width {
            position = self.frame.size.width
        }
        
        let positionLimits = getPositionLimits(with: drag)
        position = checkEdgeCasesForPosition(with: position, and: positionLimits.min, and: drag)
        
        if Float(self.duration) > self.maxSpace && self.maxSpace > 0 {
            if drag == .start {
                if position < positionLimits.max {
                    position = positionLimits.max
                }
            } else {
                if position > positionLimits.max {
                    position = positionLimits.max
                }
            }
        }
        
        recognizer.setTranslation(CGPoint.zero, in: self)
        
        currentIndicator.center = CGPoint(x: position , y: currentIndicator.center.y)
        
        let percentage = currentIndicator.center.x * 100 / self.frame.width
        
        let startSeconds = secondsFromValue(value: self.startPercentage)
        let endSeconds = secondsFromValue(value: self.endPercentage)
        
        self.delegate?.didChangeValue(videoRangeSlider: self, startTime: startSeconds, endTime: endSeconds)
        
        var progressPosition: CGFloat = 0.0
        
        if drag == .start {
            self.startPercentage = percentage
        } else {
            self.endPercentage = percentage
        }
        
        if drag == .start {
            progressPosition = positionFromValue(value: self.startPercentage)
            if self.videoType == .normal {
                self.setDrageBackground(width: self.progressPercentage * 0.01 * self.frame.width)
            }
            else if self.videoType == .music {
                self.setDrageBackground(width: self.progressPercentage * 0.01 * self.frame.width)
            }
        } else {
            if recognizer.state != .ended {
                progressPosition = positionFromValue(value: self.endPercentage)
            } else {
                progressPosition = positionFromValue(value: self.startPercentage)
            }
        }
        
        progressIndicator.center = CGPoint(x: progressPosition , y: progressIndicator.center.y)
        let progressPercentage = progressIndicator.center.x * 100 / self.frame.width
        
        if self.progressPercentage != progressPercentage {
            let progressSeconds = secondsFromValue(value: progressPercentage)
        }
        
        self.progressPercentage = progressPercentage
        
        
        layoutSubviews()
    }
    
    @objc func progressDragged(recognizer: UIPanGestureRecognizer){
        if !isProgressIndicatorDraggable {
            return
        }
        
        updateGestureStatus(recognizer: recognizer)
        
        let translation = recognizer.translation(in: self)
        
        let positionLimitStart  = positionFromValue(value: self.startPercentage)
        let positionLimitEnd    = positionFromValue(value: self.endPercentage)
        
        var position = positionFromValue(value: self.progressPercentage)
        position = position + translation.x
        
        if position < positionLimitStart {
            position = positionLimitStart
        }
        
        if position > positionLimitEnd {
            position = positionLimitEnd
        }
        
        recognizer.setTranslation(CGPoint.zero, in: self)
        
        progressIndicator.center = CGPoint(x: position , y: progressIndicator.center.y)
        
        let percentage = progressIndicator.center.x * 100 / self.frame.width
        
        let progressSeconds = secondsFromValue(value: progressPercentage)
        
        self.delegate?.indicatorDidChangePosition(videoRangeSlider: self, position: progressSeconds)
        
        self.progressPercentage = percentage
        if self.videoType == .normal {
            self.setDrageBackground(width: self.progressPercentage * 0.01 * self.frame.width)
        }
        else if self.videoType == .music {
            self.setDrageBackground(width: self.progressPercentage * 0.01 * self.frame.width)
        }
        layoutSubviews()
    }
    
    @objc func viewDragged(recognizer: UIPanGestureRecognizer){
        updateGestureStatus(recognizer: recognizer)
        
        
        let position = recognizer.location(in: self).x
        let startPosition = 0.0
        let endPosition = self.frame.width
        
        
        progressIndicator.center = CGPoint(x: position , y: progressIndicator.center.y)
        startIndicator.center = CGPoint(x: startPosition , y: startIndicator.center.y)
        endIndicator.center = CGPoint(x: endPosition, y: endIndicator.center.y)
        
        
        let startPercentage = startIndicator.center.x * 100 / self.frame.width
        let endPercentage = endIndicator.center.x * 100 / self.frame.width
        let progressPercentage = progressIndicator.center.x * 100 / self.frame.width
        
        let startSeconds = secondsFromValue(value: startPercentage)
        let endSeconds = secondsFromValue(value: endPercentage)
        
        self.delegate?.didChangeValue(videoRangeSlider: self, startTime: startSeconds, endTime: endSeconds)
        
//        if self.progressPercentage != progressPercentage{
        let progressSeconds = secondsFromValue(value: progressPercentage)
        self.delegate?.indicatorDidChangePosition(videoRangeSlider: self, position: progressSeconds)
//        }
        
        self.startPercentage = startPercentage
        self.endPercentage = endPercentage
        self.progressPercentage = progressPercentage
        
        if self.videoType == .normal {
            self.setDrageBackground(width: self.progressPercentage * 0.01 * self.frame.width)
        }
        
        layoutSubviews()
    }
    
    @objc private func viewTapped (recognizer: UITapGestureRecognizer) {
        let position = recognizer.location(in: self).x
        let startPosition = 0.0
        let endPosition = self.frame.width
        
        
        progressIndicator.center = CGPoint(x: position , y: progressIndicator.center.y)
        startIndicator.center = CGPoint(x: startPosition , y: startIndicator.center.y)
        endIndicator.center = CGPoint(x: endPosition, y: endIndicator.center.y)
        
        
        let startPercentage = startIndicator.center.x * 100 / self.frame.width
        let endPercentage = endIndicator.center.x * 100 / self.frame.width
        let progressPercentage = progressIndicator.center.x * 100 / self.frame.width
        
        let startSeconds = secondsFromValue(value: startPercentage)
        let endSeconds = secondsFromValue(value: endPercentage)
        
        self.delegate?.didChangeValue(videoRangeSlider: self, startTime: startSeconds, endTime: endSeconds)
        
//        if self.progressPercentage != progressPercentage{
        let progressSeconds = secondsFromValue(value: progressPercentage)
        self.delegate?.indicatorDidChangePosition(videoRangeSlider: self, position: progressSeconds)
//        }
        
        self.startPercentage = startPercentage
        self.endPercentage = endPercentage
        self.progressPercentage = progressPercentage
        
        if self.videoType == .normal {
            self.setDrageBackground(width: self.progressPercentage * 0.01 * self.frame.width)
        }
            
        
        layoutSubviews()
        
        self.delegate?.tapGesture?(position: progressSeconds)
    }
    
    private func setDrageBackground(width: Float64) {
        if !width.isNaN && !width.isInfinite {
            self.progressBackgroundView.frame = CGRect(x: 2,
                                                       y: 0,
                                                       width: Int(width),
                                                       height: Int(ScreenUtils.setWidth(value: 32)))
        }
    }
    
    private func setDragBackgroundViewForBehind(width: Float64) {
        if !width.isNaN && !width.isInfinite {
            self.progressBackgroundView.frame = CGRect(x: Int(self.progressIndicator.frame.origin.x) + 14,
                                                       y: 0,
                                                       width: Int(width) + 12,
                                                       height: Int(ScreenUtils.setWidth(value: 32)))
        }
    }
    
    // MARK: - Drag Functions Helpers
    private func positionFromValue(value: CGFloat) -> CGFloat{
        let position = value * self.frame.size.width / 100
        if !position.isNaN && !position.isInfinite {
            return position
        } else {
            return 0
        }
    }
    
    private func getPositionLimits(with drag: DragHandleChoice) -> (min: CGFloat, max: CGFloat) {
        if drag == .start {
            return (
                positionFromValue(value: self.endPercentage - valueFromSeconds(seconds: self.minSpace)),
                positionFromValue(value: self.endPercentage - valueFromSeconds(seconds: self.maxSpace))
            )
        } else {
            return (
                positionFromValue(value: self.startPercentage + valueFromSeconds(seconds: self.minSpace)),
                positionFromValue(value: self.startPercentage + valueFromSeconds(seconds: self.maxSpace))
            )
        }
    }
    
    private func checkEdgeCasesForPosition(with position: CGFloat, and positionLimit: CGFloat, and drag: DragHandleChoice) -> CGFloat {
        if drag == .start {
            if Float(self.duration) < self.minSpace {
                return 0
            } else {
                if position > positionLimit {
                    return positionLimit
                }
            }
        } else {
            if Float(self.duration) < self.minSpace {
                return self.frame.size.width
            } else {
                if position < positionLimit {
                    return positionLimit
                }
            }
        }
        
        return position
    }
    
    private func secondsFromValue(value: CGFloat) -> Float64{
        return duration * Float64((value / 100))
    }
    
    private func valueFromSeconds(seconds: Float) -> CGFloat{
        return CGFloat(seconds * 100) / CGFloat(duration)
    }
    
    private func updateGestureStatus(recognizer: UIGestureRecognizer) {
        if recognizer.state == .began {
            self.isReceivingGesture = true
            self.delegate?.sliderGesturesBegan?()
            
        } else if recognizer.state == .ended {
            self.isReceivingGesture = false
            self.delegate?.sliderGesturesEnded?()
        }
    }
        
    internal func resetProgressPosition() {
        self.progressPercentage = self.startPercentage
        let progressPosition = positionFromValue(value: self.progressPercentage)
        progressIndicator.center = CGPoint(x: progressPosition , y: progressIndicator.center.y)
        
        let startSeconds = secondsFromValue(value: self.progressPercentage)
        self.delegate?.indicatorDidChangePosition(videoRangeSlider: self, position: startSeconds)
        self.delegate?.resetPosition?()
        
    }
    
    // MARK: - Layout Subviews
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let startPosition = positionFromValue(value: self.startPercentage)
        let endPosition = positionFromValue(value: self.endPercentage)
        let progressPosition = positionFromValue(value: self.progressPercentage)
        
        startIndicator.center = CGPoint(x: startPosition, y: startIndicator.center.y)
        endIndicator.center = CGPoint(x: endPosition, y: endIndicator.center.y)
        progressIndicator.center = CGPoint(x: progressPosition, y: progressIndicator.center.y)
        draggableView.frame = CGRect(x: startIndicator.frame.origin.x + startIndicator.frame.size.width,
                                     y: 0,
                                     width: endIndicator.frame.origin.x - startIndicator.frame.origin.x - endIndicator.frame.size.width,
                                     height: self.frame.height)
    }
}

