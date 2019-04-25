//
//  URL+Extensions.swift
//  test
//
//  Created by Michael Westbrooks on 11/14/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import Foundation

extension NSURL {
    
//    @objc func isExternalBrowserLink() -> Bool {
//        return self.isHttpRequest() && !self.isOwnedDomain()
//    }
    
    private func isHttpRequest() -> Bool {
        return self.scheme?.hasPrefix("http") ?? false
    }
    
//    private func isOwnedDomain() -> Bool {
//        let ownedHost = NSURL(string: DLEnvironmentsManager.sharedInstance().dotComHost() ?? "")?.host
//        return self.host == ownedHost
//    }
}

extension URL {
    var baseDomain: String? {
        return host?.components(separatedBy: ".").suffix(2).joined(separator: ".")
    }
}

@objc public extension NSURL {
    @objc public var baseDomain: String? {
        return (self as URL).baseDomain
    }
}
