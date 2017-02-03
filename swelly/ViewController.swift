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
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let site = Site()
        site.address = "ssh://tgfbeta@bbs.newsmth.net"
        let connection = Connection(site: site)
        let term = Terminal()
        term.delegate = termView
        connection.terminal = term
        //term.connection = connection
        termView.connection = connection
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

