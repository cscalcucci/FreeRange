//
//  FreeRange.swift
//  FreeRange
//
//  Created by Christopher Scalcucci on 4/24/16.
//  Copyright © 2016 Christopher Scalcucci. All rights reserved.
//

import UIKit
import QuartzCore

protocol FreeRangeDelegate {
    func rangeSliderValueChanged(slider: FreeRange)
}

protocol MediaType {}
extension UIImage: MediaType {}
extension UIColor: MediaType {}
typealias RangeMedia = MediaType

enum ThumbType {
    case Left, Right, Both
}

enum ThumbStyle : RangeMedia {
    case Contained(RangeMedia)
    case Balanced(RangeMedia)
    case Freestyle(RangeMedia)
    
    var underlyingMedia: RangeMedia {
        return getUnderlyingMedia(self)
    }
    
    private func getUnderlyingMedia(style: ThumbStyle) -> RangeMedia {
        switch style {
            case .Contained(let media): return media
            case .Balanced(let media): return media
            case .Freestyle(let media): return media
        }
    }
}

enum TrackStyle {
    case Transformed(inner: RangeMedia, outer: RangeMedia)
    case Revealed(media: RangeMedia, outerAlpha: CGFloat )
    
    var underlyingMedia: (RangeMedia, Any) {
        return getUnderlyingMedia(self)
    }
    
    private func getUnderlyingMedia(style: TrackStyle) -> (RangeMedia, Any) {
        switch style {
            case .Revealed(media: let media, outerAlpha: let alpha)  : return (media, alpha)
            case .Transformed(inner: let inside, outer: let outside) : return (inside, outside)
        }
    }
}

class FreeRange: UIControl {
    var delegate : FreeRangeDelegate?
    internal let trackLayer = FreeRangeTrackLayer()
    internal let leftThumbLayer = FreeRangeThumbLayer(.Left)
    internal let rightThumbLayer = FreeRangeThumbLayer(.Right)
    internal var previousLocation = CGPoint()
    
    private var leftThumb: ThumbStyle = .Balanced(UIColor.whiteColor()) {
        didSet {
            leftThumbLayer.setNeedsDisplay()
        }
    }
    
    private var rightThumb: ThumbStyle = .Balanced(UIColor.whiteColor()) {
        didSet {
            rightThumbLayer.setNeedsDisplay()
        }
    }
    
    private var trackStyle: TrackStyle = .Transformed(inner: UIColor.redColor(), outer: UIColor.greenColor()) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    internal var leftThumbFill : CGColor {
        get {
            var fillColor : CGColor = UIColor.whiteColor().CGColor
            if let media = leftThumb.underlyingMedia as? UIImage {
                fillColor = UIColor(patternImage: media).CGColor
            }
            if let media = leftThumb.underlyingMedia as? UIColor {
                fillColor = media.CGColor
            }
            return fillColor
        }
    }
    
    internal var rightThumbFill : CGColor {
        get {
            var fillColor : CGColor = UIColor.whiteColor().CGColor
            if let media = rightThumb.underlyingMedia as? UIImage {
                fillColor = UIColor(patternImage: media).CGColor
            }
            if let media = rightThumb.underlyingMedia as? UIColor {
                fillColor = media.CGColor
            }
            return fillColor
        }
    }
    
    internal var trackInnerFill : CGColor {
        get {
            var fillColor = UIColor.redColor().CGColor
            switch self.trackStyle {
                case let .Transformed(inner, _):
                    if let media = inner as? UIImage {
                        fillColor = UIColor(patternImage: media).CGColor
                    }
                    if let media = inner as? UIColor {
                        fillColor = media.CGColor
                    }
                case let .Revealed(image, outerAlpha) :
                    if let media = image as? UIImage {
                        fillColor = UIColor(patternImage: media).colorWithAlphaComponent(outerAlpha).CGColor
                    }
                    if let media = image as? UIColor {
                        fillColor = media.colorWithAlphaComponent(outerAlpha).CGColor
                    }
            }
            return fillColor
        }
    }
    
    internal var trackOuterFill : CGColor {
        get {
            var fillColor = UIColor.redColor().CGColor
            switch self.trackStyle {
            case let .Transformed(_, outer):
                if let media = outer as? UIImage { fillColor = UIColor(patternImage: media).CGColor }
                if let media = outer as? UIColor { fillColor = media.CGColor }
            case let .Revealed(image, _):
                if let media = image as? UIImage { fillColor = UIColor(patternImage: media).CGColor }
                if let media = image as? UIColor { fillColor = media.CGColor }
            }
            return fillColor
        }
    }
    
    var minimumValue: Double = 0.0 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var maximumValue: Double = 1.0 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var lowerValue: Double = 0.2 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var upperValue: Double = 0.8 {
        didSet {
            updateLayerFrames()
        }
    }

    
    var curvaceousness: CGFloat = 1.0 {
        didSet {
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC))
            dispatch_after(time, dispatch_get_main_queue()) {
                self.trackLayer.setNeedsDisplay()
                self.leftThumbLayer.setNeedsDisplay()
                self.rightThumbLayer.setNeedsDisplay()
            }
        }
    }
    
    var thumbWidth: CGFloat {
        return CGFloat(bounds.height)
    }
    
    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addTarget(self, action: #selector(sliderValueChanged), forControlEvents: .ValueChanged)
        
        trackLayer.rangeSlider = self
        trackLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(trackLayer)
        
        leftThumbLayer.rangeSlider = self
        leftThumbLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(leftThumbLayer)
        
        rightThumbLayer.rangeSlider = self
        rightThumbLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(rightThumbLayer)
    }
    
    func sliderValueChanged(slider: FreeRange) {
        delegate?.rangeSliderValueChanged(self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setTrackStyle(style: TrackStyle) {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.trackStyle = style
        }
    }
    
    func setThumbStyle(style: ThumbStyle, forThumb type: ThumbType) {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue()) {
            switch type {
                case .Left  : self.leftThumb  = style
                case .Right : self.rightThumb = style
                case .Both  : self.leftThumb  = style; self.rightThumb = style
            }
        }
    }
    
    func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        trackLayer.frame = bounds.insetBy(dx: 0.0, dy: bounds.height / 3)
        trackLayer.setNeedsDisplay()
        
        let lowerThumbCenter = CGFloat(positionForValue(lowerValue))
        
        leftThumbLayer.frame = CGRect(x: lowerThumbCenter - thumbWidth / 2.0, y: 0.0, width: thumbWidth, height: thumbWidth)
        leftThumbLayer.setNeedsDisplay()
        
        let upperThumbCenter = CGFloat(positionForValue(upperValue))
        rightThumbLayer.frame = CGRect(x: upperThumbCenter - thumbWidth / 2.0, y: 0.0,
                                       width: thumbWidth, height: thumbWidth)
        rightThumbLayer.setNeedsDisplay()
        
        CATransaction.commit()
    }
    
    func positionForValue(value: Double) -> Double {
        return Double(bounds.width - thumbWidth) * (value - minimumValue) /
            (maximumValue - minimumValue) + Double(thumbWidth / 2.0)
    }
    
    // Touch handlers
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        previousLocation = touch.locationInView(self)
        
        // Hit test the thumb layers
        if leftThumbLayer.frame.contains(previousLocation) {
            leftThumbLayer.highlighted = true
        } else if rightThumbLayer.frame.contains(previousLocation) {
            rightThumbLayer.highlighted = true
        }
        
        return leftThumbLayer.highlighted || rightThumbLayer.highlighted
    }
    
    func boundValue(value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let location = touch.locationInView(self)
        
        // 1. Determine by how much the user has dragged
        let deltaLocation = Double(location.x - previousLocation.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.width - bounds.height)
        
        previousLocation = location
        
        // 2. Update the values
        if leftThumbLayer.highlighted {
            lowerValue += deltaValue
            lowerValue = boundValue(lowerValue, toLowerValue: minimumValue, upperValue: upperValue)
        } else if rightThumbLayer.highlighted {
            upperValue += deltaValue
            upperValue = boundValue(upperValue, toLowerValue: lowerValue, upperValue: maximumValue)
        }
        
        sendActionsForControlEvents(.ValueChanged)
        return true
        
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        leftThumbLayer.highlighted = false
        rightThumbLayer.highlighted = false
    }
}

class FreeRangeThumbLayer: CALayer {
    
    var highlighted: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var type : ThumbType
    weak var rangeSlider: FreeRange?
    
    init(_ type: ThumbType) {
        self.type = type
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getMedia() -> CGColor? {
        switch self.type {
            case .Left: return rangeSlider?.leftThumbFill
            case .Right: return rangeSlider?.rightThumbFill
            case .Both: return rangeSlider?.leftThumbFill
        }
    }
    
    override func drawInContext(ctx: CGContext) {
        if let slider = rangeSlider {
            let thumbFrame = bounds.insetBy(dx: 2.0, dy: 2.0)
            let cornerRadius = thumbFrame.height * slider.curvaceousness / 2.0
            let thumbPath = UIBezierPath(roundedRect: thumbFrame, cornerRadius: cornerRadius)
            
            // Fill - with a subtle shadow
            let shadowColor = UIColor.grayColor()
            CGContextSetShadowWithColor(ctx, CGSize(width: 0.0, height: 1.0), 1.0, shadowColor.CGColor)
            if let fill = getMedia() {
                CGContextSetFillColorWithColor(ctx, fill)
            }
            CGContextAddPath(ctx, thumbPath.CGPath)
            CGContextFillPath(ctx)
            
            // Outline
            CGContextSetStrokeColorWithColor(ctx, shadowColor.CGColor)
            CGContextSetLineWidth(ctx, 0.5)
            CGContextAddPath(ctx, thumbPath.CGPath)
            CGContextStrokePath(ctx)
            
            if highlighted {
                CGContextSetFillColorWithColor(ctx, UIColor(white: 0.0, alpha: 0.1).CGColor)
                CGContextAddPath(ctx, thumbPath.CGPath)
                CGContextFillPath(ctx)
            }
        }
    }
}

class FreeRangeTrackLayer: CALayer {
    weak var rangeSlider: FreeRange?
    
    override func drawInContext(ctx: CGContext) {
        if let slider = rangeSlider {
            // Clip
            let cornerRadius = bounds.height * slider.curvaceousness / 2.0
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
            CGContextAddPath(ctx, path.CGPath)
            
            // Fill the track
            CGContextSetFillColorWithColor(ctx, slider.trackInnerFill)
            CGContextAddPath(ctx, path.CGPath)
            CGContextFillPath(ctx)
            
            // Fill the highlighted range
            CGContextSetFillColorWithColor(ctx, slider.trackOuterFill)
            let lowerValuePosition = CGFloat(slider.positionForValue(slider.lowerValue))
            let upperValuePosition = CGFloat(slider.positionForValue(slider.upperValue))
            let rect = CGRect(x: lowerValuePosition, y: 0.0, width: upperValuePosition - lowerValuePosition, height: bounds.height)
            CGContextFillRect(ctx, rect)
        }
    }
}