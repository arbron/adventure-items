//
//  File.swift
//  
//
//  Created by Jeff Hitchcock on 2021-05-23.
//

import Foundation

struct Credit: Codable, Hashable {
    var name: String
    var role: String
    @DecodableDefault.False var key: Bool
}
