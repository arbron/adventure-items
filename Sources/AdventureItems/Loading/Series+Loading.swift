//
//  Series+Loading.swift
//  
//
//  Created by Jeff Hitchcock on 2021-05-28.
//

import Foundation
import Files
import Yams


extension Series {
    static func load() throws -> [Self] {
        let jsonDecoder = JSONDecoder()
        let yamlDecoder = YAMLDecoder()

        let dataFolder = try Folder.packageFolder(path: "Data/Series/")
        var series: [Series] = .init()

        for file in dataFolder.files.recursive {
            switch file.extension {
            case "json":
                series.append(contentsOf: try jsonDecoder.decode([Series].self, from: file.read()))
            case "yaml":
                series.append(contentsOf: try yamlDecoder.decode([Series].self, from: file.readAsString(encodedAs: .utf8)))
            default:
                continue
            }

            fputs("Loading Series from \(file.path(relativeTo: dataFolder))\n", stdout)
        }

        series.sort { (lhs, rhs) in lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending }

        return series
    }

    static func collate(_ series: inout [Series], with adventures: inout [Adventure]) {
        var adventureMap: [String: Adventure] = adventures.reduce(into: [:]) { acc, adventure in
            acc[adventure.code] = adventure
        }

        series = series.map { initialSeries in
            var workingSeries = initialSeries
            workingSeries.adventures = workingSeries.adventures.compactMap { adventureEntry in
                var adventureEntry = adventureEntry
                guard var adventure = adventureMap[adventureEntry.code] else { return nil }

                adventure.series = initialSeries
                adventureEntry.name = adventure.name

                adventureMap[adventureEntry.code] = adventure
                return adventureEntry
            }
            return workingSeries
        }

        adventures = adventures.map { adventure in
            adventureMap[adventure.code] ?? adventure
        }
    }
}
