//
//  GraphViewController.swift
//  Calculator
//
//  Created by Ali Mohamed on 11/15/17.
//  Copyright © 2017 Ali Mohamed. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {

    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: #selector(graphView.zoom(recognizer:))))
            
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: #selector(graphView.move(recognizer:))))
            
            let recognizer = UITapGestureRecognizer(target: graphView, action: #selector(graphView.doubleTap(recognizer:)))
            recognizer.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(recognizer)
            
             updateUI()
            
        }
    }
    
    func updateUI() {
        //graphView?.scale = 50.0
        graphView?.color = UIColor.blue
    }
    
    func getBounds() -> CGRect {
        return navigationController?.view.bounds ?? view.bounds
    }
    
    func getYCoordinate(x: CGFloat) -> CGFloat? {
        if let function = function {
            return CGFloat(function(x))
        }
        return nil
    }
    
    var function: ((CGFloat) -> Double)?

}
