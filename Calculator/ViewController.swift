//
//  ViewController.swift
//  Calculator
//
//  Created by Michael Griebling on 26Apr2016.
//  Copyright © 2016 Solinst Canada. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet fileprivate var display: UILabel!
    @IBOutlet fileprivate var history: UILabel!
    
    fileprivate var userIsInTheMiddleOfTyping = false

    @IBAction fileprivate func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        let textCurrentlyInDisplay = display.text!
        if userIsInTheMiddleOfTyping {
            if digit == "." && textCurrentlyInDisplay.contains(".") { return }
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    fileprivate var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    var savedProgram: CalculatorBrain.PropertyList?
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
            updateHistory()
        }
    }
    
    @IBAction func clear() {
        userIsInTheMiddleOfTyping = false
        displayValue = 0
        savedProgram = nil
        brain.clear()
        updateHistory()
    }
    
    fileprivate func updateHistory() {
        let postString = brain.isPartialResult ? "..." : "="
        if !userIsInTheMiddleOfTyping {
            history.text = brain.description + postString
        }
    }
    
    fileprivate var brain = CalculatorBrain()
    
    @IBAction fileprivate func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
        updateHistory()
    }


}

