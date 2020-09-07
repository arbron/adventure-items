//
//  File.swift
//  
//
//  Created by Jeff Hitchcock on 2020-09-07.
//

import Foundation

extension String {
    func removePrefix(_ prefix: String) -> Substring? {
        guard self.hasPrefix(prefix) else { return nil }
        return self.dropFirst(prefix.count)
    }
}
