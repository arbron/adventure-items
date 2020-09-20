//
//  StoryAward.swift
//  
//
//  Created by Jeff Hitchcock on 2020-09-04.
//

import Foundation

struct StoryAward: Codable, Hashable {
    var name: String
    var description: String
    @DecodableDefault.False var downtime: Bool
    @DecodableDefault.False var pet: Bool
}
