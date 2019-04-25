//
//  Media.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/24/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import ObjectMapper
import SDWebImage

class Media: Mappable, CustomStringConvertible {

    private var urlString: String?
    var meta: String?
    var order: Int?

    required init?(map: Map) { }

    func mapping(map: Map) {
        urlString <- map["url"]
        meta <- map["meta"]
        order <- map["order"]

        if let urlString = self.urlString, let url = URL(string: urlString) {
            SDWebImageManager().loadImage(with: url, options: .progressiveDownload, progress: { (time, time2, url) in
//                print("Is loading \(time) with \(time2) for \(url)")
            }) { (image, data, error, cacheType, success, url) in
//                print("A lot happened with the image")
            }
        }
    }

    var url: URL? {
        guard let urlString = self.urlString as? String, let url = URL(string: urlString) else { return nil }
        return url
    }
    
}
