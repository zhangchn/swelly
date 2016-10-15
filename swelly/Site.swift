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
    var isDummy: Bool { get { return address.characters.count == 0 }}
    var name = NSLocalizedString(WLDefaultSiteName, comment: "Site")
    var address = ""
    var encoding : Encoding
    var ansiColorKey: ANSIColorKey
    var shouldAutoReply: Bool = false
    var shouldDetectDoubleByte: Bool
    var shouldEnableMouse: Bool
    var autoReplyString = NSLocalizedString(WLDefaultAutoReplyString, comment: "Site")
    var proxyAddress = ""
    var proxyType: ProxyType = .None
    init() {
        encoding = GlobalConfig.sharedInstance.defaultEncoding
        ansiColorKey = GlobalConfig.sharedInstance.defaultANSIColorKey
        shouldEnableMouse = GlobalConfig.sharedInstance.shouldEnableMouse
        shouldDetectDoubleByte = GlobalConfig.sharedInstance.shouldDetectDoubleByte
    }
    
}
