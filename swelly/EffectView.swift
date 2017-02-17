//
//  EffectView.swift
//  swelly
//
//  Created by ZhangChen on 16/02/2017.
//
//

import Cocoa
import QuartzCore.CoreAnimation

public var DEFAULT_POPUP_BOX_FONT: String { return "Helvetica" }
public var DEFAULT_POPUP_MENU_FONT: String { return "Lucida Grande" }

class WLEffectView : NSView {
    
    @IBOutlet var mainView: TermView!
    
    lazy var mainLayer: CALayer = {
        let layer = CALayer()
        // Make the background color to be a dark gray with a 50% alpha similar to
        // the real Dashbaord.
        let bgColor = NSColor.black.cgColor
        layer.backgroundColor = bgColor
        return layer
    }()
    var ipAddrLayer: CALayer!
    var clickEntryLayer: CALayer!
    var popUpLayer: CALayer!
    var buttonLayer: CALayer!
    var urlLineLayer: CALayer!
    var urlIndicatorImage: CGImage!
    var selectedItemIndex: Int!
    var popUpLayerTextColor: CGColor!
    var popUpLayerTextFont: CGFont!
    /*
     */

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
    }
    
    init(view: NSView) {
        super.init(frame: view.frame)
        wantsLayer = true
    }
    
    deinit {
        buttonLayer.removeFromSuperlayer()
    }
    
    override func awakeFromNib() {
        setupLayer()
    }
    
    // for ip seeker
    func drawIPAddrBox(_ rect: NSRect) {
        
    }
    
    func clearIPAddrBox() {
        
    }
    
    
    // for post view
    func drawClickEntry(_ rect: NSRect) {
        
    }
    
    func clearClickEntry() {
        
    }
    
    
    // for button
    func drawButton(_ rect: NSRect, withMessage message: String!) {
        
    }
    
    func clearButton() {
        
    }
    
    
    // for URL
    func showIndicator(at point: NSPoint) {
        
    }
    
    func removeIndicator() {
        
    }
    
    
    // To show pop up message by core animation
    // This method might be changed in future
    // by gtCarrera @ 9#
    func drawPopUpMessage(_ message: String!) {
        
    }
    
    func removePopUpMessage() {
        
    }
    
    
    func resize() {
        setFrameSize(mainView.frame.size)
        setFrameOrigin(.zero)
    }
    
    func clear() {
        clearIPAddrBox()
        clearClickEntry()
        clearButton()
    }
    
    func setupLayer() {
        frame = mainView.frame
        mainLayer.frame = frame
    }
}
