//
//  PTY.swift
//  swelly
//
//  Created by ZhangChen on 05/10/2016.
//
//

import Foundation
import Darwin

protocol PTYDelegate: NSObjectProtocol {
    func ptyWillConnect(_ pty: PTY)
    func ptyDidConnect(_ pty: PTY)
    func pty(_ pty: PTY, didRecv data: Data)
    func pty(_ pty: PTY, willSend data: Data)
    func ptyDidClose(_ pty: PTY)
}

func ctrlKey(_ c: String) throws -> UInt8 {
    if let c = c.unicodeScalars.first {
        if !c.isASCII {
            throw NSError(domain: "PTY", code: 1, userInfo: nil)
        }
        return UInt8(c.value) - UInt8("A".unicodeScalars.first!.value + 1)
    } else {
        throw NSError(domain: "PTY", code: 2, userInfo: nil)
    }
}

func fdZero(_ set: inout fd_set) {
    set.fds_bits = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
}

func fdSet(_ fd: Int32, set: inout fd_set) {
    let intOffset = Int(fd / 32)
    let bitOffset = fd % 32
    let mask: __int32_t = 1 << bitOffset
    switch intOffset {
    case 0: set.fds_bits.0 = set.fds_bits.0 | mask
    case 1: set.fds_bits.1 = set.fds_bits.1 | mask
    case 2: set.fds_bits.2 = set.fds_bits.2 | mask
    case 3: set.fds_bits.3 = set.fds_bits.3 | mask
    case 4: set.fds_bits.4 = set.fds_bits.4 | mask
    case 5: set.fds_bits.5 = set.fds_bits.5 | mask
    case 6: set.fds_bits.6 = set.fds_bits.6 | mask
    case 7: set.fds_bits.7 = set.fds_bits.7 | mask
    case 8: set.fds_bits.8 = set.fds_bits.8 | mask
    case 9: set.fds_bits.9 = set.fds_bits.9 | mask
    case 10: set.fds_bits.10 = set.fds_bits.10 | mask
    case 11: set.fds_bits.11 = set.fds_bits.11 | mask
    case 12: set.fds_bits.12 = set.fds_bits.12 | mask
    case 13: set.fds_bits.13 = set.fds_bits.13 | mask
    case 14: set.fds_bits.14 = set.fds_bits.14 | mask
    case 15: set.fds_bits.15 = set.fds_bits.15 | mask
    case 16: set.fds_bits.16 = set.fds_bits.16 | mask
    case 17: set.fds_bits.17 = set.fds_bits.17 | mask
    case 18: set.fds_bits.18 = set.fds_bits.18 | mask
    case 19: set.fds_bits.19 = set.fds_bits.19 | mask
    case 20: set.fds_bits.20 = set.fds_bits.20 | mask
    case 21: set.fds_bits.21 = set.fds_bits.21 | mask
    case 22: set.fds_bits.22 = set.fds_bits.22 | mask
    case 23: set.fds_bits.23 = set.fds_bits.23 | mask
    case 24: set.fds_bits.24 = set.fds_bits.24 | mask
    case 25: set.fds_bits.25 = set.fds_bits.25 | mask
    case 26: set.fds_bits.26 = set.fds_bits.26 | mask
    case 27: set.fds_bits.27 = set.fds_bits.27 | mask
    case 28: set.fds_bits.28 = set.fds_bits.28 | mask
    case 29: set.fds_bits.29 = set.fds_bits.29 | mask
    case 30: set.fds_bits.30 = set.fds_bits.30 | mask
    case 31: set.fds_bits.31 = set.fds_bits.31 | mask
    default: break
    }
}

func fdIsset(_ fd: Int32, _ set: fd_set) -> Bool {
    let a = fd / 32
    let mask: Int32 = 1 << (fd % 32)
    switch a {
    case 0: return (set.fds_bits.0 & mask) != 0
    case 1: return (set.fds_bits.1 & mask) != 0
    case 2: return (set.fds_bits.2 & mask) != 0
    case 3: return (set.fds_bits.3 & mask) != 0
    case 4: return (set.fds_bits.4 & mask) != 0
    case 5: return (set.fds_bits.5 & mask) != 0
    case 6: return (set.fds_bits.6 & mask) != 0
    case 7: return (set.fds_bits.7 & mask) != 0
    case 8: return (set.fds_bits.8 & mask) != 0
    case 9: return (set.fds_bits.9 & mask) != 0
    case 10: return (set.fds_bits.10 & mask) != 0
    case 11: return (set.fds_bits.11 & mask) != 0
    case 12: return (set.fds_bits.12 & mask) != 0
    case 13: return (set.fds_bits.13 & mask) != 0
    case 14: return (set.fds_bits.14 & mask) != 0
    case 15: return (set.fds_bits.15 & mask) != 0
    case 16: return (set.fds_bits.16 & mask) != 0
    case 17: return (set.fds_bits.17 & mask) != 0
    case 18: return (set.fds_bits.18 & mask) != 0
    case 19: return (set.fds_bits.19 & mask) != 0
    case 20: return (set.fds_bits.20 & mask) != 0
    case 21: return (set.fds_bits.21 & mask) != 0
    case 22: return (set.fds_bits.22 & mask) != 0
    case 23: return (set.fds_bits.23 & mask) != 0
    case 24: return (set.fds_bits.24 & mask) != 0
    case 25: return (set.fds_bits.25 & mask) != 0
    case 26: return (set.fds_bits.26 & mask) != 0
    case 27: return (set.fds_bits.27 & mask) != 0
    case 28: return (set.fds_bits.28 & mask) != 0
    case 29: return (set.fds_bits.29 & mask) != 0
    case 30: return (set.fds_bits.30 & mask) != 0
    case 31: return (set.fds_bits.31 & mask) != 0
    default: break
    }
    return false
}

class PTY {
    weak var delegate: PTYDelegate?
    var proxyType: ProxyType
    var proxyAddress: String
    private var connecting = false
    private var fd: Int32 = -1
    private var pid: pid_t = 0
    init(proxyAddress addr:String, proxyType type: ProxyType) {
        proxyType = type
        proxyAddress = addr
    }
    deinit {
        close()
    }
    
    func close() {
        if pid > 0 {
            kill(pid, SIGKILL)
            pid = 0
        }
        if fd >= 0 {
            _ = Darwin.close(fd)
            fd = -1
            delegate?.ptyDidClose(self)
        }
    }

    class func parse(addr: String) -> String {
        var addr = addr.trimmingCharacters(in: CharacterSet.whitespaces)
        if addr.contains(" ") {
            return addr;
        }
        var ssh = false
        var port: String? = nil
        var fmt: String!
        if addr.lowercased().hasPrefix("ssh://") {
            ssh = true
            let idx = addr.index(addr.startIndex, offsetBy: 6)
            addr = String(addr[idx...])
        } else {
            if let range = addr.range(of: "://") {
                addr = String(addr[range.upperBound...])
            }
        }
        if let range = addr.range(of: ":") {
            port = String(addr[range.upperBound...])
            addr = String(addr[..<range.lowerBound])
        }
        if ssh {
            if port == nil {
                port = "22"
            }
            fmt = "ssh -o Protocol=2,1 -p %2$@ -x %1$@"
        } else {
            if port == nil {
                port = "23"
            }
            if let range = addr.range(of: "@") {
                addr = String(addr[range.upperBound...])
            }
            fmt = "/usr/bin/telnet -8 %@ -%@"
        }
        return String.init(format: fmt, addr, port!)
    }
    func connect(addr: String, connectionProtocol: ConnectionProtocol, userName: String!) -> Bool {
        let slaveName = UnsafeMutablePointer<Int8>.allocate(capacity: Int(PATH_MAX))
        let iflag = tcflag_t(bitPattern: Int(ICRNL | IXON | IXANY | IMAXBEL | BRKINT))
        let oflag = tcflag_t(bitPattern: Int(OPOST | ONLCR))
        let cflag = tcflag_t(bitPattern: Int(CREAD | CS8 | HUPCL))
        let lflag = tcflag_t(bitPattern: Int(ICANON | ISIG | IEXTEN | ECHO | ECHOE | ECHOK | ECHOKE | ECHOCTL))
        
        let controlCharacters : (cc_t, cc_t, cc_t, cc_t, cc_t, cc_t, cc_t, cc_t, cc_t, cc_t, cc_t, cc_t, cc_t, cc_t, cc_t, cc_t, cc_t, cc_t, cc_t, cc_t) = try! (ctrlKey("D"), 0xff, 0xff, 0x7f, ctrlKey("W"), ctrlKey("U"), ctrlKey("R"), 0, ctrlKey("C"), 0x1c, ctrlKey("Z"), ctrlKey("Y"), ctrlKey("Q"), ctrlKey("S"), 0xff, 0xff, 1, 0, 0xff, 0)
        var term = termios(c_iflag: iflag,
                           c_oflag: oflag,
                           c_cflag: cflag,
                           c_lflag: lflag,
                           c_cc: controlCharacters,
                           c_ispeed: speed_t(B38400),
                           c_ospeed: speed_t(B38400))
        let ws_col = GlobalConfig.sharedInstance.column
        let ws_row = GlobalConfig.sharedInstance.row
        var size = winsize(ws_row: UInt16(ws_row), ws_col: UInt16(ws_col), ws_xpixel: 0, ws_ypixel: 0)
        

        //var arguments = PTY.parse(addr: addr).components(separatedBy: " ")
        pid = forkpty(&fd, slaveName, &term, &size)
        if pid < 0 {
            print("Error forking pty: \(errno)")
        } else if pid == 0 {
            // child process
            //kill(0, SIGSTOP)
            var arguments: [String]
            var hostAndPort = addr.split(separator: ":")
            switch connectionProtocol {
            case .telnet:
                if hostAndPort.count == 2, let _ = Int(hostAndPort[1]) {
                    arguments = ["/usr/bin/telnet", "-8", String(hostAndPort[0]), String(hostAndPort[1])]
                } else {
                    arguments = ["/usr/bin/telnet", "-8", String(hostAndPort[0])]
                }
            case .ssh:
                if hostAndPort.count == 2 {
                    if let _ = Int(hostAndPort[1]) {
                        arguments = ["ssh", "-o", "Protocol=2,1",  "-p", String(hostAndPort[1]), "-x", userName! + "@" + String(hostAndPort[0])]
                    } else {
                        arguments = ["ssh", "-o", "Protocol=2,1",  "-p", "22", "-x", userName! + "@" + String(hostAndPort[0])]
                    }
                } else {
                    arguments = ["ssh", "-o", "Protocol=2,1",  "-p", "22", "-x", userName! + "@" + String(hostAndPort[0])]
                }
                if let proxyCommand = Proxy.proxyCommand(address: proxyAddress, type: proxyType) {
                    arguments.append("-o")
                    arguments.append(proxyCommand)
                }
            }
            let argv = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: arguments.count + 1)
            for (idx, arg) in arguments.enumerated() {
                argv[idx] = arg.utf8CString.withUnsafeBytes({ (buf) -> UnsafeMutablePointer<Int8> in
                    let x = UnsafeMutablePointer<Int8>.allocate(capacity: buf.count + 1)
                    memcpy(x, buf.baseAddress, buf.count)
                    x[buf.count] = 0
                    return x
                })
            }
            argv[arguments.count] = nil
            execvp(argv[0], argv)
            perror(argv[0])
            
            sleep(UINT32_MAX)
        } else {
            // parent process
            var one = 1
            let result = ioctl(fd, TIOCPKT, &one)
            if result == 0 {
                Thread.detachNewThread {
                    self.readLoop()
                }
            } else {
                print("ioctl failure: erron: \(errno)")
            }
        }
        slaveName.deallocate()
        connecting = true
        delegate?.ptyWillConnect(self)
        return true
    }
    
    func recv(data: Data) {
        if connecting {
            connecting = false
            delegate?.ptyDidConnect(self)
        }
        delegate?.pty(self, didRecv: data)
    }
    
    func send(data: Data) {
        guard fd >= 0 && !connecting else {
            return
        }
        
        
        
        delegate?.pty(self, willSend: data)
        var length = data.count
        data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
            var writefds = fd_set()
            var errorfds = fd_set()
            var timeout = timeval()
            
            
            var chunkSize: Int
            var msg = bytes.baseAddress!
            while length > 0 {
//                bzero(&writefds, MemoryLayout<fd_set>.size)
//                bzero(&errorfds, MemoryLayout<fd_set>.size)
                fdZero(&writefds)
                fdZero(&errorfds)
                fdSet(fd, set: &writefds)
                fdSet(fd, set: &errorfds)
                
                timeout.tv_sec = 0
                timeout.tv_usec = 100000
                
                let result = select(fd + 1, nil, &writefds, &errorfds, &timeout)
                if result == 0 {
                    NSLog("timeout")
                    break
                } else if result < 0 {
                    self.close()
                    break
                }
                
                if length > 4096 {
                    chunkSize = 4096
                } else {
                    chunkSize = length
                }
                let size = write(fd, bytes.baseAddress!, chunkSize)
                if size < 0 {
                    break
                }
                msg = msg.advanced(by: size)
                length -= size
            }
        }
    }
    func readLoop() {
        
        var readfds = fd_set()
        var errorfds = fd_set()
        var exit = false
        
        let buf = UnsafeMutablePointer<Int8>.allocate(capacity: 4096)
        var iterationCount = 0
        let result = autoreleasepool { () -> Int32 in
            var result = Int32(0)
            while !exit {
                iterationCount += 1
                fdZero(&readfds)
                fdZero(&errorfds)
                fdSet(fd, set: &readfds)
                fdSet(fd, set: &errorfds)
                
                result = select(fd.advanced(by: 1), &readfds, nil, &errorfds, nil)
                if result < 0 {
                    print("")
                    break
                } else if fdIsset(fd, errorfds) {
                    result = Int32(read(fd, buf, 1))
                    if result == 0 {
                        exit = true
                    }
                    
                } else if fdIsset(fd, readfds) {
                    result = Int32(read(fd, buf, 4096))
                    if result > 1 {
                        let d =  Data(buffer: UnsafeBufferPointer<Int8>(start: buf.advanced(by: 1), count: Int(result)-1))
                        DispatchQueue.main.async {
                            self.recv(data: d)
                        }
                    } else if result == 0 {
                        exit = true
                    }
                }
            }
            return result
        }
        if result >= 0 {
            DispatchQueue.main.async {
                self.close()
            }
        }
        buf.deallocate()
    }
}
