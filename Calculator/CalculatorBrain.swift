//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Michael Griebling on 26Apr2016.
//  Copyright © 2016 Solinst Canada. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    fileprivate var accumulator = 0.0
    fileprivate var internalProgram = [PropertyList]()
    
    var description = " "
    var isPartialResult : Bool {
        return pending != nil
    }
    
    fileprivate var argument : String?
    
    func setOperand(_ operand: Double) {
        accumulator = operand
        internalProgram.append(operand as CalculatorBrain.PropertyList)
        if isPartialResult {
            argument = String(operand)
        } else {
            addToDescription(String(operand))
        }
    }
    
    fileprivate var operations: Dictionary<String,Operation> = [
        "π"   : Operation.constant(M_PI),
        "e"   : Operation.constant(M_E),
        "±"   : Operation.unaryPrefixOperation( - ),
        "√"   : Operation.unaryPrefixOperation(sqrt),
        "∛"   : Operation.unaryPrefixOperation(cbrt),
        "x²"  : Operation.unaryPostfixOperation( { $0 * $0 } ),
        "x³"  : Operation.unaryPostfixOperation( { $0 * $0 * $0 } ),
        "x⁻¹" : Operation.unaryPostfixOperation( { $0 == 0 ? 0.0 : 1.0 / $0 } ),
        "cos" : Operation.unaryPrefixOperation(cos),
        "sin" : Operation.unaryPrefixOperation(sin),
        "exp" : Operation.unaryPrefixOperation(exp),
        "log" : Operation.unaryPrefixOperation(log),
        "×"   : Operation.binaryOperation( * ),
        "÷"   : Operation.binaryOperation( / ),
        "+"   : Operation.binaryOperation( + ),
        "−"   : Operation.binaryOperation( - ),
        "="   : Operation.equals
    ]
    
    fileprivate enum Operation {
        case constant(Double)
        case unaryPrefixOperation((Double) -> Double)
        case unaryPostfixOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    fileprivate func addToDescription (_ symbol: String, asPrefix: Bool = false) {
        var result = description
        
        // We use " " when no description so the label isn't resized
        if result == " " {
            result = ""
        }
        
        // remove "x"s from the symbol (e.g., x³)
        let strippedSymbol = symbol.replacingOccurrences(of: "x", with: "")
        
        if let arg = argument {
            if asPrefix {
                result = result + strippedSymbol + "(" + arg + ")"
            } else {
                result =  result + "(" + arg + ")" + strippedSymbol
            }
            argument = nil
        } else {
            result = result + symbol
        }
        
        // either add symbol as a prefix or a suffix
        description = result
    }
    
    fileprivate func addBracketsToDescription() {
        if isPartialResult { description = "(" + description + ")" }
    }
    
    func performOperation(_ symbol: String) {
        internalProgram.append(symbol as CalculatorBrain.PropertyList)
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                addToDescription(symbol)
            case .unaryPrefixOperation(let function):
                addToDescription(symbol, asPrefix: true)
                accumulator = function(accumulator)
            case .unaryPostfixOperation(let function):
                accumulator = function(accumulator)
                addToDescription(symbol)
            case .binaryOperation(let function):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                addToDescription(symbol)
            case .equals:
                executePendingBinaryOperation()
            }
        }
    }
    
    fileprivate func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    fileprivate var pending: PendingBinaryOperationInfo?
    
    fileprivate struct PendingBinaryOperationInfo {
        let binaryFunction: (Double, Double) -> Double
        let firstOperand: Double
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
