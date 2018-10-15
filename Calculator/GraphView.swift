//
//  GraphView.swift
//  Calculator
//
//  Created by Ali Mohamed on 11/15/17.
//  Copyright © 2017 Ali Mohamed. All rights reserved.
//

import UIKit

protocol GraphViewDataSource {
    func getBounds() -> CGRect
    func getYCoordinate(x: CGFloat) -> CGFloat?
}

class GraphView: UIView {
    
    var origin: CGPoint! { didSet { setNeedsDisplay() } }
    
    var scale: CGFloat = 50.0 { didSet { setNeedsDisplay() } }
    
    var color = UIColor.black { didSet { setNeedsDisplay() } }
    
    var lineWidth: CGFloat = 2.0 { didSet { setNeedsDisplay() } }
    
    var originLocation = CGPoint.zero
    
    
    func graphCenter() -> CGPoint {
        return convert(center, from: superview)
    }
    
    func findOrigin() -> CGPoint {
        var origin = originLocation
        origin.x += graphCenter().x
        origin.y += graphCenter().y
        return origin
    }
    
    var axesDrawer = AxesDrawer()
    
    override func draw(_ rect: CGRect) {
        
        origin = origin ?? CGPoint(x: bounds.midX, y: bounds.midY)
        
        axesDrawer.color = color
        axesDrawer.contentScaleFactor = scale
        axesDrawer.drawAxes(in: self.bounds, origin: origin, pointsPerUnit: scale)
        
        functionPath().stroke()
    }
    
    
    var dataSource: GraphViewDataSource?
    
    private func functionPath() -> UIBezierPath {
        print("i am being drawn")
        let path = UIBezierPath()
        
        let data = dataSource
        
        var pathIsEmpty = true
        var point = CGPoint()
        
        let width = Int(bounds.size.width * scale)
        for pixel in 0...width {
            point.x = CGFloat(pixel) / scale
            
            if let y = data?.getYCoordinate(x: (point.x - origin.x) / scale) {
                
                
                if !y.isNormal && !y.isZero {
                    pathIsEmpty = true
                    continue
                }
                
                point.y = origin.y - y * scale
                
                if pathIsEmpty {
                    path.move(to: point)
                    pathIsEmpty = false
                } else {
                    path.addLine(to: point)
                }
            }
        }
        
        path.lineWidth = lineWidth
        print("i think im good")
        return path
    }
 
    
    func doubleTap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            origin = recognizer.location(in: self)
        }
    }
    
    func zoom(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            scale *= recognizer.scale
            recognizer.scale = 1.0
        default: break
        }
    }
    
    func move(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .changed: fallthrough
        case .ended:
            let translation = recognizer.translation(in: self)
            
            origin.x += translation.x
            origin.y += translation.y
            
            recognizer.setTranslation(CGPoint.zero, in: self)
        default: break
        }
    }
    
}
