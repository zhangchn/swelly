//
//  MarkedTextView.swift
//  swelly
//
//  Created by ZhangChen on 07/02/2017.
//
//

import Foundation
import Cocoa

class MarkedTextView: NSView {
    var string : NSAttributedString? {
        didSet {
            needsDisplay = true
            if let string = string {
                
                let line = CTLineCreateWithAttributedString(string)
                let w = CTLineGetTypographicBounds(line, nil, nil, nil)
                var size = frame.size
                size.width = CGFloat(w) + 12
                size.height = lineHeight + 8 + 5
                setFrameSize(size)
            }
        }
    }
    var markedRange = NSRange(location: 0, length: 0) {
        didSet {
            needsDisplay = true
        }
    }
    var selectedRange = NSRange(location: 0, length: 0) {
        didSet {
            needsDisplay = true
        }
    }
    
    fileprivate var lineHeight = CGFloat(0)
    var defaultFont: NSFont {
        didSet {
            lineHeight = NSLayoutManager().defaultLineHeight(for: defaultFont)
            needsDisplay = true
        }
    }
    
    var destination: NSPoint = .zero
    
    override init(frame frameRect: NSRect) {
        defaultFont = NSFont(name: "Lucida Grande", size: 20)!
        lineHeight = NSLayoutManager().defaultLineHeight(for: defaultFont)
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        defaultFont = NSFont(name: "Lucida Grande", size: 20)!
        lineHeight = NSLayoutManager().defaultLineHeight(for: defaultFont)
        super.init(coder: coder)
    }
    
    override var isOpaque: Bool {
        return false
    }
    
    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current()?.cgContext else {
            return
        }
        context.saveGState()
        let half = frame.height / 2.0
        let fromTop = destination.y > half
        
        context.translateBy(x: 1.0, y: 1.0)
        if !fromTop {
            context.translateBy(x: 0, y: 5)
        }
        var dest = NSPointToCGPoint(destination)
        dest.x -= 1.0
        dest.y -= 1.0
        
        if !fromTop { dest.y -= 5.0 }
        
        context.saveGState()
        let ovalSize = CGFloat(6.0)
        
        context.translateBy(x: 1.0, y: 1.0)
        let fw = bounds.width - 3
        let fh = bounds.height - 3 - 5
        
        context.beginPath()
        context.move(to: CGPoint(x: 0, y: fh - ovalSize))
        context.addArc(tangent1End: CGPoint(x: 0, y: fh), tangent2End: CGPoint(x: ovalSize, y: fh), radius: ovalSize)
        if fromTop {
            var left = dest.x - 2.5
            var right = left + 5.0
            if left < ovalSize {
                left = ovalSize
                right = left + 5.0
            } else if right > fh - ovalSize {
                right = fw - ovalSize
                left = right - 5.0
            }
            
            context.addLine(to: CGPoint(x: left, y: fh))
            context.addLine(to: dest)
            context.addLine(to: CGPoint(x: right, y: fh))
        }
        context.addArc(tangent1End: CGPoint(x: fw, y: fh), tangent2End: CGPoint(x: fw, y: fh - ovalSize), radius: ovalSize)
        context.addArc(tangent1End: CGPoint(x: fw, y: 0), tangent2End: CGPoint(x: fw - ovalSize, y: 0), radius: ovalSize)
        
        if !fromTop {
            var left = dest.x - 2.5
            var right = left + 5.0
            if left < ovalSize {
                left = ovalSize
                right = left + 5.0
            } else if right > fh - ovalSize {
                right = fw - ovalSize
                left = right - 5.0
            }
            
            context.addLine(to: CGPoint(x: right, y: 0))
            context.addLine(to: dest)
            context.addLine(to: CGPoint(x: left, y: 0))
        }
        context.addArc(tangent1End: CGPoint(x: 0, y: 0), tangent2End: CGPoint(x: 0, y: ovalSize), radius: ovalSize)
        context.closePath()
        context.setFillColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
        context.setLineWidth(2.0)
        context.setStrokeColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        context.drawPath(using: .fillStroke)
        
        context.restoreGState()
        if let string = string {
            context.translateBy(x: 4.0, y: 3.0)
            string.draw(at: .zero)
            let line = CTLineCreateWithAttributedString(string)
            let offset = CTLineGetOffsetForStringIndex(line, selectedRange.location, nil)
            NSColor.white.set()
            NSBezierPath.strokeLine(from: NSPoint(x: offset, y: 0), to: NSPoint(x:offset, y:lineHeight))
        }
        context.restoreGState()
    }
}
