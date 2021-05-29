//
//  Adventure+Loading.swift
//  
//
//  Created by Jeff Hitchcock on 2021-05-28.
//

import Foundation
import Files
import Yams


extension Adventure {
    static func load() throws -> [Self] {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(.iso8601date)
        let yamlDecoder = YAMLDecoder()

        let dataFolder = try Folder.packageFolder(path: "Data/Adventures/")
        var adventures: [Adventure] = .init()

        for file in dataFolder.files.recursive {
            switch file.extension {
            case "json":
                adventures.append(contentsOf: try jsonDecoder.decode([Adventure].self, from: file.read()))
            case "yaml":
                adventures.append(contentsOf: try yamlDecoder.decode([Adventure].self, from: file.readAsString(encodedAs: .utf8)))
            default:
                continue
            }

            fputs("Loading Adventures from \(file.path(relativeTo: dataFolder))\n", stdout)
        }

        adventures.sort { (lhs, rhs) in lhs.code.localizedStandardCompare(rhs.code) == .orderedAscending }

        return adventures
    }
}
