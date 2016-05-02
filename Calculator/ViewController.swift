//
//  ViewController.swift
//  Calculator
//
//  Created by Michael Griebling on 26Apr2016.
//  Copyright © 2016 Solinst Canada. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private var display: UILabel!
    @IBOutlet private var history: UILabel!
    
    private var userIsInTheMiddleOfTyping = false

    @IBAction private func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        let textCurrentlyInDisplay = display.text!
        if userIsInTheMiddleOfTyping {
            if digit == "." && textCurrentlyInDisplay.containsString(".") { return }
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    private var displayValue: Double {
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
    
    private func updateHistory() {
        let postString = brain.isPartialResult ? "..." : "="
        if !userIsInTheMiddleOfTyping {
            history.text = brain.description + postString
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction private func performOperation(sender: UIButton) {
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

