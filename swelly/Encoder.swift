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
}

func encodeToUnicode(_ char: UInt16, from encoding: Encoding) -> UTF16Char {
    var encodingValue : CFStringEncoding
    switch encoding {
    case .gbk:
        encodingValue = CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue)
    case .big5:
        encodingValue = CFStringEncoding(CFStringEncodings.big5_E.rawValue)
    }
    var d = Data.init(count: 2)
    d.withUnsafeMutableBytes { (buffer: UnsafeMutablePointer<UInt16>) in
        buffer[0] = char
    }
    let s = String(data: d, encoding: String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(encodingValue)))!
    return s.utf16.first!.littleEndian
}
