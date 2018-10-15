//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Student on 9/6/17.
//  Copyright © 2017 Ali Mohamed. All rights reserved.
//

import Foundation


struct CalculatorBrain {
    
    private var accumulator: Double?
    
    var variableValues = [String:Double]()
    
    private var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    private var internalProgram = [AnyObject]()
    
    var description: String {
        get {
            if pending == nil {
                return descriptionAccumulator
            } else {
                return pending!.descriptionFunction(pending!.descriptionOperand,
                                                    pending!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
            }
        }
    }
    
    private var descriptionAccumulator = "0" {
        didSet {
            if pending == nil {
                currentPrecedence = Precedence.Max
            }
        }
    }
    
    private var currentPrecedence = Precedence.Max
    
    mutating func clear() {
        pending = nil
        accumulator = 0.0
        descriptionAccumulator = "0"
        internalProgram.removeAll()
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        descriptionAccumulator = String(format:"%g", operand)
        internalProgram.append(operand as AnyObject)
    }
    
    mutating func setOperand(_ variableName: String) {
        variableValues[variableName] = variableValues[variableName] ?? 0.0
        accumulator = variableValues[variableName]!
        descriptionAccumulator = variableName
        internalProgram.append(variableName as AnyObject)
    }
    
    private enum Precedence: Int {
        case Min = 0, Max
    }
    
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double, (String) -> String)
        case BinaryOperation((Double, Double) -> Double, (String, String) -> String, Precedence)
        case NullaryOperation((Double) -> Double, String)
        case Equals
    }
    
    private var operations: Dictionary<String, Operation> =
        [
            "π" : Operation.Constant(Double.pi),
            "e" : Operation.Constant(M_E),
            "rand" : Operation.NullaryOperation({_ in Double(arc4random())}, "arc4random"),
            "±" : Operation.UnaryOperation({-$0}, { "-(\($0))"}),
            "√" : Operation.UnaryOperation(sqrt, { "√(\($0))"}),
            "cos" : Operation.UnaryOperation(cos, { "cos(\($0))"}),
            "sin" : Operation.UnaryOperation(sin, { "sin(\($0))"}),
            "tan" : Operation.UnaryOperation(tan, { "tan(\($0))"}),
            "x⁻¹" : Operation.UnaryOperation({1 / $0},{ "(\($0))⁻¹"}),
            "x²"  : Operation.UnaryOperation({$0 * $0}, { "(\($0))²"}),
            "×" : Operation.BinaryOperation({$0 * $1}, { "\($0)×\($1)"}, Precedence.Max),
            "÷" : Operation.BinaryOperation({$0 / $1}, { "\($0)÷\($1)"}, Precedence.Max),
            "+" : Operation.BinaryOperation({$0 + $1}, { "\($0)+\($1)"}, Precedence.Min),
            "−" : Operation.BinaryOperation({$0 - $1}, { "\($0)-\($1)"}, Precedence.Min),
            "=" : Operation.Equals
    ]
    
    
    mutating func performOperation(_ symbol: String) {
        
        internalProgram.append(symbol as AnyObject)
        
        if let operation = operations[symbol] {
            
            switch operation {
                
            case .Constant(let value):
                accumulator = value
                descriptionAccumulator = symbol
                
            case .UnaryOperation(let function, let descriptionFunction):
                if accumulator == nil {
                    accumulator = 0.0
                }
                accumulator = function(accumulator!)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
                
                
            case .BinaryOperation(let function, let descriptionFunction, let precedence):
                if accumulator == nil {
                    accumulator = 0.0
                }
                
                executePendingBinaryOperation()
                if currentPrecedence.rawValue < precedence.rawValue {
                    descriptionAccumulator = "(\(descriptionAccumulator))"
                }
                currentPrecedence = precedence
                pending = PendingBinaryOperation(binaryFunction: function, firstOperand: accumulator!,
                                                     descriptionFunction: descriptionFunction,
                                                     descriptionOperand: descriptionAccumulator)
                accumulator = nil
                
            case .Equals:
                if accumulator != nil {
                    executePendingBinaryOperation()
                }
                
            case .NullaryOperation(let function, let descriptionValue):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                    descriptionAccumulator = descriptionValue
                }
            }
        }
    }
    
    mutating func undo() {
        if !internalProgram.isEmpty {
            internalProgram.removeLast()
            program = internalProgram as CalculatorBrain.PropertyList
        } else {
            clear()
            descriptionAccumulator = ""
        }
    }
    
    private mutating func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator!)
            descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand, descriptionAccumulator)
            pending = nil
        }
    }
    
    private var pending: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
    }
    
    
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram as CalculatorBrain.PropertyList
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let variableName = op as? String {
                        if variableValues[variableName] != nil {
                            setOperand(variableName)
                        } else if let operation = op as? String {
                            performOperation(operation)
                        }
                    }
                }
            }
        }
    }
    
    func getDescription() -> String {
        
        return isPartialResult ? (description + "...") : (description + "=")
    }
    
    
    
}
