//
//  GlobalConfig.swift
//  swelly
//
//  Created by ZhangChen on 05/10/2016.
//
//

import AppKit

class GlobalConfig {
    static var sharedInstance: GlobalConfig = GlobalConfig()
    var defaultEncoding: Encoding
    var shouldDetectDoubleByte = false
    var shouldSmoothFonts = false
    var shouldEnableMouse = false
    var shouldRepeatBounce = false
    var blinkTicker = false
    var showHiddenText = false
    var defaultANSIColorKey: ANSIColorKey
    
    var row: Int = 24
    var column: Int = 80
    var cellWidth: CGFloat = 12
    var cellHeight: CGFloat = 24
    var contentSize: NSSize {
        get {
            return NSSize(width: CGFloat(column) * cellWidth, height: CGFloat(row) * cellHeight)
        }
    }
    var messageCount: Int = 0
    var fgColorIndex: Int = 7
    var bgColorIndex: Int = 9
    var chineseFontSize: CGFloat
    var englishFontSize: CGFloat
    var chineseFontPaddingLeft: CGFloat
    var englishFontPaddingLeft: CGFloat
    var chineseFontPaddingBottom: CGFloat
    var englishFontPaddingBottom: CGFloat
    var chineseFontName: String
    var englishFontName: String
    
    var englishFont: CTFont!
    var chineseFont: CTFont!

    var cCTAttribute: [[[NSAttributedString.Key: Any]]] = []
    var eCTAttribute: [[[NSAttributedString.Key: Any]]] = []
    var colorTable: [[NSColor]]!
    
    var colorBG: NSColor {
        get { return colorTable[0][9] }
        set {
            colorTable[0][9] = newValue.usingColorSpaceName(NSColorSpaceName.calibratedRGB)!
            UserDefaults.standard.set(NSArchiver.archivedData(withRootObject: newValue), forKey: "ColorBG")

        }
    }
    init() {
        let defaults = UserDefaults.standard
        let numColor = 10
        colorTable = [[NSColor].init(repeating: .clear, count: numColor),
                      [NSColor].init(repeating: .clear, count: numColor)]
        colorTable[0][0] = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        colorTable[0][1] = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        colorTable[0][2] = #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)
        colorTable[0][3] = #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1)
        colorTable[0][4] = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        colorTable[0][5] = #colorLiteral(red: 1, green: 0.2527923882, blue: 1, alpha: 1)
        colorTable[0][6] = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)
        colorTable[0][7] = #colorLiteral(red: 0.9217456579, green: 0.9217456579, blue: 0.9217456579, alpha: 1)
        colorTable[0][8] = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        colorTable[0][9] = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

        colorTable[1][0] = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        colorTable[1][1] = #colorLiteral(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 1)
        colorTable[1][2] = #colorLiteral(red: 0.8321695924, green: 0.985483706, blue: 0.4733308554, alpha: 1)
        colorTable[1][3] = #colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 1)
        colorTable[1][4] = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        colorTable[1][5] = #colorLiteral(red: 1, green: 0.2527923882, blue: 1, alpha: 1)
        colorTable[1][6] = #colorLiteral(red: 0.4513868093, green: 0.9930960536, blue: 1, alpha: 1)
        colorTable[1][7] = #colorLiteral(red: 0.956774056, green: 0.956774056, blue: 0.956774056, alpha: 1)
        colorTable[1][8] = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        colorTable[1][9] = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

        showHiddenText = defaults.bool(forKey: "ShowHiddenText")
        shouldSmoothFonts = defaults.bool(forKey: "ShouldSmoothFonts")
        shouldDetectDoubleByte = defaults.bool(forKey: "DetectDoubleByte")
        shouldEnableMouse = defaults.bool(forKey: "EnableMouse")
        defaultEncoding = Encoding(rawValue: defaults.integer(forKey: "DefaultEncoding"))!
        defaultANSIColorKey = ANSIColorKey(rawValue: defaults.integer(forKey: "DefaultANSIColorKey"))!
        shouldRepeatBounce = defaults.bool(forKey: "RepeatBounce")
     
        cellWidth = CGFloat(defaults.float(forKey: "CellWidth"))
        cellHeight = CGFloat(defaults.float(forKey: "CellHeight"))
        chineseFontName = defaults.string(forKey: "ChineseFontName") ?? "STHeiti"
        englishFontName = defaults.string(forKey: "EnglishFontName") ?? "Monaco"
        chineseFontSize = CGFloat(defaults.float(forKey: "ChineseFontSize"))
        englishFontSize = CGFloat(defaults.float(forKey: "EnglishFontSize"))
        chineseFontPaddingLeft = CGFloat(defaults.float(forKey:"ChinesePaddingLeft"))
        chineseFontPaddingBottom = CGFloat(defaults.float(forKey:"ChinesePaddingBottom"))
        englishFontPaddingLeft = CGFloat(defaults.float(forKey:"EnglishPaddingLeft"))
        englishFontPaddingBottom = CGFloat(defaults.float(forKey:"EnglishPaddingBottom"))
        

        if cellWidth < 4.0 || cellHeight < 4.0 || chineseFontSize < 4.0 || englishFontSize < 4.0 {
            restoreSettings()
        }
        if contentSize.width > NSScreen.main!.frame.width || contentSize.height > NSScreen.main!.frame.height {
            restoreSettings()
        }
        let ename = englishFontName as CFString
        let cname = chineseFontName as CFString
        englishFont = CTFontCreateWithName(ename, englishFontSize, nil)
        chineseFont = CTFontCreateWithName(cname, chineseFontSize, nil)
        
        for table in 0..<2 {
            cCTAttribute.append([])
            eCTAttribute.append([])
            for colorIndex in 0..<numColor {
                cCTAttribute[table].append([.font: chineseFont as Any, .foregroundColor : colorTable[table][colorIndex], .ligature: 0])
                eCTAttribute[table].append([.font: englishFont as Any, .foregroundColor: colorTable[table][colorIndex], .ligature: 0])
            }
        }
    }
    func restoreSettings() {
        cellWidth = 12
        cellHeight = 24
        chineseFontName = "STHeiti"
        englishFontName = "Monaco"
        chineseFontSize = 22 / 24 * cellHeight
        englishFontSize = 18 / 24 * cellHeight
    }
    
    func refreshFonts() {
        
    }
    
    func color(atIndex i: Int, highlight: Bool) -> NSColor {
        if i >= 0 && i < 10 {
            return colorTable[highlight ? 1 : 0][i]
        } else {
            return colorTable[0][10 - 1]
        }
    }
    func bgColor(atIndex i: Int, highlight: Bool) -> NSColor {
        return color(atIndex: i, highlight: highlight).withAlphaComponent(colorBG.alphaComponent)
    }
}
