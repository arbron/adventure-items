//
//  File.swift
//  
//
//  Created by Jeff Hitchcock on 2021-05-23.
//

import Foundation

enum Length: Hashable {
    case flat(Int)
    case range(min: Int, max: Int)
    case multi(count: Int, length: Int)
}

extension Length: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = .flat(try container.decode(Int.self))
        } catch {
            let value = try container.decode(String.self)
            if value.contains("-") {
                let split = value.split(separator: "-")
                guard let min = Int(split[0]), let max = Int(split[1]) else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid range string for length")
                }
                self = .range(min: min, max: max)
            } else if value.contains("x") {
                let split = value.split(separator: "x")
                guard let count = Int(split[0]), let length = Int(split[1]) else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid multi string for length")
                }
                self = .multi(count: count, length: length)
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid length string")
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case let .flat(value):
            try encoder.encodeSingleValue(value)
        case let .range(min, max):
            try encoder.encodeSingleValue("\(min)-\(max)")
        case let .multi(count, length):
            try encoder.encodeSingleValue("\(count)x\(length)")
        }
    }
}
