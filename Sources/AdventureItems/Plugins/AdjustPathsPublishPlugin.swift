//
//  AdjustPathsPublishPlugin.swift
//  
//
//  Created by Jeff Hitchcock on 2020-09-05.
//
//  Adapted from: https://github.com/Deub27/LocalWebsitePublishPlugin
//

import Foundation
import Publish
import Files

public extension Plugin {
    static func prependAllPaths(_ path: String) throws -> Self {
        Plugin(name: "Prepend Paths") { context in
            let outputFolder = try context.outputFolder(at: "")
            try Plugin.scanFiles(prepending: path, outputFolder: outputFolder)
        }
    }

    private static func scanFiles(in path: Path = "", prepending: String, outputFolder: Folder) throws {
        let currentFolder = try outputFolder.subfolder(at: path.string)
        let files = currentFolder
            .files
            .filter({ $0.extension == "html" })
        
        try files.forEach({ (file) in
            try Plugin.prependPaths(file, path: prepending)
        })
        
        let subfolders = currentFolder.subfolders
        try subfolders.forEach { (folder) in
            let path = folder.path(relativeTo: outputFolder)
            try Plugin.scanFiles(in: Path(path), prepending: prepending, outputFolder: outputFolder)
        }
        
    }

    private static func prependPaths(_ file: File, path: String) throws {
        var html = try file.readAsString()
        html = try html.replaceFiles(prepending: path, for: "href")
        html = try html.replaceFiles(prepending: path, for: "src")
        html = try html.replacePaths(prepending: path)
        try file.write(html)
    }
}

extension String {
    func replaceFiles(prepending: String, for tag: String) throws -> String {
        var output = self
        let pattern = "\(tag)=\"/([\\/a-zA-Z0-9_-]*\\.{1}[a-zA-Z0-9]*)\""
        let regex = try NSRegularExpression(pattern: pattern, options: [])

        let nsrange = NSRange(self.startIndex..<self.endIndex, in: self)

        let matches = regex.matches(in: self, options: [], range: nsrange)

        for match in matches where match.numberOfRanges == 2 {
            if let keyRange = Range(match.range(at: 1), in: self) {
                let key = String(self[keyRange])
                output = output.replacingOccurrences(of: "\(tag)=\"/\(key)\"", with: "\(tag)=\"/\(prepending)\(key)\"")
            }
        }

        return output
    }

    func replacePaths(prepending: String) throws -> String {
        var output = self
        let pattern = #"href="/([\/a-zA-Z0-9_-]*)""#
        let regex = try NSRegularExpression(pattern: pattern, options: [])

        let nsrange = NSRange(self.startIndex..<self.endIndex, in: self)

        let matches = regex.matches(in: self, options: [], range: nsrange)

        for match in matches where match.numberOfRanges == 2 {
            if let keyRange = Range(match.range(at: 1), in: self) {
                let key = String(self[keyRange])
                if key.count == 0 {
                    output = output.replacingOccurrences(of: "href=\"/\(key)\"", with: "href=\"/\(prepending)index.html\"")
                } else {
                    output = output.replacingOccurrences(of: "href=\"/\(key)\"", with: "href=\"/\(prepending)\(key)/index.html\"")
                }

            }
        }

        return output
    }
}
