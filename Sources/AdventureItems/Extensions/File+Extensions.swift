//
//  File+Extensions.swift
//  
//
//  Created by Jeff Hitchcock on 2020-09-05.
//

import Files

internal extension File {
    static func packageFile(path: String) throws -> File {
        let codeFile = try File(path: "\(#file)")
        let packageFolder = try codeFile.resolveSwiftPackageFolder()
        return try packageFolder.file(at: path)
    }

    func resolveSwiftPackageFolder() throws -> Folder {
        var nextFolder = parent

        while let currentFolder = nextFolder {
            if currentFolder.containsFile(named: "Package.swift") {
                return currentFolder
            }

            nextFolder = currentFolder.parent
        }

        throw FileError()
    }
}

struct FileError: Error { }
