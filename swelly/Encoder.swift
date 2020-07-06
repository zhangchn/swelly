//
//  Encoder.swift
//  swelly
//
//  Created by ZhangChen on 05/10/2016.
//
//

import Foundation
import CoreFoundation.CFStringEncodingExt

enum Encoding : Int {
    case gbk = 0
    case big5 = 1
    var stringEncoding: String.Encoding {
        var encodingValue : CFStringEncoding
        switch self {
        case .gbk:
            encodingValue = CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue)
        case .big5:
            encodingValue = CFStringEncoding(CFStringEncodings.big5_E.rawValue)
        }
        return String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(encodingValue))
    }
}

func decode(_ char: UInt16, as encoding: Encoding) -> UTF16Char {
   
    var d = Data.init(count: 2)
    d.withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) in
        let bytes = buffer.bindMemory(to: UInt8.self)
        bytes[0] = UInt8((char & 0xff00) >> 8) + 0x80
        bytes[1] = UInt8(char & 0x00ff)
    }
    let s = String(data: d, encoding: encoding.stringEncoding) ?? "？"
    return s.utf16.first!.littleEndian
}

func encode(_ char: UInt16, to encoding: Encoding) -> UTF16Char {
    var char = char
    guard let d = String(utf16CodeUnits: &char, count: 1).data(using: encoding.stringEncoding) else {
        return 0
    }
    return d.withUnsafeBytes({ (buff:UnsafeRawBufferPointer) -> UTF16Char in
        let buff = buff.bindMemory(to: UTF16Char.self)
        return ((buff[0] & 0xff00) >> 8) | ((buff[0] & 0x00ff) << 8)
    })
}
