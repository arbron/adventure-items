//
//  File.swift
//  
//
//  Created by Jeff Hitchcock on 2021-05-25.
//

@propertyWrapper
public struct SingleValueCollection<Value: Collection> {
    public var wrappedValue: Value?

    public init(wrappedValue: Value?) {
        self.wrappedValue = wrappedValue
    }
}

extension SingleValueCollection: Equatable where Value: Equatable {}
extension SingleValueCollection: Hashable where Value: Hashable {}

extension SingleValueCollection: Encodable where Value: Encodable, Value.Element: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        guard let wrappedValue = wrappedValue else { return }
        if wrappedValue.count == 1, let value = wrappedValue.first {
            try container.encode(value)
        } else {
            try container.encode(wrappedValue)
        }
    }
}

extension SingleValueCollection: Decodable where Value: Decodable, Value.Element: Decodable {
    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.singleValueContainer()
            do {
                wrappedValue = [try container.decode(Value.Element.self)] as! Value?
            } catch {
                wrappedValue = try container.decode(Value?.self)
            }
        } catch {
            wrappedValue = nil
        }
    }
}

extension SingleValueCollection: ExpressibleByArrayLiteral where Value: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Value.Element...) {
        guard !elements.isEmpty else {
            wrappedValue = nil
            return
        }
        wrappedValue = elements as! Value?
    }
}

extension KeyedEncodingContainer {
    public mutating func encode<T: Collection & Encodable>(_ value: SingleValueCollection<T>, forKey key: Key) throws where T.Element: Encodable {
        guard let wrappedValue = value.wrappedValue else { return }
        if wrappedValue.count == 1, let value = wrappedValue.first {
            try encode(value, forKey: key)
        } else {
            try encode(wrappedValue, forKey: key)
        }
    }
}

extension KeyedDecodingContainer {
    public func decode<T: Collection & Decodable>(_ type: SingleValueCollection<T>.Type,
                                                  forKey key: Key) throws -> SingleValueCollection<T> where T.Element: Decodable {
        do {
            return SingleValueCollection(wrappedValue: ([try decode(T.Element.self, forKey: key)] as! T))
        } catch {
            return SingleValueCollection(wrappedValue: try decodeIfPresent(T.self, forKey: key))
        }
    }
}
