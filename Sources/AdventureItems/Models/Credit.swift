//
//  File.swift
//  
//
//  Created by Jeff Hitchcock on 2021-05-23.
//

import Foundation
import AdventureUtils

struct Credit: Codable, Hashable {
    var name: String
    var role: String
    @DecodableDefault.False var key: Bool
}
