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
    d.withUnsafeMutableBytes { (buffer: UnsafeMutablePointer<UInt8>) in
        buffer[0] = UInt8((char & 0xff00) >> 8) + 0x80
        buffer[1] = UInt8(char & 0x00ff)
    }
    let s = String(data: d, encoding: encoding.stringEncoding) ?? "？"
    return s.utf16.first!.littleEndian
}

func encode(_ char: UInt16, to encoding: Encoding) -> UTF16Char {
    var char = char
    let d = String(utf16CodeUnits: &char, count: 1).data(using: encoding.stringEncoding)
    return d?.withUnsafeBytes({ (buff:UnsafePointer<UTF16Char>) -> UTF16Char in
        return ((buff[0] & 0xff00) >> 8) | ((buff[0] & 0x00ff) << 8)
    }) ?? 0
}
