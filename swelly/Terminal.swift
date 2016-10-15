//
//  Terminal.swift
//  swelly
//
//  Created by ZhangChen on 05/10/2016.
//
//

import Foundation

class Terminal {
    var offset: Int = 0
    var maxRow = GlobalConfig.sharedInstance.row
    var maxColumn = GlobalConfig.sharedInstance.column
    var cursorColumn = 0
    var cursorRow = 0
    var grid = [[Cell]]()
    var dirty = [[Bool]]()
    
    var encoding: Encoding! {
        get { return connection!.site.encoding }
        set { connection?.site.encoding = newValue }
    }
    var textBuf : [unichar]
    // TODO: observer using notification center
    weak var connection: Connection? {
        didSet {
            if let c = connection {
                bbsType = c.site.encoding == .big5 ? .Maple : .Firebird
            }
        }
    }
    var bbsType : BBSType = .Firebird
    init() {
        let cellTemplate = Cell()
        for _ in 0..<maxRow {
            grid.append([Cell](repeating: cellTemplate, count: maxColumn + 1))
            dirty.append([Bool](repeating: false, count: maxColumn))
        }
        textBuf = [unichar](repeating: 0, count: maxRow * maxColumn + 1)
        self.clearAll()
    }
    
    func clearAll() {
        cursorColumn = 0
        cursorRow = 0
        var t = Cell.Attribute(rawValue: 0)!
        t.fgColor = UInt8(GlobalConfig.sharedInstance.fgColorIndex)
        t.bgColor = UInt8(GlobalConfig.sharedInstance.bgColorIndex)
        for i in 0..<maxRow {
            for j in 0..<maxColumn {
                grid[i][j].byte = UInt8(0)
                grid[i][j].attribute = t
            }
        }
        setAllDirty()
    }
    
    func setAllDirty() {
        for i in 0..<maxRow {
            for j in 0..<maxColumn {
                dirty[i][j] = true
            }
        }
    }
    
    func setDirty(forRow row: Int) {
        for j in 0..<maxColumn {
            dirty[row][j] = true
        }
    }
    
    func isDirty(atRow row: Int, column: Int) -> Bool{
        return dirty[row][column]
    }
    
    func removeAllDirtyMarks() {
        for r in 0..<maxRow {
            for c in 0..<maxColumn {
                dirty[r][c] = false
            }
        }
    }
    
    func attribute(atRow row: Int, column: Int) -> Cell.Attribute {
        return grid[row][column].attribute
    }
    
    func string(fromIndex:Int, toIndex: Int) -> String? {
        var bufLen = 0
        var spaceBuf = 0
        var firstByte = unichar(0)
        for i in fromIndex..<toIndex {
            let x = i % maxColumn
            let y = i / maxColumn
            if x == 0 && i != fromIndex && i - 1 < toIndex {
                updateDoubleByteStateForRow(row: y)
                let cr = unichar(0x000d)
                textBuf[bufLen] = cr
                bufLen += 1
                spaceBuf = 0
            }
            let db = grid[y][x].attribute.doubleByte
            if db == 0 {
                if grid[y][x].byte == UInt8(0) || grid[y][x].byte == " ".utf8.first! {
                    spaceBuf += 1
                } else {
                    for _ in 0..<spaceBuf {
                        textBuf[bufLen] = " ".utf16.first!
                        bufLen += 1
                    }
                    
                    textBuf[bufLen] = unichar(grid[y][x].byte)
                    bufLen += 1
                    spaceBuf = 0
                }
            } else if db == 1 {
                firstByte = unichar(grid[y][x].byte)
            } else if db == 2 && firstByte != 0 {
                let index = (firstByte << 8) + unichar(grid[y][x].byte) - 0x8000
                for _ in 0..<spaceBuf {
                    textBuf[bufLen] = " ".utf16.first!
                    bufLen += 1
                }
                textBuf[bufLen] = encodeToUnicode(index, from: encoding)
                bufLen += 1
                
                spaceBuf = 0
            }
        }
        if bufLen == 0 {
            return nil
        }
        return textBuf.withUnsafeBufferPointer {
            String(data: Data(buffer: $0), encoding: String.Encoding.utf16)
        }
    }
    func string(atRow row: Int) -> String? {
        return string(fromIndex: row * maxColumn, toIndex: maxColumn)
    }
    func cells(ofRow row: Int) -> [Cell] {
        return grid[row]
    }
    func cell(atIndex index: Int) -> Cell {
        return grid[index / maxColumn][index % maxColumn]
    }
    
    func updateDoubleByteStateForRow(row: Int) {
        let currentRow = grid[row]
        var db = 0
        var isDirty = false
        for c in 0..<maxColumn {
            if db == 0 || db == 2 {
                if currentRow[c].byte > 0x7f {
                    db = 1
                    if c < maxColumn {
                        isDirty = dirty[row][c] || dirty[row][c]
                        dirty[row][c] = isDirty
                        dirty[row][c+1] = isDirty
                    }
                } else {
                    db = 0
                }
            } else {
                db = 2
            }
            grid[row][c].attribute.doubleByte = UInt8(db)
        }
    }
}
