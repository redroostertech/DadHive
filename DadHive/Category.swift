//
//  Category.swift
//  DadHive
//
//  Created by Michael Westbrooks on 9/11/19.
//  Copyright © 2019 RedRooster Technologies Inc. All rights reserved.
//

import Foundation
import ObjectMapper
import RRoostSDK

class Categories: Mappable {
  var count: Int?
  var categories: [Category]?

  required init?(map: Map) { }

  func mapping(map: Map) {
    self.count <- map["count"]
    self.categories <- map["categories"]
  }
}

class Category: Mappable {
  var id: String?
  var label: String?

  required init?(map: Map) { }

  func mapping(map: Map) {
    self.id <- map["id"]
    self.label <- map["label"]
  }
}
