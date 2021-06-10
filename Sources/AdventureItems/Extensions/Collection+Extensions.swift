//
//  Collection+Extensions.swift
//  
//
//  Created by Jeff Hitchcock on 2021-05-27.
//

import Foundation


extension Collection {
    func joined(seperator: String = "") -> String {
        guard !isEmpty else { return "" }
        var join = ""
        for element in self {
            if join != "" {
                join.append(seperator)
            }
            join.append("\(element)")
        }
        return join
    }
}


extension Collection where Element == Adventure.Tier {
    func localizedString() -> String? {
        if self.count == 4 {
            return "All Tiers".localized()
        }

        let numberFormatter = NumberFormatter()
        numberFormatter.formattingContext = .listItem
        numberFormatter.numberStyle = .none // TODO: Maybe switch to ordinal format?
        let listFormatter = ListFormatter()
        listFormatter.itemFormatter = numberFormatter

        let sorted = self.sorted { $0.rawValue < $1.rawValue }
        if let formattedTiers = listFormatter.string(from: sorted.map(\.rawValue)) {
            let key = "\(self.count == 1 ? "Tier" : "Tiers") <Tier List>" // TODO: Figure out how to do this localization properly
            return key.localizedAndFormatted(formattedTiers)
        }

        return nil
    }
}

