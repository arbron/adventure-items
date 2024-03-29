//
//  String+Extensions.swift
//  
//
//  Created by Jeff Hitchcock on 2020-09-07.
//

import Foundation

// MARK: Prefixes
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
}

// MARK: Counted
extension String {
    func counted(_ count: Int, singularArticle: String = "a", plural: String? = nil) -> String? {
        guard count > 0 else { return nil }
        if count == 1 { return "\(singularArticle) \(self)" }
        return "\(count) \(plural ?? "\(self)s")"
    }
}

// MARK: Transformation
extension String {
    func uppercaseFirst() -> String {
        guard self.count > 2 else { return self.uppercased() }
        var dup = self
        dup.replaceSubrange(
            dup.startIndex...dup.startIndex,
            with: dup[dup.startIndex...dup.startIndex].uppercased())
        return dup
    }
}

// MARK: Localization
extension String {
    static func localizedString(key: String, comment: String = "") -> String {
        return NSLocalizedString(key, bundle: Bundle.module, comment: comment)
    }

    static func localizedStringWithFormat(key: String, comment: String = "", _ arguments: [CVarArg]) -> String {
        return .init(format: String.localizedString(key: key, comment: comment), arguments: arguments)
    }

    func localized(comment: String = "") -> String {
        return .localizedString(key: self, comment: comment)
    }
    
    func localizedAndFormatted(comment: String = "", _ arguments: CVarArg...) -> String {
        return localizedAndFormatted(comment: comment, arguments)
    }

    func localizedAndFormatted(comment: String = "", _ arguments: [CVarArg]) -> String {
        return String.localizedStringWithFormat(key: self, comment: comment, arguments)
    }
}
