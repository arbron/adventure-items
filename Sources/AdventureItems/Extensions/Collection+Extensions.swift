//
//  File.swift
//  
//
//  Created by Jeff Hitchcock on 2021-05-27.
//

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
