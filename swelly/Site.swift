//
//  Site.swift
//  swelly
//
//  Created by ZhangChen on 05/10/2016.
//
//

import Foundation

fileprivate let WLDefaultSiteName = "DefaultSiteName"
fileprivate let WLDefaultAutoReplyString = "DefaultAutoReplyString"
class Site {
    var isDummy: Bool { get { return address.isEmpty }}
    var name = NSLocalizedString(WLDefaultSiteName, comment: "Site")
    var address = ""
    var encoding = GlobalConfig.sharedInstance.defaultEncoding
    var ansiColorKey: ANSIColorKey = GlobalConfig.sharedInstance.defaultANSIColorKey
    var shouldAutoReply: Bool = false
    var shouldDetectDoubleByte = GlobalConfig.sharedInstance.shouldDetectDoubleByte
    var shouldEnableMouse = GlobalConfig.sharedInstance.shouldEnableMouse
    var autoReplyString = NSLocalizedString(WLDefaultAutoReplyString, comment: "Site")
    var proxyAddress = ""
    var proxyType: ProxyType = .None    
}
