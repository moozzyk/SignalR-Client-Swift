//
//  ReactiveHubConnectionEvent.swift
//  SignalRClient
//
//  Created by Eduardo Bocato on 14/07/21.
//  Copyright © 2021 Pawel Kadluczka. All rights reserved.
//

import Foundation

public enum ReactiveHubConnectionEvent: Equatable {
    case opened(HubConnection)
    case gotArgumentExtractor(ArgumentExtractor, forMethod: String)
    case succesfullySentArguments([Encodable], toMethod: String)
    case failedToSendArguments([Encodable], toMethod: String, error: Error) // conexão não vai cair depois de falhar, dependendo do erro pode reconectar e tal...
    case willReconnectAfterFailure(Error) // estranho mas como vai reconectar, não posso terminar o stream...
    case reconnected
    case closed
}

extension ReactiveHubConnectionEvent {
    public static func == (lhs: ReactiveHubConnectionEvent, rhs: ReactiveHubConnectionEvent) -> Bool {
        switch (lhs, rhs) {
        case let (.opened(c1), .opened(c2)):
            return c1.connectionId == c2.connectionId
        case let (.gotArgumentExtractor(ext1, m1), .gotArgumentExtractor(ext2, m2)):
            return ext1 === ext2 && m1 == m2
        case let (.succesfullySentArguments(args1, m1), .succesfullySentArguments(args2, m2)):
            return args1.asJSON() == args2.asJSON() && m1 == m2
        case let (.failedToSendArguments(args1, m1, e1), .failedToSendArguments(args2, m2, e2)):
            return args1.asJSON() == args2.asJSON() && m1 == m2 && e1 as NSError == e2 as NSError
        case let (.willReconnectAfterFailure(e1), .willReconnectAfterFailure(e2)):
            return e1 as NSError == e2 as NSError
        case (.reconnected, .reconnected), (.closed, .closed):
            return true
        default:
            return false
        }
    }
}
