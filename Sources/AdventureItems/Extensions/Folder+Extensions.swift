//
//  Folder+Extensions.swift
//  
//
//  Created by Jeff Hitchcock on 2020-09-09.
//

import Files

extension Folder {
    static func packageFolder(path: String) throws -> Folder {
        let codeFile = try File(path: "\(#file)")
        let packageFolder = try codeFile.resolveSwiftPackageFolder()
        return try packageFolder.subfolder(at: path)
    }
}
