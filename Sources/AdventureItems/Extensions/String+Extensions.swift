//
//  String+Extensions.swift
//  
//
//  Created by Jeff Hitchcock on 2020-09-07.
//

import Foundation

extension String {
    func hasPrefixes(_ prefixes: String...) -> Bool {
        for prefix in prefixes {
            if self.hasPrefix(prefix) { return true }
        }
        return false
    }

    func removePrefix(_ prefix: String) -> Substring? {
        guard self.hasPrefix(prefix) else { return nil }
        return self.dropFirst(prefix.count)
    }

    func removePrefixes(_ prefixes: String...) -> Substring? {
        for prefix in prefixes {
            if let result = removePrefix(prefix) {
                return result
            }
        }
        return nil
    }

    func counted(_ count: Int, singularArticle: String = "a", plural: String? = nil) -> String? {
        guard count > 0 else { return nil }
        if count == 1 { return "\(singularArticle) \(self)" }
        return "\(count) \(plural ?? "\(self)s")"
    }
}
