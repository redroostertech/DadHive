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
    private var id: Any?
    private var urlString: Any?
    private var type: Any?
    var url: URL? {
        guard let urlString = self.urlString as? String, let url = URL(string: urlString) else { return nil }
        return url
    }
    required init?(map: Map) { }

    func mapping(map: Map) {
        id <- map["id"]
        urlString <- map["url"]
        type <- map["type"]
    }
}
