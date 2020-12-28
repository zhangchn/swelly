//
//  ViewController.swift
//  swelly
//
//  Created by ZhangChen on 05/10/2016.
//
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var termView : TermView!
    @IBOutlet weak var connectButton : NSButton!
    
    @IBOutlet weak var siteAddressField: NSTextField!
    @IBOutlet weak var newConnectionView: NSView!
    
    var site : Site = Site()

    var windowDelegate = MainWindowDelegate()
    var idleTimer: Timer!
    var reconnectTimer: Timer!
    weak var currentConnectionViewController : ConnectionViewController?
    override func viewWillAppear() {
        super.viewWillAppear()
        termView.adjustFonts()
    }
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.makeFirstResponder(termView)
        self.view.window?.delegate = windowDelegate
        self.view.window?.isReleasedWhenClosed = false
        self.view.window?.backgroundColor = .black
        let identifier = "login-segue"
        if (!self.termView.connected) {
            self.performSegue(withIdentifier: identifier, sender: self)
        }
//        let newConnectionAlert = NSAlert(error: NSError(domain: "", code: 0, userInfo: nil))
//        newConnectionAlert.alertStyle = .informational
//        newConnectionAlert.accessoryView = newConnectionView
//        newConnectionAlert.messageText = "Connect to BBS..."
//        newConnectionAlert.icon = nil
//        newConnectionAlert.beginSheetModal(for: self.view.window!) { (resp: NSApplication.ModalResponse) in
//            self.performSegue(withIdentifier: NSStoryboard.SegueIdentifier.init("login-segue"), sender: self)
//        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        windowDelegate.controller = self
        idleTimer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { [weak self](timer) in
            self?.termView?.connection?.sendAntiIdle()
        }
    }
    
    deinit {
        idleTimer.invalidate()
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    var connectObserver : AnyObject?
    var disconnectObserver: AnyObject?
    func connectTo(site address:String, as user: String, using protoc: ConnectionProtocol) {
        site.address = address
        site.connectionProtocol = protoc
        let connection = Connection(site: site)
        connection.userName = user
        connection.setup()
        let term = Terminal()
        term.delegate = termView
        connection.terminal = term
        termView.connection = connection

        connectObserver = NotificationCenter.default.addObserver(forName: .connectionDidConnect, object: connection, queue: .main) { [weak self] (note) in
            if let self = self, let connWindow = self.currentConnectionViewController?.view.window {
                self.view.window?.endSheet(connWindow)
            }
        }
        disconnectObserver = NotificationCenter.default.addObserver(forName: .connectionDidDisconnect, object: connection, queue: .main) { [weak self](note) in
            guard let self = self else { return }
            if let ob1 = self.connectObserver {
                NotificationCenter.default.removeObserver(ob1)
            }
            if let ob2 = self.disconnectObserver {
                NotificationCenter.default.removeObserver(ob2)
            }
            if let vc = self.currentConnectionViewController {
                vc.resetUI()
            } else {
                let identifier = "login-segue"
                self.performSegue(withIdentifier: identifier, sender: self)
            }
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if (segue.identifier ?? "") == "login-segue" {
            if let vc = segue.destinationController as? ConnectionViewController {
                vc.terminalViewController = self
                currentConnectionViewController = vc
            }
        }
    }
    
    @IBOutlet var leadingConstraint: NSLayoutConstraint!
    @IBOutlet var trailingConstraint: NSLayoutConstraint!
    @IBOutlet var aspectConstraint: NSLayoutConstraint!
    func disableConstraintsForFullScreen() {
        aspectConstraint.isActive = false
    }
    
    func enableConstraintsFromFullScreen() {
        aspectConstraint.isActive = true
    }
}


class MainWindowDelegate: NSObject, NSWindowDelegate {
    weak var controller: ViewController!
    /*
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        
        sender.setIsVisible(false)
        
        return false
    }
     */
    func windowWillClose(_ notification: Notification) {
        if let termView = controller.termView {
            termView.connection?.close()
        }
    }
    
    func windowWillEnterFullScreen(_ notification: Notification) {
        controller.disableConstraintsForFullScreen()
    }
    
    func windowWillExitFullScreen(_ notification: Notification) {
        controller.enableConstraintsFromFullScreen()
    }
}

class ConnectionViewController : NSViewController {
    weak var terminalViewController: ViewController!
    @IBOutlet weak var addressField: NSTextField!
    @IBOutlet weak var userNameField: NSTextField!
    @IBOutlet weak var connectionTypeControl: NSSegmentedControl!
    @IBOutlet weak var confirmButton: NSButton!
    @IBOutlet weak var cancelButton: NSButton!
    
    override func viewDidLoad() {
        self.userNameField.stringValue = (NSApp.delegate as! AppDelegate).username ?? ""
        self.addressField.stringValue = (NSApp.delegate as! AppDelegate).site ?? ""
    }
    @IBAction func didPressConnect(_ sender: Any) {
        self.confirmButton.title = "Connecting"
        self.confirmButton.isEnabled = false

        (NSApp.delegate as! AppDelegate).username = self.userNameField.stringValue
        (NSApp.delegate as! AppDelegate).site = self.addressField.stringValue
        terminalViewController.connectTo(site: addressField.stringValue, as: userNameField.stringValue, using: connectionTypeControl.selectedSegment == 0 ? .telnet : .ssh)
    }
    
    func resetUI() {
        self.confirmButton.title = "Connect"
        self.confirmButton.isEnabled = true
    }
    
    @IBAction func didPressCancel(_ sender: Any) {
        
        terminalViewController.view.window?.endSheet(view.window!)
    }
}
