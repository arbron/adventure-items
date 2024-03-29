//
//  Series.swift
//  
//
//  Created by Jeff Hitchcock on 2021-05-28.
//

import AdventureUtils
import Foundation


struct Series: Codable, Hashable {
    var slug: String
    var name: String
    @DecodableDefault.False var includesArticle: Bool

    @DecodableDefault.EmptyString var type: String

    @DecodableDefault.EmptyString var description: String

    var adventures: [Entry]

    struct Entry: Codable, Hashable {
        var position: Int?
        var code: String

        // MARK: Not Included in Data Files
        @DecodableDefault.EmptyString var name: String
        @DecodableDefault.EmptyString var description: String
        @DecodableDefault.EmptyString var path: String
        @DecodableDefault.EmptyList var tiers: [Adventure.Tier]
    }

    // MARK: Not Included in Data Files
    var tiers: Set<Adventure.Tier>?

    var path: String {
        "/series/\(slug)/"
    }
}
