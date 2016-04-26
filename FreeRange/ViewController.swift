//
//  ViewController.swift
//  FreeRange
//
//  Created by Christopher Scalcucci on 4/24/16.
//  Copyright © 2016 Christopher Scalcucci. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FreeRangeDelegate {
    let rangeSlider = FreeRange(frame: CGRectZero)
    let rangeSliderTwo = FreeRange(frame: CGRectZero)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(rangeSlider)
        view.addSubview(rangeSliderTwo)
                
        rangeSlider.delegate = self
        rangeSliderTwo.delegate = self
        
        setSliderOne()
        setSliderTwo()
    }
    
    override func viewDidLayoutSubviews() {
        let margin: CGFloat = 20.0
        let width = view.bounds.width - 2.0 * margin
        rangeSlider.frame = CGRect(x: margin, y: margin + topLayoutGuide.length + (view.frame.width / 4), width: width, height: 31.0)
        rangeSliderTwo.frame = CGRect(x: margin, y: margin + topLayoutGuide.length + (view.frame.width / 2), width: width, height: 31.0)
    }
    
    func rangeSliderValueChanged(slider: FreeRange) {
        print("Range slider value changed (Lower: \(slider.thumbPosition.left) Upper: \(slider.thumbPosition.right))")
    }
    
    func setSliderOne() {
        //self.rangeSlider.setTrackStyle(TrackStyle.Revealed(image: UIImage(named: "Inner")!, outerAlpha: 0.4))
        //self.rangeSlider.setTrackStyle(TrackStyle.Filled(inner: .redColor(), outer: .blueColor()))
        rangeSlider.setTrackStyle(TrackStyle.Transformed(inner: UIImage(named: "Inner")!, outer: UIColor.greenColor()))
        rangeSlider.setThumbStyle(ThumbStyle.Balanced(UIColor.redColor()), forThumb: .Right)
        rangeSlider.setThumbStyle(ThumbStyle.Balanced(UIColor.blueColor()), forThumb: .Left)
        rangeSlider.curvaceousness = 0.0
    }
    
    func setSliderTwo() {
        rangeSliderTwo.setTrackStyle(TrackStyle.Revealed(media: UIImage(named: "Inner")!, outerAlpha: 0.5))
        rangeSliderTwo.setThumbStyle(ThumbStyle.Balanced(UIImage(named: "Inner")!), forThumb: .Right)
        rangeSliderTwo.setThumbStyle(ThumbStyle.Balanced(UIImage(named: "Outer")!), forThumb: .Left)
        rangeSliderTwo.curvaceousness = 5.0
    }
}

