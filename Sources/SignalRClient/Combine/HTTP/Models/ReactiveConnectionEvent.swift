//
//  ReactiveConnectionEvent.swift
//  SignalRClient
//
//  Created by Eduardo Bocato on 13/07/21.
//  Copyright © 2021 Pawel Kadluczka. All rights reserved.
//

import Foundation

public enum ReactiveConnectionEvent: Equatable {
    case opened(Connection)
    case gotData(fromConnection: Connection, data: Data)
    case succesfullySentData(Data)
    case failedToSendData(Data, Error) // conexão não vai cair depois de falhar, dependendo do erro pode reconectar e tal...
    case willReconnectAfterFailure(Error) // estranho mas como vai reconectar, não posso terminar o stream...
    case reconnected
    case closed
}

extension ReactiveConnectionEvent {
    public static func == (lhs: ReactiveConnectionEvent, rhs: ReactiveConnectionEvent) -> Bool {
        switch (lhs, rhs) {
        case let (.opened(c1), .opened(c2)):
            return c1.connectionId == c2.connectionId
        case let (.gotData(c1, d1), .gotData(c2, d2)):
            return c1.connectionId == c2.connectionId && d1 == d2
        case let (.succesfullySentData(d1), .succesfullySentData(d2)):
            return d1 == d2
        case let (.failedToSendData(d1, e1), .failedToSendData(d2, e2)):
            return d1 == d2 && e1 as NSError == e2 as NSError
        case let (.willReconnectAfterFailure(e1), .willReconnectAfterFailure(e2)):
            return e1 as NSError == e2 as NSError
        case (.reconnected, .reconnected), (.closed, .closed):
            return true
        default:
            return false
        }
    }
}
