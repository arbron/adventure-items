//
//  StoryAward.swift
//  
//
//  Created by Jeff Hitchcock on 2020-09-04.
//

import AdventureUtils
import Foundation

struct StoryAward: Codable, Hashable {
    var name: String
    @DecodableDefault.EmptyString var description: String
    var type: AwardType?

    enum AwardType: String, Codable, Hashable {
        case downtime, familiar, pet, property

        var name: String {
            return rawValue.uppercaseFirst()
        }

        var plural: String {
            switch self {
            case .downtime: return "downtime activities"
            case .familiar: return "familiars"
            case .pet: return "pets"
            case .property: return "properties"
            }
        }
    }
}
