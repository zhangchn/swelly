//
//  MessageDelegate.swift
//  swelly
//
//  Created by ZhangChen on 05/10/2016.
//
//

import Foundation

class MessageDelegate {
    var connection: Connection!
    var unreadMessage: String
    var unreadCount: Int
    convenience init(connection:Connection) {
        self.init()
        self.connection = connection
    }
    init() {
        unreadMessage = ""
        unreadCount = 0
    }
}
