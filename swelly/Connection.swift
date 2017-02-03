//
//  Connection.swift
//  swelly
//
//  Created by ZhangChen on 05/10/2016.
//
//

import AppKit

class Connection : PTYDelegate {
    var icon: NSImage?
    var processing: Bool = false
    
    private var _lastTouchDate : Date?
    var lastTouchDate : Date? { get { return _lastTouchDate } }
    
    var connected: Bool! {
        didSet {
            if connected! {
                icon = NSImage(named: "online.pdf")
            } else {
                resetMessageCount()
                icon = NSImage(named: "offline.pdf")
            }
        }
    }
    var terminal: Terminal! {didSet{ terminal.connection = self}}
    var terminalFeeder: TerminalFeeder
    var pty: PTY?
    var site: Site
    var messageDelegate: MessageDelegate
    var messageCount: Int = 0
    
    init(site: Site){
        self.site = site
        messageDelegate = MessageDelegate()
        terminalFeeder = TerminalFeeder()
        if !site.isDummy {
            pty = PTY(proxyAddress: site.proxyAddress, proxyType: site.proxyType)
            pty!.delegate = self
            _ = pty!.connect(addr: site.address)
        }
    }
    
    // PTY Delegate
    func ptyWillConnect(_ pty: PTY) {
        processing = true
        connected = false
        icon = NSImage(named: "waiting.pdf")
    }
    func ptyDidConnect(_ pty: PTY) {
        processing = false
        connected = true
        Thread.detachNewThread {
            self.login()
        }
    }
    func pty(_ pty: PTY, didRecv data: Data) {
        terminalFeeder.feed(data: data, connection: self)
    }
    
    func pty(_ pty: PTY, willSend data: Data) {
        _lastTouchDate = Date()
    }
    
    func ptyDidClose(_ pty: PTY) {
        processing = false
        connected = false
        terminalFeeder.clearAll()
        terminal.clearAll()
    }
    
    func close() {
        pty?.close()
    }
    
    func reconnect() {
        pty?.close()
        _ = pty?.connect(addr: site.address)
        resetMessageCount()
    }
    
    func sendMessage(msg: Data) {
        pty?.send(data:msg)
    }
    
    func login() {
        let addr = site.address
        let account = addr.utf8
        if !addr.hasPrefix("ssh") {
            if let ps = account.split(separator: "@".utf8.first!).last?
                .split(separator: " ".utf8.first!).last?
                .split(separator: " ".utf8.first!).last {
                while terminalFeeder.cursorY <= 3 {
                    sleep(1)
                    sendMessage(msg: String(ps)!.data(using: .utf8)!)
                    sendMessage(msg: Data.init(bytes: [0x0d]))
                }
            }
            
        } else if terminalFeeder.cursorX > 2, terminalFeeder.grid[terminalFeeder.cursorY][terminalFeeder.cursorX - 2].byte == "?".utf8.first! {
            sendMessage(msg: "yes\r".data(using: .ascii)!)
            sleep(1)
        }
        let service = "Welly".data(using: .utf8)
        service?.withUnsafeBytes() { (buffer : UnsafePointer<Int8>) in
            let accountData = addr.data(using: .utf8)!
            accountData.withUnsafeBytes() {(buffer2 : UnsafePointer<Int8>) in
                var len = UInt32(0)
                var pass : UnsafeMutableRawPointer? = nil
                if noErr == SecKeychainFindGenericPassword(nil, UInt32(service!.count), buffer, UInt32(accountData.count), buffer2, &len, &pass, nil) {
                    sendMessage(msg: Data.init(bytes: pass!, count: Int(len)))
                    sendMessage(msg: Data.init(bytes: [0x0d]))
                    SecKeychainItemFreeContent(nil, pass)
                }
            }
        }
        
    }
    
    func send(text: String, delay microsecond: Int = 0) {
        let s = text.replacingOccurrences(of: "\n", with: "\r")
        var data = Data()
        let encoding = site.encoding
        for ch in s.utf16 {
            var buf = [UInt8](repeating:0, count: 2)
            if ch < 0x007f {
                buf[0] = UInt8(ch)
                data.append(&buf, count: 1)
            } else {
                let code = encodeFromUnicode(ch, to: encoding)
                if code != 0 {
                    buf[0] = UInt8(code >> 8)
                    buf[1] = UInt8(code & 0xff)
                } else {
                    if (ch == 8943 && encoding == .gbk) {
                        // hard code for the ellipsis
                        buf[0] = 0xa1
                        buf[1] = 0xad
                    } else if ch != 0 {
                        buf[0] = 0x20
                        buf[1] = 0x20
                    }
                }
                data.append(&buf, count: 2)
            }
        }
        
        // Now send the message
        if microsecond == 0 {
            // send immediately
            sendMessage(msg: data)
        } else {
            // send with delay
            for i in 0..<data.count {
                sendMessage(msg: data.subdata(in: i..<(i+1)))
                usleep(useconds_t(microsecond))
            }
        }
    }
    
    func increaseMessageCount(value: Int) {
        guard value > 0 else {
            return
        }
        let config = GlobalConfig.sharedInstance
        NSApp.requestUserAttention(config.shouldRepeatBounce ? .criticalRequest : .informationalRequest)
        config.messageCount += value
        messageCount += value
        // self.objectCount = messageCount
    }
    
    func resetMessageCount() {
        guard messageCount > 0 else {return}
        GlobalConfig.sharedInstance.messageCount -= messageCount
        messageCount = 0
        //TODO:
        //self.objectCount = 0
    }
    
    func didReceive(newMessage: String, from caller: String) {
        //
    }
}
