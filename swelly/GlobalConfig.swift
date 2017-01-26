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
    var cellWidth: CGFloat
    var cellHeight: CGFloat
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

    var cCTAttribute: [[[String: Any]]]!
    var eCTAttribute: [[[String: Any]]]!
    var colorTable: [[NSColor]]!
    
    var colorBG: NSColor {
        get { return colorTable[0][9] }
        set {
            colorTable[0][9] = newValue.usingColorSpaceName(NSCalibratedRGBColorSpace)!
            UserDefaults.standard.set(NSArchiver.archivedData(withRootObject: newValue), forKey: "ColorBG")

        }
    }
    init() {
        let defaults = UserDefaults.standard
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
        if contentSize.width > NSScreen.main()!.frame.width || contentSize.height > NSScreen.main()!.frame.height {
            restoreSettings()
        }
    }
    func restoreSettings() {
        
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
