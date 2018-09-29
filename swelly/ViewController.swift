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
    var windowDelegate = MainWindowDelegate()
    var idleTimer: Timer!
    var reconnectTimer: Timer!
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
        let identifier = NSStoryboardSegue.Identifier("login-segue")
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
            let termView = self!.termView!
            if termView.connected {
                termView.connection?.sendAntiIdle()
            }
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func didPressConnect(_ sender: Any) {
        if !termView.connected {
            let site = Site()
            site.address = siteAddressField.stringValue
            let connection = Connection(site: site)
            connection.setup()
            let term = Terminal()
            term.delegate = termView
            connection.terminal = term
            termView.connection = connection
            connectButton.title = "Disconnect"
            //siteAddressField.isEditable = false
            
        } else {
            termView.connection?.close()
            //siteAddressField.isEditable = true
            connectButton.title = "Connect"
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if (segue.identifier?.rawValue ?? "") == "login-segue" {
            if let vc = segue.destinationController as? ConnectionViewController {
                vc.terminalViewController = self
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
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        
        sender.setIsVisible(false)
        
        return false
    }
    func windowWillEnterFullScreen(_ notification: Notification) {
        controller.disableConstraintsForFullScreen()
    }
    
    func windowWillExitFullScreen(_ notification: Notification) {
        controller.enableConstraintsFromFullScreen()
    }
}

class ConnectionViewController : NSViewController {
    var site : Site = Site()
    weak var terminalViewController: ViewController!
    @IBOutlet weak var addressField: NSTextField!
    @IBOutlet weak var userNameField: NSTextField!
    @IBOutlet weak var connectionTypeControl: NSSegmentedControl!
    
    @IBAction func didPressConnect(_ sender: Any) {
        if let button = sender as? NSButton {
            button.title = "Connecting..."
            button.isEnabled = false
        }
        site.address = addressField.stringValue
        switch connectionTypeControl.selectedSegment {
        case 0:
            site.connectionProtocol = .telnet
        default:
            site.connectionProtocol = .ssh
        }
        let connection = Connection(site: site)
        connection.userName = userNameField.stringValue
        connection.setup()
        let term = Terminal()
        term.delegate = terminalViewController.termView
        connection.terminal = term
        terminalViewController.termView.connection = connection
        terminalViewController.view.window?.endSheet(view.window!)
    }
    
    @IBAction func didPressCancel(_ sender: Any) {
        
        terminalViewController.view.window?.endSheet(view.window!)
    }
}
