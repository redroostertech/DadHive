//
//  SDWebImageManagerExt.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/24/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import SDWebImage

class SDWebImageManagerExt {
    static let shared = SDWebImageManagerExt()
    private init() {
        print(" \(kAppName) | SDWebImageManagerExt Handler Initialized")
        SDWebImageManager.shared().imageDownloader?.maxConcurrentDownloads = kMaxConcurrentImageDownloads
    }
}
