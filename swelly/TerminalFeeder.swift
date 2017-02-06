//
//  TerminalFeeder.swift
//  swelly
//
//  Created by ZhangChen on 05/10/2016.
//
//

import AppKit

enum EMUStd {
    case VT100
    case VT102
}
enum State {
    case TP_NORMAL
    case TP_ESCAPE
    case TP_CONTROL
    case TP_SCS
}

let ASC_NUL : UInt8 = 0x00 // NULL
let ASC_SOH : UInt8 = 0x01 // START OF HEADING
let ASC_STX : UInt8 = 0x02 // START OF TEXT
let ASC_ETX : UInt8 = 0x03 // END OF TEXT
let ASC_EQT : UInt8 = 0x04 // END OF TRANSMISSION
let ASC_ENQ : UInt8 = 0x05 // ^E, ENQUIRE
let ASC_ACK : UInt8 = 0x06 // ACKNOWLEDGE
let ASC_BEL : UInt8 = 0x07 // ^G, BELL (BEEP)
let ASC_BS : UInt8 = 0x08 // ^H, BACKSPACE
let ASC_HT : UInt8 = 0x09 // ^I, HORIZONTAL TABULATION
let ASC_LF : UInt8 = 0x0A // ^J, LINE FEED
let ASC_VT : UInt8 = 0x0B // ^K, Virtical Tabulation
let ASC_FF : UInt8 = 0x0C // ^L, Form Feed
let ASC_CR : UInt8 = 0x0D // ^M, Carriage Return
let ASC_LS1 : UInt8 = 0x0E // Shift Out
let ASC_LS0 : UInt8 = 0x0F // ^O, Shift In
let ASC_DLE : UInt8 = 0x10 // Data Link Escape, normally MODEM
let ASC_DC1 : UInt8 = 0x11 // Device Control One, XON
let ASC_DC2 : UInt8 = 0x12 // Device Control Two
let ASC_DC3 : UInt8 = 0x13 // Device Control Three, XOFF
let ASC_DC4 : UInt8 = 0x14 // Device Control Four
let ASC_NAK : UInt8 = 0x15 // Negative Acknowledge
let ASC_SYN : UInt8 = 0x16 // Synchronous Idle
let ASC_ETB : UInt8 = 0x17 // End of Transmission Block
let ASC_CAN : UInt8 = 0x18 // Cancel
let ASC_EM : UInt8 = 0x19 // End of Medium
let ASC_SUB : UInt8 = 0x1A // Substitute
let ASC_ESC : UInt8 = 0x1B // Escape
let ASC_FS : UInt8 = 0x1C // File Separator
let ASC_GS : UInt8 = 0x1D // Group Separator
let ASC_RS : UInt8 = 0x1E // Record Separator
let ASC_US : UInt8 = 0x1F // Unit Separator
let ASC_DEL : UInt8 = 0x7F // Delete, Ignored on input; not stored in buffer.

// Escape Sequence
let ESC_HASH : UInt8 = 0x23 // #, Several DEC modes..
let ESC_sG0 : UInt8 = 0x28 // (, Font Set G0
let ESC_sG1 : UInt8 = 0x29 // ), Font Set G1
let ESC_APPK : UInt8 = 0x3D // =, Appl. keypad
let ESC_NUMK : UInt8 = 0x3E // >, Numeric keypad
let ESC_DECSC : UInt8 = 0x37 // 7,
let ESC_DECRC : UInt8 = 0x38 // 8,
let ESC_BPH : UInt8 = 0x42 // B,
let ESC_NBH : UInt8 = 0x43 // C,
let ESC_IND : UInt8 = 0x44 // D, Index
let ESC_NEL : UInt8 = 0x45 // E, Next Line
let ESC_SSA : UInt8 = 0x46 // F,
let ESC_ESA : UInt8 = 0x47 // G,
let ESC_HTS : UInt8 = 0x48 // H, Tab Set
let ESC_HTJ : UInt8 = 0x49 // I,
let ESC_VTS : UInt8 = 0x4A // J,
let ESC_PLD : UInt8 = 0x4B // K,
let ESC_PLU : UInt8 = 0x4C // L,
let ESC_RI : UInt8 = 0x4D // M, Reverse Index
let ESC_SS2 : UInt8 = 0x4E // N, Single Shift Select of G2 Character Set
let ESC_SS3 : UInt8 = 0x4F // O, Single Shift Select of G3 Character Set
let ESC_DCS : UInt8 = 0x50 // P, Device Control String
let ESC_PU1 : UInt8 = 0x51 // Q,
let ESC_PU2 : UInt8 = 0x52 // R,
let ESC_STS : UInt8 = 0x53 // S,
let ESC_CCH : UInt8 = 0x54 // T,
let ESC_MW : UInt8 = 0x55 // U,
let ESC_SPA : UInt8 = 0x56 // V, Start of Guarded Area
let ESC_EPA : UInt8 = 0x57 // W, End of Guarded Area
let ESC_SOS : UInt8 = 0x58 // X, Start of String
//#define ESC_      0x59 // Y,
let ESC_SCI : UInt8 = 0x5A // Z, Return Terminal ID
let ESC_CSI : UInt8 = 0x5B // [, Control Sequence Introducer
let ESC_ST : UInt8 = 0x5C // \, String Terminator
let ESC_OSC : UInt8 = 0x5D // ], Operating System Command
let ESC_PM : UInt8 = 0x5E // ^, Privacy Message
let ESC_APC : UInt8 = 0x5F // _, Application Program Command
let ESC_RIS : UInt8 = 0x63 // c, RIS reset

// Control sequences
let CSI_ICH : UInt8 = 0x40 // INSERT CHARACTER, requires DCSM implementation
let CSI_CUU : UInt8 = 0x41 // A, CURSOR UP
let CSI_CUD : UInt8 = 0x42 // B, CURSOR DOWN
let CSI_CUF : UInt8 = 0x43 // C, CURSOR FORWARD
let CSI_CUB : UInt8 = 0x44 // D, CURSOR BACKWARD
let CSI_CNL : UInt8 = 0x45 // E, CURSOR NEXT LINE
let CSI_CPL : UInt8 = 0x46 // F, CURSOR PRECEDING LINE
let CSI_CHA : UInt8 = 0x47 // G, CURSOR CHARACTER ABSOLUTE
let CSI_CUP : UInt8 = 0x48 // H, CURSOR POSITION
let CSI_CHT : UInt8 = 0x49 // I, CURSOR FORWARD TABULATION
let CSI_ED : UInt8 = 0x4A // J, ERASE IN PAGE
let CSI_EL : UInt8 = 0x4B // K, ERASE IN LINE
let CSI_IL : UInt8 = 0x4C // L, INSERT LINE
let CSI_DL : UInt8 = 0x4D // M, DELETE LINE
let CSI_EF : UInt8 = 0x4E // N, Erase in Field, not implemented
let CSI_EA : UInt8 = 0x4F // O, Erase in Area, not implemented
let CSI_DCH : UInt8 = 0x50 // P, DELETE CHARACTER
let CSI_SSE : UInt8 = 0x51 // Q, ?
let CSI_CPR : UInt8 = 0x52 // R, ACTIVE POSITION REPORT, this is for responding
let CSI_SU : UInt8 = 0x53 // S, ?
let CSI_SD : UInt8 = 0x54 // T, ?
let CSI_NP : UInt8 = 0x55 // U, ?
let CSI_PP : UInt8 = 0x56 // V, ?
let CSI_CTC : UInt8 = 0x57 // W, CURSOR TABULATION CONTROL, not implemented
let CSI_ECH : UInt8 = 0x58 // X, ERASE CHARACTER
let CSI_CVT : UInt8 = 0x59 // Y, CURSOR LINE TABULATION, not implemented
let CSI_CBT : UInt8 = 0x5A // Z, CURSOR BACKWARD TABULATION, not implemented
let CSI_SRS : UInt8 = 0x5B // [, ?
let CSI_PTX : UInt8 = 0x5C // \, ?
let CSI_SDS : UInt8 = 0x5D // ], ?
//#define CSISIMD     0x5E // ^, ?
let CSI_HPA : UInt8 = 0x60 // _, CHARACTER POSITION ABSOLUTE
let CSI_HPR : UInt8 = 0x61 // a, CHARACTER POSITION FORWARD
let CSI_REP : UInt8 = 0x62 // b, REPEAT, not implemented
let CSI_DA : UInt8 = 0x63 // c, DEVICE ATTRIBUTES
let CSI_VPA : UInt8 = 0x64 // d, LINE POSITION ABSOLUTE
let CSI_VPR : UInt8 = 0x65 // e, LINE POSITION FORWARD
let CSI_HVP : UInt8 = 0x66 // f, CHARACTER AND LINE POSITION
let CSI_TBC : UInt8 = 0x67 // g, TABULATION CLEAR, not implemented, ignored
let CSI_SM : UInt8 = 0x68 // h, Set Mode, not implemented, ignored
let CSI_MC : UInt8 = 0x69 // i, MEDIA COPY, not implemented, ignored
let CSI_HPB : UInt8 = 0x6A // j, CHARACTER POSITION BACKWARD
let CSI_VPB : UInt8 = 0x6B // k, LINE POSITION BACKWARD
let CSI_RM : UInt8 = 0x6C // l, Reset Mode. not implemented, ignored
let CSI_SGR : UInt8 = 0x6D // m, SELECT GRAPHIC RENDITION
let CSI_DSR : UInt8 = 0x6E // n, DEVICE STATUS REPORT
let CSI_DAQ : UInt8 = 0x6F // o, DEFINE AREA QUALIFICATION, not implemented
let CSI_DFNKY : UInt8 = 0x70 // p, shouldn't be implemented
//0x71 // q,
let CSI_DECSTBM : UInt8 = 0x72 // r, Set Top and Bottom Margins
let CSI_SCP : UInt8 = 0x73 // s, Saves the cursor position.
let CSI_RCP : UInt8 = 0x75 // u, Restores the cursor position.

func isParameter(c: UInt8) -> Bool { return (c >= 0x30 && c <= 0x3F) }

class TerminalFeeder {
    var hasNewMessage = false
    var row: Int
    var column: Int
    var savedCursorX = -1
    var savedCursorY = -1
    var scrollBeginRow = 0
    var scrollEndRow : Int
    var modeScreenReverse = false
    var modeOriginRelative = false
    var modeWraptext = true
    var modeLNM = true
    var modeIRM = false
    var emustd = EMUStd.VT102
    var grid : [[Cell]]
    var cursorX = 0
    var cursorY = 0

    var fgColor: Int
    var bgColor: Int
    var connection: Connection!
    var csTemp = 0
    var state = State.TP_NORMAL
    var bold = false
    var underline = false
    var blink = false
    var reverse = false
    var csBuf = [Int]()
    var csArg = [Int]()
    init() {
        let config = GlobalConfig.sharedInstance
        row = config.row
        column = config.column
        scrollEndRow = row - 1
        grid = [[Cell]](repeating: [Cell](repeating: Cell(), count: column), count: row)
        fgColor = config.fgColorIndex
        bgColor = config.bgColorIndex

        clearAll()
    }
    convenience init(connection: Connection) {
        self.init()
        self.connection = connection
        
    }
    static var gEmptyAttr = Cell.Attribute(rawValue: 0)!
    func clear(row: Int) {
        clear(row: row, from: 0, to: column - 1)
    }

    func clear(row: Int, from start: Int, to end: Int) {
        for i in start...end {
            grid[row][i].byte = 0
            grid[row][i].attribute = TerminalFeeder.gEmptyAttr
            grid[row][i].attribute.bgColor = UInt8(bgColor)
            terminal?.dirty[row][i] = true
        }
    }
    func clearAll() {
        let config = GlobalConfig.sharedInstance
        fgColor = config.fgColorIndex
        bgColor = config.bgColorIndex
        

        TerminalFeeder.gEmptyAttr = Cell.Attribute(rawValue: 0)!
        TerminalFeeder.gEmptyAttr.fgColor = UInt8(fgColor)
        TerminalFeeder.gEmptyAttr.bgColor = UInt8(bgColor)
        
        csTemp = 0;
        state = .TP_NORMAL
        bold = false
        underline = false
        blink = false
        reverse = false
        
        _ = (0..<row).map { self.clear(row: $0) }
        
        csBuf = []
        csArg = []
    }
    func reverseAll() {
        for r in 0..<row {
            for c in 0..<column {
                // swap bgColor and fgColor
                let colorIndex = grid[r][c].attribute.bgColor
                grid[r][c].attribute.bgColor = grid[r][c].attribute.fgColor
                grid[r][c].attribute.fgColor = colorIndex
            }
        }
        terminal?.setAllDirty()
    }
    func feed(data: Data, connection: Connection) {
        data.withUnsafeBytes { (bytes : UnsafePointer<UInt8>) in
            var debugOutput = "feed:"
            for idx in 0..<data.count {
                switch bytes[idx] {
                case 0:
                    debugOutput += "NUL "
                case 27:
                    debugOutput += "ESC "
                case 10:
                    debugOutput += "\\n"
                case 13:
                    debugOutput += "\\r"
                case 32..<127:
                    let u = UnicodeScalar(bytes[idx])
                    let c = Character(u)
                    debugOutput += "'\(c)' "
                default:
                    debugOutput += "(\(bytes[idx])) "
                }
                //debugOutput += "(\(bytes[idx])) "
            }
            print(debugOutput)
            feed(bytes: bytes, length: data.count, connection: connection)
        }
    }
    
    func feed(bytes: UnsafePointer<UInt8>, length len: Int, connection: Connection) {
//        var x: Int
        var peek = false
        if let term = terminal {
            if term.bbsType == .Firebird {
                hasNewMessage = false
            }
        }
        for i in 0..<len {
            if peek {
                peek = false
                continue
            }
            let c = bytes[i]
            switch state {
            case .TP_NORMAL:
                switch c {
                case ASC_NUL, ASC_ETX, ASC_EQT, ASC_ACK, ASC_LS1, ASC_LS0, ASC_DLE, ASC_DC1, ASC_DC2, ASC_DC3, ASC_DC4, ASC_NAK, ASC_SYN, ASC_ETB, ASC_CAN, ASC_SUB, ASC_EM, ASC_FS, ASC_GS, ASC_RS, ASC_US, ASC_DEL:
                    break
                case ASC_ENQ:
                    let d = Data.init(bytes: [ASC_NUL])
                    connection.sendMessage(msg: d)
                case ASC_BEL:
                    NSSound(named:"Whit.aiff")?.play()
                case ASC_BS:
                    if cursorX > 0 {
                        cursorX -= 1
                    }
                case ASC_HT:
                    cursorX = ((cursorX / 8) + 1) * 8
                case ASC_LF, ASC_VT, ASC_FF:
                    if modeLNM == false {
                        cursorX = 0
                    }
                    if cursorY == scrollEndRow {
                        clear(row: scrollBeginRow)
                        
                        for x in scrollBeginRow..<scrollEndRow {
                            grid[x] = grid[x + 1]
                        }
                        grid[scrollEndRow] = grid[scrollBeginRow]
                        terminal?.setAllDirty()
                    } else {
                        cursorY += 1
                        if cursorY >= row {
                            cursorY = row - 1
                        }
                    }

                case ASC_CR:
                    cursorX = 0
                case ASC_ESC:
                    state = .TP_ESCAPE
                default:
                    // SET_GRID_BYTE
                    if cursorX <= column - 1 {
                        grid[cursorY][cursorX].byte = c
                        grid[cursorY][cursorX].attribute.fgColor = UInt8(fgColor)
                        grid[cursorY][cursorX].attribute.bgColor = UInt8(bgColor)
                        grid[cursorY][cursorX].attribute.bold = bold
                        grid[cursorY][cursorX].attribute.underline = underline
                        grid[cursorY][cursorX].attribute.blink = blink
                        grid[cursorY][cursorX].attribute.reverse = reverse
                        grid[cursorY][cursorX].attribute.url = false
                        terminal?.dirty[cursorY][cursorX] = true
                        cursorX += 1
                    }
                }
            case .TP_ESCAPE:
                switch c{
                case ASC_ESC:
                    state = .TP_ESCAPE
                case ESC_CSI:
                    csBuf = []
                    csArg = []
                    csTemp = 0
                    state = .TP_CONTROL
                case ESC_RI:
                    if cursorY == scrollBeginRow {
                        //[_view updateBackedImage];
                        //[_view extendTopFrom: _scrollBeginRow to: _scrollEndRow];
                        for x in ((scrollBeginRow+1)...scrollEndRow).reversed() {
                            grid[x] = grid[x - 1]
                        }
                        clear(row: scrollBeginRow)
                        terminal?.setAllDirty()
                    } else {
                        cursorY -= 1
                        if cursorY < 0 {
                            cursorY = 0
                        }
                    }

                    state = .TP_NORMAL
                case ESC_IND:
                    if (cursorY == scrollEndRow) {
                        clear(row: scrollBeginRow)
                        
                        for x in scrollBeginRow ..< scrollEndRow {
                            grid[x] = grid[x + 1]
                        }
                        grid[scrollEndRow] = grid[scrollBeginRow]
                        terminal?.setAllDirty()
                    } else {
                        cursorY += 1
                        if cursorY >= row {
                            cursorY = row - 1
                        }
                    }

                    state = .TP_NORMAL
                case ESC_DECSC:
                    savedCursorX = cursorX;
                    savedCursorY = cursorY;

                    state = .TP_NORMAL
                case ESC_DECRC:
                    cursorX = savedCursorX;
                    cursorY = savedCursorY;
                    
                    state = .TP_NORMAL
                case ESC_HASH:
                    if i < len-1 && bytes[i+1] == "8".utf8.first! {
                        peek = true
                        for y in 0..<row {
                            for x in 0..<column {
                                grid[y][x].byte = "E".utf8.first!
                                grid[y][x].attribute = TerminalFeeder.gEmptyAttr
                            }
                        }
                        terminal?.setAllDirty()
                    } else {
                        NSLog("Unhandled <ESC># case")
                    }
                    state = .TP_NORMAL
                case ESC_sG0:
                    state = .TP_SCS
                case ESC_sG1:
                    state = .TP_SCS
                case ESC_APPK:
                    state = .TP_NORMAL
                case ESC_NUMK:
                    state = .TP_NORMAL
                case ESC_NEL:
                    cursorX = 0
                    if cursorY == scrollEndRow {
                        clear(row: scrollBeginRow)
                        
                        for x in scrollBeginRow..<scrollEndRow {
                            grid[x] = grid[x + 1]
                        }
                        grid[scrollEndRow] = grid[scrollBeginRow]
                        terminal?.setAllDirty()
                    } else {
                        cursorY += 1
                        if cursorY >= row {
                            cursorY = row - 1
                        }
                    }
                    state = .TP_NORMAL
                case ESC_RIS:
                    self.clearAll()
                    cursorX = 0
                    cursorY = 0
                    
                    state = .TP_NORMAL
                default:
                    NSLog("unprocessed esc: %c(0x%X)", c, c)
                    state = .TP_NORMAL
                }
            case .TP_CONTROL:
                // TODO:
                if isParameter(c: c) {
                    csBuf.append(Int(c))
                    if c >= "0".utf8.first! && c <= "9".utf8.first! {
                        csTemp = csTemp * 10 + Int(c - "0".utf8.first!)
                    } else if c == "?".utf8.first! {
                        csArg.append(-1)
                        csTemp = 0
                        csBuf = []
                    } else if !csBuf.isEmpty {
                        csArg.append(csTemp)
                        csTemp = 0
                        csBuf = []
                    }
                } else if c == ASC_BS { // Backspace eats previous parameter.
                    if !csBuf.isEmpty {
                        csArg.removeFirst()
                    }
                } else if c == ASC_VT {// Virtical Tabulation
                    if modeLNM == false {
                        cursorX = 0
                    }
                    if cursorY == scrollEndRow {
                        for x in scrollBeginRow..<scrollEndRow {
                            grid[x] = grid[x + 1]
                        }
                        clear(row: scrollEndRow)
                        terminal?.setAllDirty() // We might not need to set everything dirty.
                    } else {
                        cursorY += 1
                        if cursorY >= row {
                            cursorY = row - 1
                        }
                    }
                } else if c == ASC_CR { // CR (Carriage Return)
                    cursorX = 0
                } else {
                    if !csBuf.isEmpty {
                        csArg.append(csTemp)
                        csTemp = 0
                        csBuf = []
                    }
                    switch c {
                    case CSI_ICH:
                        var p: Int = 1
                        if let f = csArg.first {
                            if f >= 1 {
                                p = f
                            }
                        }
                        for x in ((cursorX + p)...(column - 1)).reversed() {
                            grid[cursorY][x] = grid[cursorY][x - p]
                            terminal?.dirty[cursorY][x] = true
                        }
                        clear(row: cursorY, from: cursorX, to: cursorX + p - 1)
                    case CSI_CUU: // Cursor Up
                        var p: Int = 1
                        if let f = csArg.first {
                            if (f > 1) {
                                p = f
                            }
                        }
                        cursorY -= p
                        
                        if modeOriginRelative && cursorY < scrollBeginRow {
                            cursorY = scrollBeginRow
                        } else if cursorY < 0 {
                            cursorY = 0
                        }
                    case CSI_CUD:
                        
                        var p: Int = 1
                        if let f = csArg.first {
                            if (f > 1) {
                                p = f
                            }
                        }
                        cursorY += p
                        if modeOriginRelative && cursorY > scrollEndRow {
                            cursorY = scrollEndRow
                        } else {
                            cursorY = min(row - 1, cursorY)
                        }
                    case CSI_CUF:
                        var p = 1
                        if let f = csArg.first {
                            if (f > 1) {
                                p = f
                            }
                        }
                        cursorX += p
                        cursorX = min(cursorX, column - 1)
                    case CSI_CUB:
                        var p = 1
                        if let f = csArg.first {
                            if (f > 1) {
                                p = f
                            }
                        }
                        cursorX -= p
                        cursorX = max(0, cursorX)
                        
                    case CSI_CHA: // move to Pn position of current line
                        var p = 1
                        if let f = csArg.first {
                            if f > 1 {
                                p = f
                            }
                            
                        }
                        CURSOR_MOVETO(x: p - 1, y: cursorY)
                    case CSI_HVP, CSI_CUP:
                        // Cursor Position
                        /*  ^[H			: go to row 1, column 1
                         ^[3H		: go to row 3, column 1
                         ^[3;4H		: go to row 3, column 4 */
                        switch csArg.count {
                        case 0:
                            cursorX = 0
                            cursorY = 0
                        case 1:
                            var p = max(1, csArg.first!)
                            if modeOriginRelative && scrollBeginRow > 0 {
                                p += scrollBeginRow
                                p = min(p, scrollEndRow + 1)
                            }
                            CURSOR_MOVETO(x: 0, y: p - 1)
                        default:
                            var p = max(1, csArg.removeFirst())
                            let q = max(1, csArg.first!)
                            if modeOriginRelative && scrollBeginRow > 0 {
                                p += scrollBeginRow
                                p = min(p, scrollEndRow + 1)
                            }
                            CURSOR_MOVETO(x: q - 1, y: p - 1)
                        }
                    case CSI_ED: // Erase Page (cursor does not move)
                        /*  ^[J, ^[0J	: clear from cursor position to end
                         ^[1J		: clear from start to cursor position
                         ^[2J		: clear all */
                        if (csArg.isEmpty || csArg[0] == 0) {
                            // mjhsieh is not comfortable with putting _csArg lookup with
                            // [_csArg size]==0
                            clear(row: cursorY, from: cursorX, to: column - 1)
                            
                            for j in (cursorY + 1)..<row {
                                clear(row: j)
                            }
                        } else if (!csArg.isEmpty && csArg[0] == 1) {
                            clear(row: cursorY, from: 0, to: cursorX)
                            for j in 0..<cursorY {
                                clear(row: j)
                            }
                        } else if (!csArg.isEmpty && csArg[0] == 2) {
                            clearAll()
                        }
                    case CSI_EL: // Erase Line (cursor does not move)
                        /*
                         ^[K, ^[0K	: clear from cursor position to end of line
                         ^[1K		: clear from start of line to cursor position
                         ^[2K		: clear whole line
                         */
                        if (csArg.isEmpty || csArg[0] == 0) {
                            clear(row: cursorY, from: cursorX, to: column - 1)
                        } else if (!csArg.isEmpty && csArg[0] == 1) {
                            clear(row: cursorY, from: 0, to: cursorX)
                        } else if (!csArg.isEmpty && csArg[0] == 2) {
                            clear(row: cursorY)
                        }
                    case CSI_IL: // Insert Line
                        var lineNumber = 0;
                        if csArg.isEmpty {
                            lineNumber = 1
                        } else {
                            lineNumber = csArg[0]
                        }
                        if (lineNumber < 1) {
                            lineNumber = 1; //mjhsieh is paranoid
                        }
                        
                        for _ in 0..<lineNumber {
//                            cell *emptyRow = [self cellsOfRow: _scrollEndRow];
                            for r in ((cursorY + 1)...scrollEndRow).reversed() {
                                grid[r] = grid[r - 1]
                            }
                            clear(row:cursorY)
                        }
                        for j in cursorY..<scrollEndRow {
                            terminal?.setDirty(forRow: j)
                        }
                    case CSI_DL: // Delete Line
                        var lineNumber = 0;
                        if csArg.isEmpty {
                            lineNumber = 1
                        } else {
                            lineNumber = csArg[0]
                        }
                        if (lineNumber < 1) {
                            lineNumber = 1; //mjhsieh is paranoid
                        }
                        
                        for _ in 0..<lineNumber {
                            for r in cursorY..<scrollEndRow {
                                grid[r] = grid[r + 1]
                            }
                            clear(row:scrollEndRow)
                        }
                        for j in cursorY...scrollEndRow {
                            terminal?.setDirty(forRow: j)
                        }
                    case CSI_DCH: // Delete characters at the current cursor position.
                        var p = 1
                        if csArg.count == 1 {
                            p = max(csArg[0], p)
                        }
                        for j in cursorX..<column {
                            if j <= column - 1 - p {
                                grid[cursorY][j] = grid[cursorY][j+p]
                            } else {
                                grid[cursorY][j].byte = 0
                                grid[cursorY][j].attribute = TerminalFeeder.gEmptyAttr
                                grid[cursorY][j].attribute.bgColor = UInt8(bgColor)
                            }
                            terminal?.dirty[cursorY][j] = true
                        }

                    case CSI_HPA: // goto to absolute character position
                        var p = 0
                        if let f = csArg.first {
                            p = max(f - 1, p)
                        }
                        CURSOR_MOVETO(x: p,y: cursorY)
                    case CSI_HPR: // goto to the next position of the line
                        var p = 1;
                        if let f = csArg.first {
                            p = max(p, f)
                        }
                        CURSOR_MOVETO(x: cursorX+p, y: cursorY);

                    case CSI_DA: // Computer requests terminal identify itself.
                        var data : Data
                        switch emustd {
                        case .VT100:
                            data = Data(bytes: [0x1B, 0x5B, 0x3F, 0x31, 0x3B, 0x30, 0x63])
                        case .VT102:
                            data = Data(bytes: [0x1B, 0x5B, 0x3F, 0x36, 0x63])
                        }
                        if csArg.isEmpty || (csArg.count == 1 && csArg[0] == 0){
                            connection.sendMessage(msg: data)
                        }
                    case CSI_VPA: // move to Pn line, col remaind the same
                        var p = 0
                        if let f = csArg.first {
                            p = max(f - 1, p)
                        }
                        CURSOR_MOVETO(x: cursorX, y: p)
                    case CSI_VPR: // move to Pn Line in forward direction
                        var p = 1;
                        if let f = csArg.first {
                            p = max(p, f)
                        }
                        CURSOR_MOVETO(x: cursorX, y: cursorY + p)
                    case CSI_TBC:
                        // Clear a tab at the current column
                        var p = 1
                        if csArg.count == 1 {
                            p = csArg[0]
                        }
                        if (p == 3) {
                            NSLog("Ignoring request to clear all horizontal tab stops.")
                        } else {
                            NSLog("Ignoring request to clear one horizontal tab stop.")
                        }
                    case CSI_SM: // set mode
                        var doClear = false
                        while !csArg.isEmpty {
                            let p = csArg[0]
                            
                            if (p == -1) {
                                _ = csArg.removeFirst()
                                if csArg.count == 1 {
                                    let f = csArg[0]
                                    if (f == 3) { // Set number of columns to 132
                                        NSLog("132-column mode is not supported.");
                                        doClear = true
                                        modeOriginRelative = false
                                        scrollBeginRow = 0;
                                        scrollEndRow = row - 1;
                                    } else if (f == 5 && modeScreenReverse == false) { //Set reverse video on screen
                                        modeScreenReverse = true
                                        reverse = !reverse;
                                        reverseAll()
                                    } else if (f == 6) { // Set origin to relative
                                        modeOriginRelative = true
                                    } else if (f == 7) { // Set auto-wrap mode
                                        modeWraptext = true
                                        
                                    }
                                }
                            } else if (p == 20) { // Set new line mode
                                modeLNM = false
                            } else if (p == 4) {
                                // selects insert mode and turns INSERT on. New
                                // display characters move old display characters
                                // to the right. Characters moved past the right
                                // margin are lost.
                                modeIRM = true
                                //                      } else if (p == 1) { //When set, the cursor keys send an ESC O prefix, rather than ESC [
                                //                      } else if (p == 2) { //NSLog(@"ignore setting Keyboard Action Mode (AM)");
                                //						} else if (p == 6) { //_modeErasure = YES;
                                //                      } else if (p == 12) { //NSLog(@"ignore re/setting Send/receive (SRM)");
                            }
                            _ = csArg.removeFirst()
                            
                        }
                        if doClear {
                            if modeOriginRelative {
                                
                            } else {
                                clearAll()
                                cursorX = 0
                                cursorY = 0
                            }
                        }

                    case CSI_HPB: // move to Pn Location in backward direction, same raw
                        var p = 1
                        if let f = csArg.first {
                            p = max(p, f)
                        }
                        CURSOR_MOVETO(x: cursorX - p, y: cursorY)
                    case CSI_VPB: // move to Pn Line in backward direction
                        var p = 1
                        if let f = csArg.first {
                            p = max(f, p)
                        }
                        CURSOR_MOVETO(x: cursorX, y: cursorY-p)
                    case CSI_RM: // reset mode
                        var doClear = false
                        while !csArg.isEmpty {
                            let p = csArg[0]
                            if (p == -1) {
                                _ = csArg.removeFirst()
                                if csArg.count == 1 {
                                    let f = csArg[0]
                                    if (f == 3) { // Set number of columns to 80
                                        //NSLog(@"132-column mode (re)setting are not supported.");
                                        doClear = true
                                        modeOriginRelative = false
                                        scrollBeginRow = 0;
                                        scrollEndRow = row - 1;
                                    } else if (p == 5 && modeScreenReverse) { // Set non-reverse video on screen
                                        modeScreenReverse = false
                                        reverse = !reverse;
                                        reverseAll()
                                    } else if (p == 6) { // Set origin to absolute
                                        modeOriginRelative = false
                                    } else if (p == 7) { // Reset auto-wrap mode (disable)
                                        modeWraptext = false
                                        //							    } else if (p == 1) { // Set cursor key to cursor
                                        //								} else if (p == 4) { // Set jump scrolling
                                        //								} else if (p == 8) { // Reset auto-repeat mode
                                        //								} else if (p == 9) { // Reset interlacing mode
                                    }
                                }
                            } else if (p == 20) { // set line feed mode
                                modeLNM = true
                            } else if (p == 4) {
                                // selects replace mode and turns INSERT off. New
                                // display characters replace old display characters
                                // at cursor position. The old character is erased.
                                modeIRM = false
                                //						} else if (p == 6) { //_modeErasure = NO;
                            }
                            _ = csArg.removeFirst()
                        }
                        if doClear {
                            clearAll()
                            cursorX = 0
                            cursorY = 0
                        }

                    case CSI_SGR:
                        // Character Attributes
                        if csArg.isEmpty { // clear
                            fgColor = 7
                            bgColor = 9
                            bold = false
                            underline = false
                            blink = false
                            reverse = !modeScreenReverse
                        } else {
                            while !csArg.isEmpty {
                                let p = csArg.removeFirst()
                                switch p {
                                case 0:
                                    fgColor = 7
                                    bgColor = 9
                                    bold = false
                                    underline = false
                                    blink = false
                                    reverse = !modeScreenReverse
                                case 30...39:
                                    fgColor = p - 30
                                case 40...49:
                                    bgColor = p - 40
                                case 1:
                                    bold = true
                                case 4:
                                    underline = true
                                case 5:
                                    blink = true
                                case 7:
                                    reverse = modeScreenReverse
                                default:
                                    break
                                }
                            }
                        }
                    case CSI_DSR:
                        if csArg.count == 1{
                            let f = csArg[0]
                            switch f {
                            case 5:
                                // Report Device OK	<ESC>[0n
                                connection.sendMessage(msg: Data(bytes:[0x1B, 0x5B, 0x30, CSI_DSR]))
                            case 6:	// Report Device OK	<ESC>[y;xR

                                var data = Data(bytes:[0x1B, 0x5B])
                                if (cursorY + 1) / 10 >= 1 {
                                    data.append(0x30 + UInt8((cursorY + 1)/10))
                                }
                                data.append(0x30 + UInt8((cursorY + 1) % 10))
                                data.append(0x3B)
                                if (cursorX + 1 )/10 >= 1 {
                                    data.append(0x30 + UInt8((cursorX + 1)/10))
                                }
                                data.append(0x30 + UInt8((cursorX + 1) % 10))
                                data.append(CSI_CPR)
                                connection.sendMessage(msg: data)
                            default:
                                break
                            }
                        }
                    case CSI_DECSTBM: // Assigning Scrolling Region
                        switch csArg.count {
                        case 0:
                            scrollBeginRow = 0
                            scrollEndRow = row - 1
                        case 2:
                            let s = min(csArg[0], csArg[1])
                            let e = max(csArg[0], csArg[1])
                            scrollBeginRow = s - 1
                            scrollEndRow = e - 1
                        default:
                            break
                        }
                        cursorX = 0
                        cursorY = scrollBeginRow;
                    case CSI_SCP:
                        savedCursorX = cursorX
                        savedCursorY = cursorY

                    case CSI_RCP:
                        if savedCursorX >= 0 && savedCursorY >= 0 {
                            cursorX = savedCursorX
                            cursorY = savedCursorY
                        }
                    default:
                        NSLog("unsupported control sequence: 0x%X", c)
                    }
                    csArg = []
                    state = .TP_NORMAL
                }
                
                
//                csArg = []
//                state = .TP_NORMAL
            case .TP_SCS:
                state = .TP_NORMAL
            }
        }
        terminal?.cursorColumn = cursorX
        terminal?.cursorRow = cursorY
        terminal?.feed(grid: &grid)
        if hasNewMessage {
            // TODO: new incoming message
            if let terminal = terminal {
                switch terminal.bbsType {
                case .Maple:
                    guard grid[row - 1][0].attribute.bgColor != 9
                        && grid[row - 1][column - 2].attribute.bgColor == 9 else {
                            break
                    }
                    // PTT
                case .Firebird:
                    guard grid[0][0].attribute.bgColor != 9 else {
                        break
                    }
                    // NewSMTH
                    var stop: Int!
                    for i in 2..<row {
                        stop = i
                        if grid[i][0].attribute.bgColor == 9 {
                            break
                        }
                    }
                    let caller = terminal.string(fromIndex: 0, toIndex: column)
                    let message = terminal.string(fromIndex: column, toIndex: stop * column )
                    print("caller: \(caller); message: \(message)")
                default:
                    break
                }
            }
//            if terminal?.bbsType == .Maple ?? false
//                && grid[row - 1][0].attribute.bgColor != 9
//                && grid[row - 1][column - 2].attribute.bgColor == 9 {
//                    
////                .f.bgColor != 9 && grid[row - 1][column - 2].attr.f.bgColor == 9) {
//            } else if (terminal?.bbsType == WLFirebird && _grid[0][0].attr.f.bgColor != 9) {
//                // for firebird bbs (e.g. smth)
//                for (i = 2; i < _row && _grid[i][0].attr.f.bgColor != 9; ++i);	// determine the end of the message
//                NSString *callerName = [_terminal stringAtIndex:0 length:_column];
//                NSString *messageString = [_terminal stringAtIndex:_column length:(i - 1) * _column];
//                
//                [connection didReceiveNewMessage:messageString fromCaller:callerName];
//            }

        }
    }
    func  CURSOR_MOVETO(x: Int, y: Int) {
        cursorX = min(max(x, 0), column - 1)
        cursorY = min(max(y, 0), row - 1)
    }
    
    
    
    weak var terminal: Terminal?
    func withCells<R>(ofRow r: Int, block: ([Cell]) throws -> R ) rethrows -> R {
        return try block(grid[r])
    }
}
