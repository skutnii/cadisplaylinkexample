//
//  AnimatedView.swift
//  CADisplayLinkExample
//
//  Created by Serge Kutny on 2/23/18.
//  Copyright © 2018 skutnii. All rights reserved.
//

import UIKit

class AnimatedView: UIView {
    
    class Geometry {
        static let squareSide: CGFloat = 160.0
    }
    
    class Animation {
        static let period : Double = 0.5
        static let decayTime: Double = 1.0
        static let amplitude: CGFloat = 200.0
    }

    lazy var squareView : UIView = {
        [unowned self] in
        let view = UIView(frame: .zero)
        view.backgroundColor = .blue
        self.addSubview(view)
        return view
    } ()
    
    private var squareOffset: CGFloat = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let squareX = bounds.origin.x + 0.5 * (bounds.size.width - Geometry.squareSide)
        let squareY = bounds.origin.y + 0.5 * (bounds.size.height - Geometry.squareSide) - squareOffset
        let squareOrigin = CGPoint(x: squareX, y: squareY)
        let squareSize = CGSize(width:Geometry.squareSide, height:Geometry.squareSide)
        
        squareView.frame = CGRect(origin:squareOrigin, size:squareSize)
    }
    
    private var elapsedTime: CFTimeInterval = 0
    
    private var currentDisplayLink: CADisplayLink? {
        willSet {
            squareOffset = 0
            elapsedTime = 0
            currentDisplayLink?.invalidate()
        }
    }
    
    @objc private func step(_ displayLink: CADisplayLink) {
        elapsedTime += (displayLink.targetTimestamp - displayLink.timestamp)
        let fadedAmplitude = Animation.amplitude * CGFloat(exp(-elapsedTime / Animation.decayTime))
        if (fadedAmplitude < 0.25) {
            //Stop animation when it fades away
            currentDisplayLink = nil
        } else {
            squareOffset = fadedAmplitude * CGFloat(cos(2 * .pi * elapsedTime / Animation.period))
        }
        
        setNeedsLayout()
    }
    
    @IBAction func animate(_ sender: Any?) {
        currentDisplayLink = CADisplayLink(target: self, selector: #selector(step(_:)))
        currentDisplayLink?.add(to: .current, forMode: .defaultRunLoopMode)
    }
}
