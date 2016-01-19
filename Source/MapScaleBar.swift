// MapScaleBar.swift
//
// Copyright (c) 2015 René Lindhorst
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import UIKit
import MapKit


/// The bar scale (also called a linear scale or graphical scale) is usually present on most maps. 
/// It visually shows the relationship between distances on the map and the real world.
@IBDesignable
public class MapScaleBar: UIView {

    /// Scale bar type.
    public enum Type: Int {
        case SingleDivision = 0
        case Alternating = 1
        case DoubleAlternating = 2
    }

    /// Scale bar label option.
    public enum LabelOption: Int {
        case Edges = 0
        case Center = 1
    }
    
    public enum Unit {
        case Kilometers
        case Meters
        
        private func localizedString() -> String {
            switch self {
                case .Kilometers:
                    return NSLocalizedString("km", comment: "Kilometers unit")
                case .Meters:
                    return NSLocalizedString("m", comment: "Meters unit")
            }
        }
        
        private static let OneKilometerInMeters = 1000
    }
    
    /// The map this scale bar belongs to.
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            adjustScale()
        }
    }
    
    /// The type of scale bar to be rendered.
    public var type: Type = .SingleDivision
    
    @IBInspectable public var typeAdapter: Int {
        get {
            return type.rawValue
        }
        set {
            type = Type(rawValue: newValue) ?? .SingleDivision
            setNeedsDisplay()
        }
    }
    
    /// The type of scale bar to be rendered.
    public var labelOption: LabelOption = .Edges
    
    @IBInspectable public var labelOptionAdapter: Int {
        get {
            return labelOption.rawValue
        }
        set {
            labelOption = LabelOption(rawValue: newValue) ?? .Edges
            setNeedsDisplay()
        }
    }
    
    public private(set) var unit: Unit = .Kilometers
    
    public private(set) var value: Int = 0
    
    /// The possible metrical scale bar values (in meters).
    private let  scaleBarValues = [10_000_000, 5_000_000, 2_000_000,
                                    1_000_000,   500_000,   200_000,
                                      100_000,    50_000,    20_000,
                                       10_000,     5_000,     2_000,
                                        1_000,       500,       200,
                                          100,        50,        20,
                                           10,         5,         2]
    
    private var scaleBarWidth = 0.0
    
    private static let MaxScaleBarWidth = 150.0
    
    
    private func initView() {
        backgroundColor = UIColor.clearColor()

        adjustScale()
    }
    
    
    /// Adjust the scale length and label as the map is zoomed in or out.
    public func adjustScale() {

        if let mapView = mapView {
            let metersPerPoint: Double
            
            #if !TARGET_INTERFACE_BUILDER
                let horizontalDistanceInPoints = 200.0
                let topLeftCoordinate = mapView.convertPoint(CGPointMake(0, CGRectGetMinY(frame)), toCoordinateFromView: self)
                let topRightCoordinate = mapView.convertPoint(CGPoint(x: horizontalDistanceInPoints, y: Double(CGRectGetMinY(frame))), toCoordinateFromView: self)
                let horizontalDistanceInMeters = MKMetersBetweenMapPoints(MKMapPointForCoordinate(topLeftCoordinate), MKMapPointForCoordinate(topRightCoordinate))

                metersPerPoint = horizontalDistanceInMeters / horizontalDistanceInPoints;
            #else
                metersPerPoint = 440
            #endif
            
            if metersPerPoint == 0 {
                return;
            }
            
            
            scaleBarWidth = 0.0
            var scaleBarValue = 0
            for possibleScaleBarValue in scaleBarValues {
                scaleBarWidth = Double(possibleScaleBarValue) / metersPerPoint
                if scaleBarWidth < MapScaleBar.MaxScaleBarWidth {
                    scaleBarValue = possibleScaleBarValue
                    break
                }
            }


            if scaleBarValue < Unit.OneKilometerInMeters {
                unit = .Meters
                value = scaleBarValue
            } else {
                unit = .Kilometers
                value = scaleBarValue / Unit.OneKilometerInMeters
            }

            
            setNeedsDisplay()
        }
    }

    
    public override func drawRect(rect: CGRect) {
        if mapView == .None {
            return
        }
        
        //
        // draw bar
        //
        
        let barRect = CGRectIntegral(CGRect(x: (Double(frame.size.width)-scaleBarWidth)/2, y: 2, width: scaleBarWidth, height: 5))
        
        switch type {
            case .SingleDivision:
                let context = UIGraphicsGetCurrentContext()
                
                UIColor(white: 1.0, alpha: 0.5).setFill()
                CGContextFillRect(context, UIEdgeInsetsInsetRect(barRect, UIEdgeInsets(top: -0.5, left: -0.5, bottom: -0.5, right: -0.5)))
                
                tintColor.setFill()
                CGContextFillRect(context, barRect)
            
            case .Alternating:
                let context = UIGraphicsGetCurrentContext()
                CGContextSetAllowsAntialiasing(context, false)
                
                UIColor(white: 1.0, alpha: 0.5).setStroke()
                CGContextAddPath(context, CGPathCreateWithRect(UIEdgeInsetsInsetRect(barRect, UIEdgeInsets(top: -0.5, left: -0.5, bottom: -0.5, right: -0.5)), nil))
                CGContextSetLineWidth(context, 0.5)
                CGContextStrokePath(context)

                tintColor.setStroke()
                CGContextAddPath(context, CGPathCreateWithRect(barRect, nil))
                CGContextSetLineWidth(context, 0.5)
                CGContextStrokePath(context)
                
                let innerRect = UIEdgeInsetsInsetRect(barRect, UIEdgeInsets(top: 0, left: 0.5, bottom: 0.5, right: 0))
                
                UIColor(white: 1.0, alpha: CGColorGetAlpha(tintColor.CGColor)).setFill()
                CGContextFillRect(context, innerRect)
                
                tintColor.setFill()
                let numberOSegments = 5
                var segmentRect = innerRect
                segmentRect.size.width = CGFloat(scaleBarWidth/Double(numberOSegments))
                for var index = 1; index < numberOSegments; index+=2 {
                    segmentRect.origin.x = innerRect.origin.x + segmentRect.size.width*CGFloat(index)
                    CGContextFillRect(context, segmentRect)
                }
                
                CGContextSetAllowsAntialiasing(context, true)
            
            case .DoubleAlternating:
                let context = UIGraphicsGetCurrentContext()
                CGContextSetAllowsAntialiasing(context, false)
                
                UIColor(white: 1.0, alpha: CGColorGetAlpha(tintColor.CGColor)).setFill()
                CGContextFillRect(context, UIEdgeInsetsInsetRect(barRect, UIEdgeInsets(top: -0.5, left: -0.5, bottom: -0.5, right: -0.5)))
                
                tintColor.setStroke()
                CGContextAddPath(context, CGPathCreateWithRect(UIEdgeInsetsInsetRect(barRect, UIEdgeInsets(top: 0.5, left: 0, bottom: 0, right: 0.5)), nil))
                CGContextSetLineWidth(context, 0.5)
                CGContextStrokePath(context)
                
                tintColor.setFill()
                let innerRect = UIEdgeInsetsInsetRect(barRect, UIEdgeInsets(top: 0.5, left: 0.5, bottom: 0.5, right: 0.5))
                let numberOSegments = 5
                var segmentRect = innerRect
                segmentRect.size.width = CGFloat(scaleBarWidth/Double(numberOSegments))
                segmentRect.size.height = segmentRect.size.height/2.0
                for var index = 0; index < numberOSegments; index++ {
                    segmentRect.origin.x = innerRect.origin.x + segmentRect.size.width*CGFloat(index)
                    segmentRect.origin.y = innerRect.origin.y + segmentRect.size.height*CGFloat(index%2)
                    CGContextFillRect(context, segmentRect)
                }
            
                CGContextSetAllowsAntialiasing(context, true)
        }
        
        
        //
        // draw label
        //
        
        let labelRect = CGRect(x: (Double(frame.size.width)-scaleBarWidth)/2, y: 8, width: scaleBarWidth, height: 10)
        
        let string: String
        switch labelOption {
            case .Edges:
                string = "0\t\(value) \(unit.localizedString())"

            case .Center:
                string = "\(value) \(unit.localizedString())"
        }
        
        let attributedString = NSMutableAttributedString(string: string)
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.maximumLineHeight = 12.0
        paragraph.alignment = .Center
        paragraph.tabStops = [NSTextTab(textAlignment: .Right, location: labelRect.size.width, options: [:])]
        
        let count = string.utf8.count
        attributedString.addAttribute(NSBackgroundColorAttributeName, value:UIColor.clearColor(), range: NSMakeRange(0, count))
        attributedString.addAttribute(NSFontAttributeName, value:UIFont.systemFontOfSize(10), range: NSMakeRange(0, count))
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraph, range: NSMakeRange(0, count))
        
        attributedString.drawInRect(labelRect)
    }

    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
}