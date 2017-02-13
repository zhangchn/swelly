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
    var windowDelegate = MainWindowDelegate()
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.makeFirstResponder(siteAddressField)
        self.view.window?.delegate = windowDelegate
        self.view.window?.isReleasedWhenClosed = false
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
}

class MainWindowDelegate: NSObject, NSWindowDelegate {
    func windowShouldClose(_ sender: Any) -> Bool {
        NSApplication.shared().hide(self)
        return false
    }
    
    
}

