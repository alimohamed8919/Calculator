//
//  ViewController.swift
//  Calculator
//
//  Created by Student on 8/28/17.
//  Copyright © 2017 Ali Mohamed. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var brain = CalculatorBrain()
    private var symbol = ""
    
    @IBOutlet weak var display: UILabel?
    
    @IBOutlet weak var descripDisplay: UILabel!
    
    
    var userInTheMiddleOfTyping = false
    
    private func updateUI() {
        descripDisplay.text = (brain.description.isEmpty ? "0" : brain.getDescription())
        //displayValue = brain.result!
    }
    
    var displayValue: Double {
        get {
            return Double(display!.text!)!
        }
        
        set {
            let value: String = String(newValue).substring(from: String(newValue).range(of: ".")!.upperBound)
            let holder = Double(value)
            if holder != 0.0 {
                display!.text = String(newValue)
            
            }else {
                display!.text = String(String(newValue).characters.dropLast(2))
            }
        }
    }
    
    
    @IBAction func touchDigit(_ sender: UIButton) {
        
        let digit = sender.currentTitle!
        
        if userInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display!.text!
            if digit != "." || textCurrentlyInDisplay.range(of: ".") == nil {
                display!.text = textCurrentlyInDisplay + digit
            }
            
        }else {
            if digit == "." {
                display!.text = "0."
                
                
            }else {
                display!.text = digit
    
            }
            userInTheMiddleOfTyping = true
        }
    }
    
    
    @IBAction func backSpace(_ sender: UIButton) {
        
        guard userInTheMiddleOfTyping == true else {
            brain.undo()
            updateUI()
            return
        }
        
        guard var number = display?.text else {
            return
        }
        
        number = String(number.characters.dropLast(1))

        if number.isEmpty {
            if savedFunction != nil {
                brain.program = savedFunction!
                displayValue = brain.result!
            }
            else {
                number = "0"
                userInTheMiddleOfTyping = false
                display?.text = number
            }
        }
    }
    
    
    var savedFunction: CalculatorBrain.PropertyList?
    
    @IBAction func clear(_ sender: UIButton) {
        savedFunction = brain.program
        brain.clear()
        displayValue = 0
        descripDisplay.text = "0"
        brain.variableValues["M"] = 0
        userInTheMiddleOfTyping = false
    }

    
    @IBAction func setVariable(_ sender: UIButton) {
        descripDisplay.text = (display?.text)! + "→M"
        brain.variableValues["M"] = displayValue
        if userInTheMiddleOfTyping {
            userInTheMiddleOfTyping = false
        } else {
            brain.undo()
        }
        
        brain.program = brain.program
        updateUI()

    }

    
    @IBAction func getVariable(_ sender: UIButton) {
        
        brain.setOperand("M")
        userInTheMiddleOfTyping = false
        updateUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segue working")
        
        let graphVC: GraphViewController = segue.destination as! GraphViewController
        print("working2")
        graphVC.navigationItem.title = brain.description
        graphVC.function = {
            (x: CGFloat) -> Double in
            self.brain.variableValues["M"] = Double(x)
            self.brain.program = self.brain.program
            return self.brain.result!
        }
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        
        symbol = sender.currentTitle!
        
        if ((Double(display!.text!)! == 0) && (symbol == "x⁻¹")) || (symbol == "√" && ((display?.text?.range(of: "-")) != nil)) {
            if symbol == "√" {
                descripDisplay.text = "Can't take the sqrt of a negative number"
            }
            else if symbol == "x⁻¹"{
                descripDisplay.text = "Can't divide by zero"
            }
        }
        else {
            
            if(userInTheMiddleOfTyping) {
                brain.setOperand(displayValue)
                userInTheMiddleOfTyping = false
            }
            if let mathematicalSymbol = sender.currentTitle {
                
                brain.performOperation(mathematicalSymbol)
                
            }
            
            if let result = brain.result {
                displayValue = result
            }
            updateUI()
            
        }
    }
    
    
}
