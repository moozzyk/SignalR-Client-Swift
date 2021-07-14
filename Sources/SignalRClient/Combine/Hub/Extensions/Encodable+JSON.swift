//
//  Encodable+JSON.swift
//  SignalRClient
//
//  Created by Eduardo Bocato on 14/07/21.
//  Copyright © 2021 Pawel Kadluczka. All rights reserved.
//

import Foundation

extension Encodable {
    func asJSON(
        using enconder: JSONEncoder = .init(),
        jsonSerializer: JSONSerialization.Type = JSONSerialization.self
    ) -> NSDictionary? {
        guard
            let data = try? enconder.encode(self),
            let jsonValue = try? jsonSerializer.jsonObject(with: data, options: .allowFragments)
        else { return nil }
        return jsonValue as? NSDictionary
    }
}

extension Array where Element == Encodable {
    func asJSON(
        using enconder: JSONEncoder = .init(),
        jsonSerializer: JSONSerialization.Type = JSONSerialization.self
    ) -> [NSDictionary] {
        self.compactMap { $0.asJSON(using: enconder, jsonSerializer: jsonSerializer) }
    }
}
