//
//  Media.swift
//  DadHive
//
//  Created by Michael Westbrooks on 12/24/18.
//  Copyright © 2018 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import ObjectMapper

class Media: Mappable, CustomStringConvertible {

    private var urlString: Any?
    var meta: String?

    required init?(map: Map) { }

    func mapping(map: Map) {
        urlString <- map["url"]
        meta <- map["meta"]
    }

    var url: URL? {
        guard let urlString = self.urlString as? String, let url = URL(string: urlString) else { return nil }
        return url
    }
}
