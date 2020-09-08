//
//  JSONDecoder+Extensions.swift
//  
//
//  Created by Jeff Hitchcock on 2020-09-06.
//

import Foundation
import Files

extension JSONDecoder {
    func decode<T>(_ type: [T].Type, files: [File]) throws -> [T] where T: Decodable {
        var objects: [T] = []
        for file in files {
            objects.append(contentsOf: try self.decode([T].self, from: Data(contentsOf: file.url)))
        }
        return objects
    }
}
