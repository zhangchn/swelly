//
//  CommonTypes.swift
//  swelly
//
//  Created by ZhangChen on 05/10/2016.
//
//

import Foundation
enum ANSIColorKey : Int {
    case ctrlU = 0
    case escEsc = 1
}

enum ProxyType {
    case None
    case Auto
    case Socks
    case Http
    case Https
}

struct Cell {
    struct Attribute: RawRepresentable {
        var rawValue: UInt16
        var fgColor : UInt8 {
            get {
                return UInt8(rawValue >> 12)
            }
            set {
                rawValue = (rawValue & 0x0fff) | ((UInt16(newValue) << 12) & 0xf000)
            }
        }
        var bgColor : UInt8 {
            get {
                return UInt8(rawValue >> 8) & 0x0f
            }
            set {
                rawValue = (rawValue & 0x0f00) | ((UInt16(newValue) << 8) & 0x0f00)
            }
        }
        var bold : Bool {
            get {
                return rawValue & 0x0080 == 0x0080
            }
            set {
                rawValue = (rawValue & 0xff7f) | (newValue ? 0x0080 : 0)
            }
        }
        var underline : Bool {
            get {
                return rawValue & 0x0040 == 0x0040
            }
            set {
                rawValue = (rawValue & 0xffbf) | (newValue ? 0x0040 : 0)
            }
        }
        var blink : Bool {
            get {
                return rawValue & 0x0020 == 0x0020
            }
            set {
                rawValue = (rawValue & 0xffdf) | (newValue ? 0x0020 : 0)
            }
        }
        var reverse : Bool {
            get {
                return rawValue & 0x0010 == 0x0010
            }
            set {
                rawValue = (rawValue & 0xffef) | (newValue ? 0x0010 : 0)
            }
        }
        var doubleByte : UInt8 {
            get {
                return UInt8(rawValue >> 2) & 0x03
            }
            set {
                rawValue = (rawValue & 0xfff3) | ((UInt16(newValue) << 2) & 0x000c)
            }
        }
        var url : Bool {
            get {
                return rawValue & 0x0002 == 0x0002
            }
            set {
                rawValue = (rawValue & 0xfffd) | (newValue ? 0x0002 : 0)
            }
        }
        var nothing : Bool {
            get {
                return rawValue & 0x0001 == 0x0001
            }
            set {
                rawValue = (rawValue & 0xfffe) | (newValue ? 0x0001 : 0)
            }
        }

        init?(rawValue: UInt16) {
            self.rawValue = rawValue
        }
    }
    var attribute = Attribute(rawValue: 0)!
    var byte: UInt8 = 0
}

enum BBSType {
    case Firebird
    case Maple
    case Unix
}
