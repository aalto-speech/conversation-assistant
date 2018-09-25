//
//  RecordButton.swift
//  ConvAssistantAR
//
//  Created by Virkkunen Anja on 09/05/2018.
//  Copyright © 2018 Virkkunen Anja. All rights reserved.
//

import UIKit

class RecordButton: UIButton {
    
    var pathLayer: CAShapeLayer!
    var cameraOn: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    let animationDuration = 0.4
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    // Common set up code
    private func setup() {
        // Add a shape layer for the inner shape to be able to animate it
        self.pathLayer = CAShapeLayer()
        // Show the right shape for the current state of the control
        self.pathLayer.path = self.currentInnerPath().cgPath
        // No stroke color, draws a ring around the inner circle
        self.pathLayer.strokeColor = nil
        // Set the color for the inner shape
        self.pathLayer.fillColor = UIColor.red.cgColor
        // Add the path layer to the control layer for drawing
        self.layer.addSublayer(self.pathLayer)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Clear the title
        self.setTitle("", for: UIControlState.normal)
        // Add out target for event handling
        self.addTarget(self, action: #selector(touchUpInside), for: UIControlEvents.touchUpInside)
        self.addTarget(self, action: #selector(touchDown), for: UIControlEvents.touchDown)
        self.addTarget(self, action: #selector(touchDragExit), for: UIControlEvents.touchDragExit)
    }
    
    // MARK: Private Methods
    private func currentInnerPath() -> UIBezierPath {
        // Change the shape of the button when selected by choosing right inner path
        var returnPath: UIBezierPath
        if (self.isSelected) {
            returnPath = self.innerSquarePath()
        }
        else {
            returnPath = self.innerCirclePath()
        }
        return returnPath
    }
    
    private func innerSquarePath() -> UIBezierPath {
        // A rectangle
        return UIBezierPath(roundedRect: CGRect(x: 13, y: 13, width: 20, height: 20), cornerRadius: 4)
    }
    
    private func innerCirclePath() -> UIBezierPath {
        // A rectangle that is rounded to look like a circle
        return UIBezierPath(roundedRect: CGRect(x: 8, y: 8, width: 30, height: 30), cornerRadius: 15)
    }
    
    override func draw(_ rect: CGRect) {
        // The outer white ring is always drawn
        let outerRing = UIBezierPath(ovalIn: CGRect(x: 3, y: 3, width: 40, height: 40))
        outerRing.lineWidth = 4
        if cameraOn {
            UIColor.white.setStroke()
        } else {
            UIColor.black.setStroke()
        }
        outerRing.stroke()
    }
    
    func startPulseAnimation() {
        // When recording, the inner shape pulsates
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        // Set pulse properties
        pulseAnimation.duration = 1
        pulseAnimation.speed = 0.5
        pulseAnimation.fromValue = 0.1
        pulseAnimation.toValue = 1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pulseAnimation.autoreverses = true
        // Repeat until recording is stopped
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        self.pathLayer.add(pulseAnimation, forKey: "animateOpacity")
    }
    
    // MARK: Button Action
    @objc func touchDown(sender: UIButton) {
        // When the user touches the button, the inner shape should change transparency
        // Create the animation for the fill color
        let morph = CABasicAnimation(keyPath: "fillColor")
        morph.duration = animationDuration
        // Set the value we want to animate to
        morph.toValue = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5).cgColor
        // Ensure the animation does not get reverted once completed
        morph.fillMode = kCAFillModeForwards
        morph.isRemovedOnCompletion = false
        morph.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.pathLayer.add(morph, forKey: "")
    }
    
    @objc func touchUpInside(sender: UIButton) {
        // Create first animation to restore the color of the button
        let colorChange = CABasicAnimation(keyPath: "fillColor")
        colorChange.duration = animationDuration
        colorChange.toValue = UIColor.red.cgColor
        // Make sure that the color animation is not reverted once the animation is completed
        colorChange.fillMode = kCAFillModeForwards
        colorChange.isRemovedOnCompletion = false
        
        // Indicate which animation timing function to use, in this case ease in and ease out
        colorChange.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        // Add the animation
        self.pathLayer.add(colorChange, forKey: "darkColor")

        // Change the state of the control to update the shape
        self.isSelected = !self.isSelected
        
        if (self.isSelected) {
            startPulseAnimation()
        } else {
            // If recording is stopped, stop the pulse animation
            self.pathLayer.removeAnimation(forKey: "animateOpacity")
        }
    }
    
    @objc func touchDragExit(sender: UIButton) {
        self.pathLayer.removeAllAnimations()
    }
    
    // Override the setter for the isSelected state to update the inner shape
    override var isSelected: Bool {
        didSet {
            // Change the inner shape to match the state
            let morph = CABasicAnimation(keyPath: "path")
            morph.duration = animationDuration
            morph.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            // Change the shape according to the current state of the control
            morph.toValue = self.currentInnerPath().cgPath
            
            // Ensure the animation is not reverted once completed
            morph.fillMode = kCAFillModeForwards
            morph.isRemovedOnCompletion = false
            // Add the animation
            self.pathLayer.add(morph, forKey: "")
            
        }
    }
    override var isEnabled: Bool {
        didSet {
            if (isEnabled == true) {
                self.pathLayer.fillColor = UIColor.red.cgColor
            }
            else {
                self.pathLayer.fillColor = UIColor.gray.cgColor
            }
        }
    }
    
    
    
    
}
