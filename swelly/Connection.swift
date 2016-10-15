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
}
