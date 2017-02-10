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
    
    var connection: Connection? {
        didSet {
            refreshDisplay()
        }
    }
    
    private var singleAdvance: [CGSize]!
    private var doubleAdvance: [CGSize]!
    
    var selectionLength = 0
    var selectionLocation = 0
    var inUrlMode = false
    var isKeying = false
    var isNotCancelingSelection = true
    var mouseActive = true
    var hasRectangleSelected = false
    var wantsRectangleSelection = false
    
    var selectionRange = Range(uncheckedBounds: (lower: 0, upper: 0))
    // TODO: mouse behavior
//    var mouseBehaviorDelegate: MouseBehaviorManager!
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

        // TODO: mouse behavior
        // mouseBehaviorDelegate = [[WLMouseBehaviorManager alloc] initWithView:self];
        // TODO: url managers
        // urlManager = [[WLURLManager alloc] initWithView:self];

        // TODO: 		[_mouseBehaviorDelegate addHandler:_urlManager];
        // TODO: _activityCheckingTimer
        // TODO: notification: WLNotificationSiteDidChangeShouldEnableMouse
        // TODO: notification: WLNotificationSiteDidChangeEncoding
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
        backedImage.lockFocus()
        let context = NSGraphicsContext.current()?.cgContext
        if let ds = frontMostTerminal {
            for y in 0 ..< maxRow {
                var x = 0
                while x < maxColumn {
                    if ds.isDirty(atRow: y, column: x) {
                        let start = x
                        while x < maxColumn && ds.isDirty(atRow: y, column: x) {
                            x += 1
                        }
                        updateBackground(row: y, from: start, to: x)
                    }
                    x += 1
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
        backedImage.unlockFocus()
    }
    
    lazy var backedImage = NSImage(size: GlobalConfig.sharedInstance.contentSize)

    static var gLeftImage: NSImage!
    func configure() {
        let gConfig = GlobalConfig.sharedInstance
        self.setFrameSize(gConfig.contentSize)
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
        // TODO: asciiartrender
    }
    
    private func updateBackground(row: Int, from start: Int, to end: Int) {
        guard let ds = frontMostTerminal else {return }
        ds.withCells(ofRow: row) { cells in
            let rowRect = NSMakeRect(CGFloat(start) * fontWidth, CGFloat(maxRow - 1 - row) * fontHeight, CGFloat(end - start) * fontWidth, fontHeight)
            var lastAttr = cells[start].attribute
            var length = 0
            var currAttr : Cell.Attribute!
            var currentBackgroundColor = UInt8(0)
            var currentBold = false
            var lastBackgroundColor = bgColorIndexOfAttribute(lastAttr)
            var lastBold = bgBoldOfAttribute(lastAttr)
            for c in start...end {
                if c < end {
                    currAttr = cells[c].attribute
                    currentBackgroundColor = bgColorIndexOfAttribute(currAttr)
                    currentBold = bgBoldOfAttribute(currAttr)
                }
                if (currentBackgroundColor != lastBackgroundColor || currentBold != lastBold || c == end) {
                    let rect = NSMakeRect(CGFloat(c - length) * fontWidth, CGFloat(maxRow - 1 - row) * fontHeight, fontWidth * CGFloat(length), fontHeight)
                    // Modified by K.O.ed: All background color use same alpha setting.
                    let bgColor = GlobalConfig.sharedInstance.bgColor(atIndex: Int(lastBackgroundColor), highlight: lastBold)
                    bgColor.set()
                    NSRectFill(rect)
                    /* finish this segment */
                    length = 1
                    lastAttr = currAttr
                    lastBackgroundColor = currentBackgroundColor
                    lastBold = currentBold
                } else {
                    length += 1
                }
            }
            setNeedsDisplay(rowRect)
        }
        
    }
    
//    override func setNeedsDisplay(_ invalidRect: NSRect) {
//        super.setNeedsDisplay(invalidRect)
//        debugPrint("setNeedsDisplay:\(invalidRect)")
//    }
    private func drawBlink() {
        let config = GlobalConfig.sharedInstance
        if !config.blinkTicker {
            return
        }
        guard let ds = frontMostTerminal else {
            return
        }
        
        for r in 0..<maxRow {
            ds.withCells(ofRow: r) { cells in
                for c in 0..<maxColumn {
                    let cell = cells[c]
                    if isBlinkCell(cell) {
                        let bgColorIndex = cell.attribute.reverse ? cell.attribute.fgColor : cell.attribute.bgColor
                        let bold = cell.attribute.reverse ? cell.attribute.bold : false
                        let bgColor = config.bgColor(atIndex: Int(bgColorIndex), highlight: bold)
                        bgColor.set()
                        NSRectFill(NSMakeRect(CGFloat(c) * fontWidth, CGFloat(maxRow - r - 1) * fontHeight, fontWidth, fontHeight))
                    }
                }
            }
        }
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
        let siteEncoding = frontMostConnection!.site.encoding
        var end = start
        var buffer = [(Bool, Bool, unichar, Int)]()
        var textBytes = Data()
        var positions = [CGPoint]()
        ds.withCells(ofRow: row) { (cells) in
            for x in start..<maxColumn {
                if !ds.isDirty(atRow: row, column: x) {
                    continue
                }
                end = x
                switch cells[x].attribute.doubleByte {
                case 0:
                    let isDouble = false
                    let isDoubleColor = false
                    let text = cells[x].byte > 0 ? unichar(cells[x].byte) : " ".utf16.first!
                    let index = x
                    let position = CGPoint(x: CGFloat(x) * fontWidth + ePaddingLeft, y: CGFloat(maxRow - 1 - row) * fontHeight + CTFontGetDescent(eCTFont!) + ePaddingBottom)
                    buffer.append((isDouble, isDoubleColor, text, index))
                    positions.append(position)
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
                    
                    //let text = ch
                    
                    let index = x
                    let position = CGPoint(x: CGFloat(x - 1) * fontWidth + cPaddingLeft, y: CGFloat(maxRow - 1 - row) * fontHeight + CTFontGetDescent(cCTFont!) + cPaddingBottom)
                    
                    if siteEncoding == .gbk {
                        if cells[x-1].byte < 0x81 ||
                            cells[x-1].byte > 0xfe ||
                            cells[x].byte < 0x40 ||
                            cells[x].byte > 0xfe {
                            // XXX: might be a split glyph
                            Swift.print("invalid gbk: \(cells[x-1].byte) \(cells[x].byte) at: \(row) \(x)")
                        } else {
                            textBytes.append(cells[x-1].byte)
                            textBytes.append(cells[x].byte)
                            buffer.append((isDouble, isDoubleColor, ch, index))
                            positions.append(position)
                        }
                    } else {
                        // TODO: Big-5?
                        textBytes.append(cells[x-1].byte)
                        textBytes.append(cells[x].byte)
                        buffer.append((isDouble, isDoubleColor, ch, index))
                        positions.append(position)
                    }
                    
                    if x == start {
                        setNeedsDisplay(NSRect(x: CGFloat(x - 1) * fontWidth, y: CGFloat(maxRow - 1 - row) * fontHeight, width: fontWidth, height: fontHeight))
                    }

                    
                default:
                    NSLog("invalid doubleByte")
                    break
                }
            }
        }
        // sentinel
        buffer.append((false, false, unichar(0), -1))
        let string = String(data: textBytes,
                            encoding: siteEncoding.stringEncoding)!
        let mutableAttributedString = NSMutableAttributedString(string: string)
        // split by attribute
        ds.withCells(ofRow: row) { (cells) in
            var c = 0
            while c < buffer.count - 1 {
                let loc = c
                let db = buffer[c].0
                var index = buffer[c].3
                
                let lastAttr = cells[index].attribute
                while c < buffer.count - 1{
                    index = buffer[c].3
                    if index < 0 || cells[index].attribute != lastAttr || buffer[c].0 != db {
                        break
                    }
                    c += 1
                }
                

                let length = c - loc
                let i = fgBoldOfAttribute(lastAttr) ? 1: 0
                let j = Int(fgColorIndexOfAttribute(lastAttr))
                let range = NSMakeRange(loc, length)
                if db {
                    mutableAttributedString.addAttributes(config.cCTAttribute[i][j], range: range)
                } else {
                    mutableAttributedString.addAttributes(config.eCTAttribute[i][j], range: range)
                }
            }
            let line = CTLineCreateWithAttributedString(mutableAttributedString as CFMutableAttributedString)
            let glyphCount = CTLineGetGlyphCount(line)
            
            guard glyphCount > 0 else {
                return
            }
            
            let runArray = CTLineGetGlyphRuns(line) as! [CTRun]
            
            let runCount = runArray.count
            var glyphOffset = 0
            let showsHidden = config.showHiddenText
            
            if let context = context {
                
                for runIndex in 0 ..< runCount {
                    let run = runArray[runIndex]
                    let runGlyphCount = CTRunGetGlyphCount(run)
                    // index of glyph in current run
                    //var runGlyphIndex = 0
                    
                    let attrDict = CTRunGetAttributes(run) as Dictionary
                    let runFont = attrDict[kCTFontAttributeName] as! CTFont
                    let cgFont = CTFontCopyGraphicsFont(runFont, nil)
                    let runColor = (attrDict[kCTForegroundColorAttributeName] as? NSColor) ?? NSColor.red
                    
                    context.setFont(cgFont)
                    context.setFontSize(CTFontGetSize(runFont))
                    context.setFillColor(red: runColor.redComponent, green: runColor.greenComponent, blue: runColor.blueComponent, alpha: 1.0)
                    context.setLineWidth(1.0)
                    
                    var location = 0
                    var lastIndex = buffer[glyphOffset].3
                    var hidden = isHiddenAttribute(cells[lastIndex].attribute)
                    var lastDoubleByte = buffer[glyphOffset].0
                    
                    for runGlyphIndex in 0...runGlyphCount {
                        
                        let index = buffer[glyphOffset + runGlyphIndex].3
                        let isHidden = index >= 0 ? isHiddenAttribute(cells[index].attribute) : false
                        if runGlyphIndex == runGlyphCount
                            || ((showsHidden && isHidden) != hidden)
                            || (buffer[runGlyphIndex + glyphOffset].0 && index != lastIndex + 2)
                            || (!buffer[runGlyphIndex + glyphOffset].0 && index != lastIndex + 1)
                            || (buffer[runGlyphIndex + glyphOffset].0 != lastDoubleByte) {
                            lastDoubleByte = buffer[runGlyphIndex + glyphOffset].0
                            
                            let len = runGlyphIndex - location
                            let drawingMode : CGTextDrawingMode = showsHidden && hidden ? .stroke : .fill;
                            
                            context.setTextDrawingMode(drawingMode)
                            var glyphs = [CGGlyph](repeating: CGGlyph(0), count:len)
                            let glyphRange = CFRangeMake(location, len)
                            CTRunGetGlyphs(run, glyphRange, &glyphs)
                            context.showGlyphs(glyphs, at: Array(positions[(glyphOffset + location)..<(glyphOffset + runGlyphIndex)]))
                            location = runGlyphIndex
                            if runGlyphIndex != runGlyphCount {
                                hidden = isHiddenAttribute(cells[index].attribute)
                            }
                        }
                        lastIndex = index
                    }
                    for runGlyphIndex in 0 ... runGlyphCount {
                        if buffer[glyphOffset + runGlyphIndex].1 {
                            let range = CFRangeMake(runGlyphIndex, 1)
                            var glyph = CGGlyph()
                            CTRunGetGlyphs(run, range, &glyph)
                            let index = buffer[glyphOffset + runGlyphIndex].3
                            let bgColor = bgColorIndexOfAttribute(cells[index].attribute)
                            let fgColor = fgColorIndexOfAttribute(cells[index].attribute)
                            
                            TermView.gLeftImage.lockFocus()
                            config.bgColor(atIndex: Int(bgColor), highlight: bgBoldOfAttribute(cells[index].attribute)).set()
                            let rect = NSRect(origin: NSZeroPoint, size: TermView.gLeftImage.size)
                            NSRectFill(rect)
                            if let tempContext = NSGraphicsContext.current()?.cgContext {
                                tempContext.setShouldSmoothFonts(config.shouldSmoothFonts)
                                let tempColor = config.color(atIndex: Int(fgColor), highlight: fgBoldOfAttribute(cells[index].attribute))
                                tempContext.setFont(cgFont)
                                tempContext.setFontSize(CTFontGetSize(runFont))
                                tempContext.setFillColor(red: tempColor.redComponent, green: tempColor.greenComponent, blue: tempColor.blueComponent, alpha: 1.0)
                                let glyphPosition = CGPoint(x: cPaddingLeft, y: CTFontGetDescent(cCTFont!) + cPaddingBottom)
                                tempContext.showGlyphs([glyph], at: [glyphPosition])
                                TermView.gLeftImage.unlockFocus()
                                TermView.gLeftImage.draw(at: NSPoint(x:CGFloat(index) * fontWidth,
                                                                     y: CGFloat(maxRow - 1 - row) * fontHeight),
                                                         from: rect,
                                                         operation: .copy,
                                                         fraction: 1.0);
                            
                            }
                        }
                    }
                    glyphOffset += runGlyphCount
                }
                
            }
            for var x in start...end {
                if cells[x].attribute.underline {
                    let beginColor = cells[x].attribute.reverse ? cells[x].attribute.bgColor : cells[x].attribute.fgColor
                    let beginBold = !cells[x].attribute.reverse && cells[x].attribute.bold
                    let begin = x;
                    while x <= end {
                        let currentColor = cells[x].attribute.reverse ? cells[x].attribute.bgColor : cells[x].attribute.fgColor
                        let currentBold = !cells[x].attribute.reverse && cells[x].attribute.bold
                        if (!cells[x].attribute.underline || currentColor != beginColor || currentBold != beginBold) {
                            break
                        }
                        x += 1
                    }
                    config.color(atIndex: Int(beginColor), highlight: beginBold).set()
                    NSBezierPath.strokeLine(from: NSPoint(x: CGFloat(begin) * fontWidth, y: CGFloat(maxRow - 1 - row) * fontHeight + 0.5),
                                            to: NSPoint(x: CGFloat(x) * fontWidth, y: CGFloat(maxRow - 1 - row) * fontHeight + 0.5))
                    x -= 1
                }
            }
        }
        
       
    }

    func refreshDisplay() {
        frontMostTerminal?.setAllDirty()
        updateBackedImage()
        needsDisplay = true
    }
    
    func refreshHiddenRegion () {
        
    }
    fileprivate func tick() {
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
            backedImage.draw(at: dirtyRect.origin, from: dirtyRect, operation: .copy, fraction: 1.0)
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
         
            if connected && selectionLength != 0 {
                drawSelection()
            }
        }
    }
    
    func terminalDidUpdate(_ terminal: Terminal!) {
        if let f = self.frontMostTerminal {
            if f === terminal {
                tick()
            }
        }
    }
    
    // MARK:
    override var isFlipped: Bool { get { return false }}
    override var isOpaque: Bool { get { return true }}
    override var acceptsFirstResponder: Bool { get { return true }}
    override var canBecomeKeyView: Bool { get {return true}}
    override class func defaultMenu() -> NSMenu? {
        return NSMenu()
    }
    override func hitTest(_ point: NSPoint) -> NSView? {
        return self
    }
    override func resetCursorRects() {
        super.resetCursorRects()
        // TODO: refreshMouseHotspot
    }
    override func viewDidMoveToWindow() {
        self.refreshDisplay()
        // TODO: refreshMouseHotspot()
    }
    
    override var frame: NSRect {
        didSet {
            // TODO:
//            effectiveView.resize()
        }
    }
    
    @IBOutlet var textField: MarkedTextView!
    var markedText: NSAttributedString?
    var _selectedRange: NSRange = NSMakeRange(0, 0)
    var _markedRange: NSRange = NSMakeRange(0, 0)
}

extension TermView: NSTextInputClient {
    func insert(text: Any, delay microsecond: Int) {
        guard frontMostTerminal != nil && frontMostConnection!.connected else {
            return
        }
        textField.isHidden = true
        markedText = nil
        frontMostConnection?.send(text: text as! String, delay: microsecond)
    }
    override func doCommand(by selector: Selector) {
        let leftSquare = "[".utf8.first!
        let tilde = "~".utf8.first!
        switch selector {
        case #selector(NSResponder.insertNewline(_:)):
            frontMostConnection?.sendMessage(msg: Data([0x0d]))
        case #selector(NSResponder.cancelOperation(_:)):
            frontMostConnection?.sendMessage(msg: Data([0x1b]))
        case #selector(NSResponder.scrollToBeginningOfDocument(_:)), #selector(NSResponder.moveToBeginningOfLine(_:)):
            frontMostConnection?.sendMessage(msg: Data([0x1b, leftSquare, 0x31, tilde]))
        case #selector(NSResponder.scrollToEndOfDocument(_:)), #selector(NSResponder.moveToEndOfLine(_:)):
            frontMostConnection?.sendMessage(msg: Data([0x1b, leftSquare, 0x34, tilde]))
        case #selector(NSResponder.scrollPageUp(_:)), #selector(NSResponder.pageUp(_:)):
            frontMostConnection?.sendMessage(msg: Data([0x1b, leftSquare, 0x35, tilde]))
        case #selector(NSResponder.scrollPageDown(_:)), #selector(NSResponder.pageDown(_:)):
            frontMostConnection?.sendMessage(msg: Data([0x1b, leftSquare, 0x36, tilde]))
        case #selector(NSResponder.insertTab(_:)):
            frontMostConnection?.sendMessage(msg: Data([0x09]))
        case #selector(NSResponder.deleteForward(_:)):
            if let ds = frontMostTerminal {
                var d = Data([0x1b, leftSquare, 0x33, tilde])
                if frontMostConnection?.site.shouldDetectDoubleByte ?? false && ds.cursorColumn < maxColumn - 1 && ds.attribute(atRow: ds.cursorRow, column: ds.cursorColumn + 1).doubleByte == 2 {
                    d.append(d)
                }
                frontMostConnection?.sendMessage(msg: d)
            }
        case #selector(NSResponder.insertTabIgnoringFieldEditor(_:)):
            switchURL()
        default:
            NSLog("Unprocessed selector: \(selector)")
        }
    }
    func send(text: String) {
        clearSelection()
        frontMostConnection?.send(text: text)
    }
    var conversationIdentifier: Int {
        get { return self.hash }
    }
    func insertText(_ string: Any, replacementRange: NSRange) {
        insert(text: string, delay: 0)
    }
    func setMarkedText(_ string: Any, selectedRange: NSRange, replacementRange: NSRange) {
        var attrString : NSAttributedString
        if let aString = string as? NSAttributedString {
            attrString = aString
        } else {
            attrString = NSAttributedString(string: string as! String)
        }
        
        guard !attrString.string.isEmpty else {
            unmarkText()
            return
        }
        
        guard let ds = frontMostTerminal else {
            return
        }
        
        if attrString !== markedText {
            markedText = attrString
        }
        _selectedRange = selectedRange
        _markedRange.location = 0
        _markedRange.length = attrString.length
        let mAttrString = NSMutableAttributedString(attributedString: attrString)
        mAttrString.addAttribute(NSFontAttributeName, value: textField.defaultFont, range: NSRange(location: 0, length: attrString.length))
        mAttrString.addAttribute(NSForegroundColorAttributeName, value: NSColor.white, range: NSRange(location: 0, length: attrString.length))
        
        textField.string = mAttrString
        textField.selectedRange = selectedRange
        textField.markedRange = _markedRange
        
        var o = NSPoint(x: CGFloat(ds.cursorColumn) * fontWidth, y: CGFloat(maxRow - 1 - ds.cursorRow) * fontHeight + 5.0)
        var dy: CGFloat
        if (o.x + textField.frame.width > CGFloat(maxColumn) * fontWidth) {
            o.x = CGFloat(maxColumn) * fontWidth - textField.frame.width
        }
        if (o.y + textField.frame.height > CGFloat(maxRow) * fontHeight) {
            o.y = (CGFloat(maxRow - ds.cursorRow)) * fontHeight - 5.0 - textField.frame.height
            dy = o.y + textField.frame.height
        } else {
            dy = o.y
        }
        textField.setFrameOrigin(o)
        textField.destination = textField.convert(NSPoint(x: (CGFloat(ds.cursorColumn) + 0.5) * fontWidth, y: dy), from: self)
        textField.isHidden = false
        
    }
    func unmarkText() {
        markedText = nil
        textField.isHidden = true
    }
    
    func hasMarkedText() -> Bool {
        return markedText != nil
    }
    
    func selectedRange() -> NSRange {
        return _selectedRange
    }
 
    func markedRange() -> NSRange {
        return _markedRange
    }
    
    func attributedSubstring(forProposedRange range: NSRange, actualRange: NSRangePointer?) -> NSAttributedString? {
        guard let markedText = markedText else {
            return nil
        }
        var range = range
        if (range.location >= markedText.length) {
            return nil
        }
        if (range.location + range.length > markedText.length){
            range.length = markedText.length - range.location
        }
        let substring = (markedText.string as NSString).substring(with: range)
        return NSAttributedString(string: substring)
    }
    
    func validAttributesForMarkedText() -> [String] {
        return []
    }
    
    func firstRect(forCharacterRange range: NSRange, actualRange: NSRangePointer?) -> NSRect {
        return textField.window!.convertToScreen(textField.frame)
    }
    
    func characterIndex(for point: NSPoint) -> Int {
        return 0
    }
}

extension TermView {
    // MARK: Event handling
    
    override func mouseDown(with event: NSEvent) {
        // TODO: reset mouse timer
        
        frontMostConnection?.resetMessageCount()
        self.window?.makeFirstResponder(self)
        guard connected else {
            return
        }
        if labs(selectionLength) > 0 {
            isNotCancelingSelection = false
        }
        let point = convert(event.locationInWindow, from: nil)
        selectionLocation = convertIndex(from: point)
        selectionLength = 0
        
    }
    
    override func mouseUp(with event: NSEvent) {
        // TODO:
        guard connected else {
            return
        }
        // open url
        if labs(selectionLength) <= 1 && isNotCancelingSelection && !isKeying && !inUrlMode {
            //[_mouseBehaviorDelegate mouseUp:theEvent];
        }
        isNotCancelingSelection = true
    }
    
    override func mouseMoved(with event: NSEvent) {
        // TODO:
    }
    
    override func mouseDragged(with event: NSEvent) {
        // TODO:
        if (!self.connected) {
            return;
        }
        
        let point = convert(event.locationInWindow, from:nil)
        let index = convertIndex(from: point)
        let oldValue = selectionLength
        selectionLength = index - selectionLocation + 1
        if selectionLength <= 0 {
            selectionLength -= 1
        }
        if oldValue != selectionLength {
            needsDisplay = true
        }
        hasRectangleSelected = wantsRectangleSelection;
    }
    
    func convertIndex(from point: NSPoint) -> Int {
        var point = point
        if point.x > CGFloat(maxColumn) * fontWidth {
            point.x = CGFloat(maxColumn) * fontWidth - 0.001
        }
        if point.y > CGFloat(maxRow) * fontHeight {
            point.y = CGFloat(maxRow) * fontHeight - 0.001
        }
        if point.x < 0 {
            point.x = 0
        }
        if point.y < 0 {
            point.y = 0
        }
        let cx = Int ( point.x / fontWidth)
        
        let cy = maxRow - Int(point.y / fontHeight) - 1
        return cy * maxColumn + cx
    }
}


extension TermView {
    // MARK: Actions
    @IBAction func copy(_ sender: Any){
        guard connected, selectionLength > 0 else  {
            return
        }
        
        let s = selectedPlainString ?? ""
        
        /* Color copy */
        var location: Int, length: Int
        if (selectionLength >= 0) {
            location = selectionLocation
            length = selectionLength
        } else {
            location = selectionLocation + selectionLength
            length = 0 - selectionLength
        }
        
        let pb = NSPasteboard.general()
        // TODO: ANSIColorPBoardType
        pb.declareTypes([NSStringPboardType], owner: self)
        pb.setString(s, forType: NSStringPboardType)
        
        if hasRectangleSelected {
            // TODO:
//            pb.setData(<#T##data: Data?##Data?#>, forType: ANSIColorPBoardType)
//            [pb setData:[WLAnsiColorOperationManager ansiColorDataFromTerminal:self.frontMostTerminal
//                inRect:[self selectedRect]]
//                forType:ANSIColorPBoardType];
        } else {
//            pb.setData(ANSIColorOperationManager.ansiColorData(from: frontMostTerminal!, atLocation: location, length: length), forType: ANSIPBoard)
//            [pb setData:[WLAnsiColorOperationManager ansiColorDataFromTerminal:self.frontMostTerminal
//																atLocation:location 
//                length:length] 
//                forType:ANSIColorPBoardType];
        }

    }
}

extension TermView {
    func confirmPaste(sheet: NSWindow, returnCode: Int, contextInfo: UnsafeRawPointer){
        if returnCode == NSAlertFirstButtonReturn {
            performPaste()
        }
    }
    func confirmPasteWrap( sheet: NSWindow, returnCode: Int, contextInfo: UnsafeRawPointer) {
        if returnCode == NSAlertFirstButtonReturn {
            performPasteWrap()
        }
    }
    
    func performPaste() {
        if let str = NSPasteboard.general().string(forType: NSStringPboardType) {
            insert(text: str, delay: 0)
        }
    }
    
    func performPasteWrap() {
        // TODO:
//        guard let str = NSPasteboard.general().string(forType: NSStringPboardType) else {return}
//        let lineWidth = 66
//        let lPadding = 4
//        
    }
    
    func drawSelection() {
        // TODO:
    }
    
}

extension TermView {
    // MARK: Url Menu
    func switchURL() {
        // TODO:
    }
    func exitURL() {
        
    }
}

extension TermView {
    // MARK: Active Timer
    func hasMouseActivity() {
        mouseActive = true
    }
    func checkActivity(timer: Timer) {
        if mouseActive {
            mouseActive = false
            return
        } else {
            // Hide the cursor
            NSCursor.setHiddenUntilMouseMoves(true)
            // TODO:
            // effectView.clear()
        }
    }
}

extension TermView {
    // MARK: Event handling
    func clearSelection() {
        // TODO:
    }
    
    override func scrollWheel(with event: NSEvent) {
        super.scrollWheel(with: event)
        hasMouseActivity()
    }
    
    override func swipe(with event: NSEvent) {
        if frontMostTerminal?.connection?.connected ?? false {
            if event.deltaY > 0 {
                frontMostConnection!.sendMessage(msg: termKeyPageUp)
                return
            } else if event.deltaY < 0 {
                frontMostConnection!.sendMessage(msg: termKeyPageDown)
                return
            }
        }
        super.swipe(with: event)
    }
    override func menu(for event: NSEvent) -> NSMenu? {
        if !connected {
            return nil
        }
        // TODO:
//        if let s = selectedPlainString() {
//            return WLContextualMenuManager.menu(selected: s)
//        } else {
//            mouseBehaviorDelegate.menu(event: event)
//        }
        
        return nil
    }
    override func keyDown(with event: NSEvent) {
        frontMostConnection?.resetMessageCount()
        if event.characters?.isEmpty ?? true {
            // dead key pressed
            return
        }
        guard let c = event.characters?.utf16.first else { return }
        switch Int(c) {
        case NSLeftArrowFunctionKey, NSUpArrowFunctionKey:
            // TODO: effectView.showIndicatorAtPoint(urlManager.movePrev())
            break
        case Int(WLTabCharacter), NSRightArrowFunctionKey, NSDownArrowFunctionKey:
            // TODO:
            break
        case Int(WLEscapeCharacter):
            exitURL()
            break
        case Int(WLWhitespaceCharacter), Int(WLReturnCharacter):
            // TODO:
            // if urlManager.openCurrentURL:event
            //    exitUrl()
            // else {
            //     effectView.showIndicator(at: urlManager.moveNext())
            break
        default:
            break
        }
        clearSelection()
        var arrow : [UInt8] = [0x1B, 0x4F, 0x00, 0x1B, 0x4F, 0x00]
        if let ds = frontMostTerminal {
            if event.modifierFlags.contains(.control) && !event.modifierFlags.contains(.option) {
                frontMostConnection?.sendMessage(msg: Data([UInt8(c)]))
                return
            }
            var isArrowKey = true
            switch Int(c) {
            case NSUpArrowFunctionKey:
                arrow[2] = "A".utf8.first!
                arrow[5] = "A".utf8.first!
            case NSDownArrowFunctionKey:
                arrow[2] = "B".utf8.first!
                arrow[5] = "B".utf8.first!
            case NSRightArrowFunctionKey:
                arrow[2] = "C".utf8.first!
                arrow[5] = "C".utf8.first!
            case NSLeftArrowFunctionKey:
                arrow[2] = "D".utf8.first!
                arrow[5] = "D".utf8.first!
            default:
                isArrowKey = false
                break
            }
           
            if !hasMarkedText() && isArrowKey {
                ds.updateDoubleByteState(for: ds.cursorRow)
                if Int(c) == NSRightArrowFunctionKey && ds.attribute(atRow: ds.cursorRow, column: ds.cursorColumn).doubleByte == 1
                || Int(c) == NSLeftArrowFunctionKey && ds.cursorColumn > 0 && ds.attribute(atRow: ds.cursorRow, column: ds.cursorColumn - 1).doubleByte == 2 {
                    if frontMostConnection?.site.shouldDetectDoubleByte ?? false {
                        frontMostConnection!.sendMessage(msg: Data(arrow))
                        return
                    }
                }
                frontMostConnection?.sendMessage(msg: Data(arrow).subdata(in: 0..<3))
                return
            }
            if !hasMarkedText() && Int(c) == NSDeleteCharacter {
                if (frontMostConnection?.site.shouldDetectDoubleByte ?? false &&
                    ds.cursorColumn > 0 && ds.attribute(atRow: ds.cursorRow, column: ds.cursorColumn - 1).doubleByte == 2) {
                    frontMostConnection?.sendMessage(msg: Data([UInt8(NSDeleteCharacter), UInt8(NSDeleteCharacter)]))
                } else {
                    frontMostConnection?.sendMessage(msg: Data([UInt8(NSDeleteCharacter)]))
                }
                return;
            }
        }
        interpretKeyEvents([event])
    }
    
//    override func moveDown(_ sender: Any?) {
//        
//        var arrow : [UInt8] = [0x1B, 0x4F, 0x00, 0x1B, 0x4F, 0x00]
//        if let ds = frontMostTerminal {
//            arrow[2] = "A".utf8.first!
//            arrow[5] = "A".utf8.first!
//        }
//    }
    
    
    override func flagsChanged(with event: NSEvent) {
        let currentFlags = event.modifierFlags
        if currentFlags.contains(.option) {
            // TODO:
//            wantsRectangleSelection = true
            NSCursor.crosshair().push()
//            _mouseBehaviorDelegate.normalCursor = [NSCursor crosshairCursor];

        } else {
            // TODO:
//            wantsRectangleSelection = false
            NSCursor.crosshair().pop()
//            _mouseBehaviorDelegate.normalCursor = [NSCursor crosshairCursor];
        }
        // ???
        // super.flagsChanged(with:event)
    }
}

extension TermView {
    // MARK: Accessor
    var selectedPlainString: String? {
        get  {
            if selectionLength == 0 {
                return nil
            }
            if !hasRectangleSelected {
                let (start, end) = selectionLength >= 0 ?
                    (selectionLocation, selectionLength + selectionLocation) :
                    (selectionLocation + selectionLength, selectionLocation)
                return frontMostTerminal?.string(fromIndex: start, toIndex: end)
            } else {
                // TODO:
                return nil
            }
        }
    }
    var shouldEnableMouse : Bool  {
        get{
            return frontMostConnection?.site.shouldEnableMouse ?? false
        }
    }
//    var shouldWarnCompose : Bool {
//        get {
//            return frontMostTerminal?.bbsState.
//        }
//    }
}

extension TermView: TerminalDelegate {
    func didUpdate(in terminal: Terminal) {
        if let t = frontMostTerminal , terminal === t {
            tick()
        }
    }
}
