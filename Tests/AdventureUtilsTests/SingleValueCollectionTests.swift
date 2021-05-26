//
//  File.swift
//  
//
//  Created by Jeff Hitchcock on 2021-05-26.
//

import XCTest
@testable import AdventureUtils


struct TestingType: Codable, Equatable {
    @SingleValueCollection var item: [Int]?
}


final class SingleValueCollectionTests: XCTestCase {
    func testEncodeEmptyValue() {
        let object = TestingType()
        let encoded = try! JSONEncoder().encode(object)
        XCTAssertEqual(String(data: encoded, encoding: .utf8)!, #"{}"#)
    }

    func testEncodeSingleValue() {
        let object = TestingType(item: [1])
        let encoded = try! JSONEncoder().encode(object)
        XCTAssertEqual(String(data: encoded, encoding: .utf8)!, #"{"item":1}"#)
    }

    func testEncodeMultipleValues() {
        let object = TestingType(item: [1, 2, 3])
        let encoded = try! JSONEncoder().encode(object)
        XCTAssertEqual(String(data: encoded, encoding: .utf8), #"{"item":[1,2,3]}"#)
    }

    func testDecodeEmptyValue() {
        let data = #"{}"#.data(using: .utf8)!
        let decoded = try? JSONDecoder().decode(TestingType.self, from: data)
        XCTAssertEqual(decoded, TestingType())
    }

    func testDecodeSingleValue() {
        let data = #"{"item":1}"#.data(using: .utf8)!
        let decoded = try! JSONDecoder().decode(TestingType.self, from: data)
        XCTAssertEqual(decoded, TestingType(item: [1]))
    }

    func testDecodeMultipleValues() {
        let data = #"{"item":[1,2,3]}"#.data(using: .utf8)!
        let decoded = try! JSONDecoder().decode(TestingType.self, from: data)
        XCTAssertEqual(decoded, TestingType(item: [1, 2, 3]))
    }
}
