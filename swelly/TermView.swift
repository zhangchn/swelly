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
    
    private var x: Int = 0
    
    private var y: Int = 0
    
    private var connection: Connection?
    
    private var singleAdvance: [CGSize]!
    private var doubleAdvance: [CGSize]!
    
    //var asciiArtRender
    
    override init(frame: NSRect) {
        let config = GlobalConfig.sharedInstance
        fontWidth = config.cellWidth
        fontHeight = config.cellHeight
        maxRow = config.row
        maxColumn = config.column
        super.init(frame: frame)
        
        self.configure()
        // TODO: Register KVO

    }
    
    required init?(coder: NSCoder) {
        let config = GlobalConfig.sharedInstance
        fontWidth = config.cellWidth
        fontHeight = config.cellHeight
        maxRow = config.row
        maxColumn = config.column
        super.init(coder: coder)
        self.configure()
    }
    
    func updateBackedImage() {
        backedImage?.lockFocus()
        let context = NSGraphicsContext.current()?.cgContext
        if let ds = frontMostTerminal {
            for y in 0 ..< maxRow {
                for var x in 0..<maxColumn {
                    if ds.isDirty(atRow: y, column: x) {
                        let start = x
                        while x < maxColumn && ds.isDirty(atRow: y, column: x) {
                            x += 1
                        }
                        updateBackground(row: y, from: start, to: x)
                    }
                }
            }
            context?.saveGState()
            context?.setShouldSmoothFonts(GlobalConfig.sharedInstance.shouldSmoothFonts)
            for y in 0..<maxRow {
                drawString(row: y, context: context)
            }
            context?.restoreGState()
            ds.removeAllDirtyMarks()
        } else {
            NSColor.clear.set()
            context?.fill(CGRect(x: 0, y: 0, width: CGFloat(maxColumn) * fontWidth, height: CGFloat(maxRow) * fontHeight))
        }
        backedImage?.unlockFocus()
    }
    
    var backedImage: NSImage?
    static var gLeftImage: NSImage!
    func configure() {
        let gConfig = GlobalConfig.sharedInstance
        self.setFrameSize(gConfig.contentSize)
        if let _ = backedImage {} else {
            backedImage = NSImage(size: gConfig.contentSize)
        }
        TermView.gLeftImage = NSImage(size: NSSize(width: fontWidth, height: fontHeight))
        singleAdvance = [CGSize](repeating: CGSize(width: fontWidth, height: 0), count: maxColumn)
        doubleAdvance = [CGSize](repeating: CGSize(width: fontWidth * 2.0, height: 0), count: maxColumn)
        // TODO: configure ascii art
    }
    
    
    var frontMostTerminal: Terminal? { get { return connection?.terminal} }
    
    var frontMostConnection: Connection? { get {return connection}}
    
    var connected: Bool { get {
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
    private func drawString(row: Int, context: CGContext?) {
        // first dirty position
        guard let ds = frontMostTerminal else {
            return
        }
        var start = -1
        for x in 0..<maxColumn {
            if ds.isDirty(atRow: row, column: x) {
                start = x
                break
            }
        }
        guard start > -1 else {
            return
        }
        let config = GlobalConfig.sharedInstance
        let ePaddingBottom = config.englishFontPaddingBottom
        let ePaddingLeft = config.englishFontPaddingLeft
        let eCTFont = config.englishFont
        let cPaddingBottom = config.chineseFontPaddingBottom
        let cPaddingLeft = config.chineseFontPaddingLeft
        let cCTFont = config.chineseFont
        var end = start
        var buffer = [(Bool, Bool, unichar, Int, CGPoint)]()
        var textBytes = Data()
        for x in start..<maxRow {
            if !ds.isDirty(atRow: row, column: x) {
                continue
            }
            ds.withCells(ofRow: row) { (cells) in
                switch cells[x].attribute.doubleByte {
                case 0:
                    let isDouble = false
                    let isDoubleColor = false
                    let text = cells[x].byte > 0 ? unichar(cells[x].byte) : " ".utf16.first!
                    let index = x
                    let position = CGPoint(x: CGFloat(x) * fontWidth + ePaddingLeft, y: CGFloat(maxRow - 1 - row) * fontHeight + CTFontGetDescent(eCTFont!) + ePaddingBottom)
                    buffer.append((isDouble, isDoubleColor, text, index, position))
                    textBytes.append(cells[x].byte > 0 ? cells[x].byte : " ".utf8.first!)
                case 1:
                    break
                case 2:
                    let code = (unichar(cells[x - 1].byte) << 8) + unichar(unichar(cells[x].byte)) - 0x8000
                    let ch = encodeToUnicode(code, from: frontMostConnection!.site.encoding)
                    // TODO: if isAsciiArtSymbol
                    // else:
                    let isDouble = true
                    let isDoubleColor = (fgColorIndexOfAttribute(cells[x - 1].attribute) != fgColorIndexOfAttribute(cells[x].attribute) ||
                        fgBoldOfAttribute(cells[x - 1].attribute) != fgBoldOfAttribute(cells[x].attribute))
                    
                    let text = ch
                    
                    let index = x
                    let position = CGPoint(x: CGFloat(x - 1) * fontWidth + cPaddingLeft, y: CGFloat(maxRow - 1 - row) * fontHeight + CTFontGetDescent(cCTFont!) + cPaddingBottom)
                    buffer.append((isDouble, isDoubleColor, text, index, position))
                    if x == start {
                        setNeedsDisplay(NSRect(x: CGFloat(x - 1) * fontWidth, y: CGFloat(maxRow - 1 - row) * fontHeight, width: fontWidth, height: fontHeight))
                    }
                    textBytes.append(cells[x-1].byte)
                    textBytes.append(cells[x].byte)
                default:
                    NSLog("invalid doubleByte")
                    break
                }
            }
        }
        
        let mutableAttributedString = NSMutableAttributedString(string: String(data: textBytes, encoding: frontMostConnection!.site.encoding.stringEncoding())!)
        // split by attribute
        ds.withCells(ofRow: row) { (cells) in
            for var c in 0..<(buffer.count) {
                let loc = c
                let db = buffer[c].0
                let lastAttr = cells[buffer[c].3].attribute
                while c < buffer.count {
                    if cells[buffer[c].3].attribute != lastAttr || buffer[c].0 != db {
                        break
                    }
                    c += 1
                }
                let length = c - loc
                let i = fgBoldOfAttribute(lastAttr) ? 1: 0
                let j = Int(fgColorIndexOfAttribute(lastAttr))
                let range = NSMakeRange(loc, length)
                if db {
                    mutableAttributedString.addAttributes(config.cCTAttribute![i][j], range: range)
                } else {
                    mutableAttributedString.addAttributes(config.cCTAttribute![i][j], range: range)
                }
            }
        }
        
        let line = CTLineCreateWithAttributedString(mutableAttributedString as CFMutableAttributedString)
        let glyphCount = CTLineGetGlyphCount(line)

        guard glyphCount > 0 {
            return
        }
        
        
        
    }

    func refreshDisplay() {
        frontMostTerminal?.setAllDirty()
        updateBackedImage()
        needsDisplay = true
    }
    
    func refreshHiddenRegion () {
        
    }
    private func tick() {
        updateBackedImage()
        if let ds = frontMostTerminal {
            if x != ds.cursorColumn || y != ds.cursorRow {
                setNeedsDisplay(NSRect(x: CGFloat(x) * fontWidth , y: CGFloat(maxRow - 1 - y) *  fontHeight, width: fontWidth, height: fontHeight))
                setNeedsDisplay(NSRect(x: CGFloat(ds.cursorColumn) * fontWidth, y: CGFloat(maxRow - 1 - ds.cursorRow) * fontHeight, width: fontWidth, height: fontHeight))
                x = ds.cursorColumn
                y = ds.cursorRow
            }
        }
        
    }
    
    override func draw(_ dirtyRect: NSRect) {
        GlobalConfig.sharedInstance.colorBG.set()
        NSRectFill(bounds)
        if connected {
            // Draw the backed image
            var imgRect = dirtyRect
            imgRect.origin.y = fontHeight * CGFloat(maxRow) - dirtyRect.origin.y - dirtyRect.size.height
            backedImage?.draw(at: dirtyRect.origin, from: dirtyRect, operation: .copy, fraction: 1.0)
            // TODO:
            drawBlink()
            // Draw the url underline
            NSColor.orange.set()
            NSBezierPath.setDefaultLineWidth(1.0)
            for r in 0..<maxRow {
                frontMostTerminal?.withCells(ofRow: r) { (cells) in
                    for var c in 0..<maxColumn {
                        let start = c
                        while c < maxColumn && cells[c].attribute.url {
                            c += 1
                        }
                        if c != start {
                            NSBezierPath.strokeLine(from: NSPoint(x:CGFloat(start) * fontWidth, y: CGFloat(maxRow - r - 1)*fontHeight + 0.5), to: NSPoint(x:CGFloat(c) * fontWidth, y: CGFloat(maxRow - r - 1)*fontHeight + 0.5))
                        }
                    }
                    
                }
            }
            // Draw the cursor
            NSColor.white.set()
            NSBezierPath.setDefaultLineWidth(2.0)
            if let ds = frontMostTerminal {
                NSBezierPath.strokeLine(from: NSPoint(x:CGFloat(ds.cursorColumn) * fontWidth, y: CGFloat(maxRow - ds.cursorRow - 1)*fontHeight + 1), to: NSPoint(x:CGFloat(ds.cursorColumn + 1) * fontWidth, y: CGFloat(maxRow - ds.cursorRow - 1)*fontHeight + 1))
                x = ds.cursorColumn
                y = ds.cursorRow
            }
            NSBezierPath.setDefaultLineWidth(1.0)
            
        }
    }
    
    func terminalDidUpdate(_ terminal: Terminal!) {
        if let f = self.frontMostTerminal {
            if f === terminal {
                tick()
            }
        }
    }
}
