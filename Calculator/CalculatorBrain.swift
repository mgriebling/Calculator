//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Michael Griebling on 26Apr2016.
//  Copyright © 2016 Solinst Canada. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private var accumulator = 0.0
    private var internalProgram = [PropertyList]()
    
    var description = " "
    var isPartialResult : Bool {
        return pending != nil
    }
    
    func setOperand(operand: Double) {
        accumulator = operand
        internalProgram.append(operand)
        addToDescription(String(operand))
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π"   : Operation.Constant(M_PI),
        "e"   : Operation.Constant(M_E),
        "±"   : Operation.UnaryOperation( - ),
        "√"   : Operation.UnaryOperation(sqrt),
        "∛"   : Operation.UnaryOperation(cbrt),
        "x²"  : Operation.UnaryOperation( { $0 * $0 } ),
        "x³"  : Operation.UnaryOperation( { $0 * $0 * $0 } ),
        "x⁻¹"  : Operation.UnaryOperation( { $0 == 0 ? 0.0 : 1.0 / $0 } ),
        "cos" : Operation.UnaryOperation(cos),
        "sin" : Operation.UnaryOperation(sin),
        "exp" : Operation.UnaryOperation(exp),
        "log" : Operation.UnaryOperation(log),
        "×"   : Operation.BinaryOperation( * ),
        "÷"   : Operation.BinaryOperation( / ),
        "+"   : Operation.BinaryOperation( + ),
        "−"   : Operation.BinaryOperation( - ),
        "="   : Operation.Equals
    ]
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    private func addToDescription (symbol: String) {
        var result = description
        
        // We use " " when no description so the label isn't resized
        if result == " " {
            result = ""
        }
        
        // remove "x"s from the symbol (e.g., x³)
        let strippedSymbol = symbol.stringByReplacingOccurrencesOfString("x", withString: "")
        
        description = result + strippedSymbol
    }
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol)
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
                addToDescription(symbol)
            case .UnaryOperation(let function):
                accumulator = function(accumulator)
                addToDescription(symbol)
            case .BinaryOperation(let function):
                addToDescription(symbol)
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals:
                executePendingBinaryOperation()
            }
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    typealias PropertyList = AnyObject
    var program: PropertyList {
        get {
            return internalProgram
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let operation = op as? String {
                        performOperation(operation)
                    }
                }
            }
        }
    }
    
    func clear() {
        accumulator = 0
        pending = nil
        internalProgram.removeAll()
        description = " "
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
}