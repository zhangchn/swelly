//
//  TermView.swift
//  swelly
//
//  Created by ZhangChen on 06/10/2016.
//
//

import AppKit

class TermView: NSView {
    var fontWidth: CGFloat
    
    var fontHeight: CoreGraphics.CGFloat
    
    var maxRow: Int
    
    var maxColumn: Int
    
    private var connection: Connection?
    //var asciiArtRender
    
    override init(frame: NSRect) {
        
        super.init(frame: frame)
        self.configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configure()
    }
    
    func updateBackedImage() {}
    
    var backedImage: NSImage?
    
    func configure() {
        let gConfig = GlobalConfig.sharedInstance
        maxColumn = gConfig.column
        maxRow = gConfig.row
        fontWidth = gConfig.cellWidth
        fontHeight = gConfig.cellHeight
        self.setFrameSize(gConfig.contentSize)
        if let _ = backedImage {} else {
            backedImage = NSImage(size: gConfig.contentSize)
        }
    }
    
    
    var frontMostTerminal: Terminal? { get { return connection?.terminal} }
    
    var frontMostConnection: Connection? { get {return connection}}
    
    var isConnected: Bool { get {
        guard self.connection != nil else {return false}
        return self.connection!.connected
        }
    }
    
    private func draw(specialSymbol: UTF16Char, row: Int, column: Int) {
        
    }
    
    private func updateBackground(row:Int, from start:Int, to end: Int) {
        
    }
    private func drawBlink() {
        
    }
    private func drawString(row: Int, context: CGContext) {
        
    }
    private func tick() {
        
    }
    func refreshDisplay() {}
    
    func terminalDidUpdate(_ terminal: Terminal!) {
        
    }
}
