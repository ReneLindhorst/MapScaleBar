// ViewController.swift
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

import UIKit
import MapKit


class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapScaleBar: MapScaleBar!
    
    
    // The MapScaleBar get adjusted using a DisplayLink so it's size is updated during pan gestures as well as double taps.
    private lazy var displayLink: CADisplayLink = {
        let displayLink = CADisplayLink(target: self.mapScaleBar, selector: Selector("adjustScale"))
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode:NSRunLoopCommonModes)
        displayLink.paused = true
        return displayLink
    }()
    

    func mapView(mapView: MKMapView!, regionWillChangeAnimated animated: Bool) {
        displayLink.paused = false
    }
    
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        displayLink.paused = true
    }
}

