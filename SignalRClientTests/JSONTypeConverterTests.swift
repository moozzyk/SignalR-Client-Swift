//
//  JSONSerializationTests.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 3/20/17.
//  Copyright © 2017 Pawel Kadluczka. All rights reserved.
//

import XCTest
@testable import SignalRClient

class JSONTypeConverterTests: XCTestCase {

    let jsonTypeConverter = JSONTypeConverter()

    func testThatConvertToWireTypeConvertsIntTypes() {
        let intValue = 42
        let optionalIntValue: Int? = intValue

        XCTAssertEqual(intValue, try jsonTypeConverter.convertToWireType(obj: intValue) as! Int)

        XCTAssertEqual(optionalIntValue, try jsonTypeConverter.convertToWireType(obj: optionalIntValue) as! Int?)

        XCTAssertEqual([intValue], try jsonTypeConverter.convertToWireType(obj: [intValue]) as! [Int])

        let optionalInts = try! jsonTypeConverter.convertToWireType(obj: [optionalIntValue, nil]) as! [Int?]
        XCTAssertEqual(2, optionalInts.count)
        XCTAssertEqual(optionalIntValue, optionalInts[0])
        XCTAssertNil(optionalInts[1])
    }

    func testThatConvertToWireTypeConvertsDoubleTypes() {
        let doubleValue = 3.14159265
        let optionalDoubleValue: Double? = doubleValue

        XCTAssertEqual(doubleValue, try jsonTypeConverter.convertToWireType(obj: doubleValue) as! Double)

        XCTAssertEqual(optionalDoubleValue, try jsonTypeConverter.convertToWireType(obj: optionalDoubleValue) as! Double?)

        XCTAssertEqual([doubleValue], try jsonTypeConverter.convertToWireType(obj: [doubleValue]) as! [Double])

        let optionalDoubles = try! jsonTypeConverter.convertToWireType(obj: [optionalDoubleValue, nil]) as! [Double?]
        XCTAssertEqual(2, optionalDoubles.count)
        XCTAssertEqual(doubleValue, optionalDoubles[0])
        XCTAssertNil(optionalDoubles[1])
    }

    func testThatConvertToWireTypeConvertsStringTypes() {
        let stringValue = "Hello, World!"
        let optionalStringValue: String? = stringValue

        XCTAssertEqual(stringValue, try jsonTypeConverter.convertToWireType(obj: stringValue) as! String)

        XCTAssertEqual(optionalStringValue, try jsonTypeConverter.convertToWireType(obj: optionalStringValue) as! String?)

        XCTAssertEqual([stringValue], try jsonTypeConverter.convertToWireType(obj: [stringValue]) as! [String])

        let optionalStrings = try! jsonTypeConverter.convertToWireType(obj: [optionalStringValue, nil]) as! [String?]
        XCTAssertEqual(2, optionalStrings.count)
        XCTAssertEqual(stringValue, optionalStrings[0])
        XCTAssertNil(optionalStrings[1])
    }

    func testThatConvertToWireTypeConvertsBoolTypes() {
        let boolValue = true
        let optionalBoolValue: Bool? = boolValue

        XCTAssertEqual(boolValue, try jsonTypeConverter.convertToWireType(obj: boolValue) as! Bool)

        XCTAssertEqual(optionalBoolValue, try jsonTypeConverter.convertToWireType(obj: optionalBoolValue) as! Bool?)

        XCTAssertEqual([boolValue], try jsonTypeConverter.convertToWireType(obj: [boolValue]) as! [Bool])

        let optionalBools = try! jsonTypeConverter.convertToWireType(obj: [optionalBoolValue, nil]) as! [Bool?]
        XCTAssertEqual(2, optionalBools.count)
        XCTAssertEqual(boolValue, optionalBools[0])
        XCTAssertNil(optionalBools[1])
    }

    func testThatConvertToWireTypeConvertsValidJsonTypes() {
        XCTAssertNil(try jsonTypeConverter.convertToWireType(obj: nil))

        let array: NSArray = [42]
        let resultArray = try! jsonTypeConverter.convertToWireType(obj: array) as! NSArray
        XCTAssertEqual(array, resultArray)

        let dictionary: NSDictionary = ["Property" : 42]
        let resultDictionary = try! jsonTypeConverter.convertToWireType(obj: dictionary) as! NSDictionary
        XCTAssertEqual(dictionary, resultDictionary)
    }

    func testThatConvertToWireTypeThrowsForUnhandledTypes() {
        do {
            _ = try jsonTypeConverter.convertToWireType(obj: NSObject())
            XCTFail()

        } catch SignalRError.unsupportedType {
        } catch {
            XCTFail()
        }
    }

    func testThatConvertFromWireTypeHandlesNil() {
        XCTAssertNil(try jsonTypeConverter.convertFromWireType(obj: nil, targetType: Int.self))
        XCTAssertNil(try jsonTypeConverter.convertFromWireType(obj: nil, targetType: Double.self))
        XCTAssertNil(try jsonTypeConverter.convertFromWireType(obj: nil, targetType: String.self))
        XCTAssertNil(try jsonTypeConverter.convertFromWireType(obj: nil, targetType: Bool.self))
        XCTAssertNil(try jsonTypeConverter.convertFromWireType(obj: nil, targetType: [Any?].self))
        XCTAssertNil(try jsonTypeConverter.convertFromWireType(obj: nil, targetType: [String: Any?].self))
    }

    func testThatConvertFromWireTypeHandlesIntValues() {
        let intValue = 42
        let intOptionalValue: Int? = intValue
        XCTAssertEqual(intValue, try jsonTypeConverter.convertFromWireType(obj: intValue, targetType: Int.self))
        XCTAssertEqual(intOptionalValue, try jsonTypeConverter.convertFromWireType(obj: intValue, targetType: Int.self))
        XCTAssertEqual(intValue, try jsonTypeConverter.convertFromWireType(obj: intOptionalValue, targetType: Int.self))
        XCTAssertEqual(intOptionalValue, try jsonTypeConverter.convertFromWireType(obj: intOptionalValue, targetType: Int.self))
    }

    func testThatConvertFromWireTypeHandlesDoubleValues() {
        let doubleValue = 3.14159265
        let doubleOptionalValue: Double? = doubleValue
        XCTAssertEqual(doubleValue, try jsonTypeConverter.convertFromWireType(obj: doubleValue, targetType: Double.self))
        XCTAssertEqual(doubleOptionalValue, try jsonTypeConverter.convertFromWireType(obj: doubleValue, targetType: Double.self))
        XCTAssertEqual(doubleValue, try jsonTypeConverter.convertFromWireType(obj: doubleOptionalValue, targetType: Double.self))
        XCTAssertEqual(doubleOptionalValue, try jsonTypeConverter.convertFromWireType(obj: doubleOptionalValue, targetType: Double.self))
    }

    func testThatConvertFromWireTypeHandlesStringValues() {
        let stringValue = "Hello, World!"
        let stringOptionalValue: String? = stringValue
        XCTAssertEqual(stringValue, try jsonTypeConverter.convertFromWireType(obj: stringValue, targetType: String.self))
        XCTAssertEqual(stringOptionalValue, try jsonTypeConverter.convertFromWireType(obj: stringValue, targetType: String.self))
        XCTAssertEqual(stringValue, try jsonTypeConverter.convertFromWireType(obj: stringOptionalValue, targetType: String.self))
        XCTAssertEqual(stringOptionalValue, try jsonTypeConverter.convertFromWireType(obj: stringOptionalValue, targetType: String.self))
    }

    func testThatConvertFromWireTypeHandlesBoolValues() {
        let boolValue = true
        let boolOptionalValue: Bool? = boolValue
        XCTAssertEqual(boolValue, try jsonTypeConverter.convertFromWireType(obj: boolValue, targetType: Bool.self))
        XCTAssertEqual(boolOptionalValue, try jsonTypeConverter.convertFromWireType(obj: boolValue, targetType: Bool.self))
        XCTAssertEqual(boolValue, try jsonTypeConverter.convertFromWireType(obj: boolOptionalValue, targetType: Bool.self))
        XCTAssertEqual(boolOptionalValue, try jsonTypeConverter.convertFromWireType(obj: boolOptionalValue, targetType: Bool.self))
    }

    func testThatConvertFromWireThrowsForValuesNotMatchingType() {

        do {
            _ = try jsonTypeConverter.convertFromWireType(obj: 42, targetType: Bool.self)
            XCTFail()
        } catch SignalRError.unsupportedType {
        } catch {
            XCTFail()
        }
    }
}
