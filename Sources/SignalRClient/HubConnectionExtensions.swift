//
//  HubConnectionExtensions.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 6/11/19.
//

import Foundation

public extension HubConnection {
    func invoke(method: String, invocationDidComplete: @escaping (_ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [], invocationDidComplete: invocationDidComplete)
    }

    func invoke<T1: Encodable>(method: String, _ arg1: T1, invocationDidComplete: @escaping (_ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1], invocationDidComplete: invocationDidComplete)
    }

    func invoke<T1: Encodable, T2: Encodable>(method: String, _ arg1: T1, _ arg2: T2, invocationDidComplete: @escaping (_ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1, arg2], invocationDidComplete: invocationDidComplete)
    }

    func invoke<T1: Encodable, T2: Encodable, T3: Encodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, invocationDidComplete: @escaping (_ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1, arg2, arg3], invocationDidComplete: invocationDidComplete)
    }

    func invoke<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, invocationDidComplete: @escaping (_ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1, arg2, arg3, arg4], invocationDidComplete: invocationDidComplete)
    }

    func invoke<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, T5: Encodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, _ arg5: T5, invocationDidComplete: @escaping (_ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1, arg2, arg3, arg4, arg5], invocationDidComplete: invocationDidComplete)
    }

    func invoke<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, T5: Encodable, T6: Encodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, _ arg5: T5, _ arg6: T6, invocationDidComplete: @escaping (_ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1, arg2, arg3, arg4, arg5, arg6], invocationDidComplete: invocationDidComplete)
    }

    func invoke<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, T5: Encodable, T6: Encodable, T7: Encodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, _ arg5: T5, _ arg6: T6, _ arg7: T7, invocationDidComplete: @escaping (_ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7], invocationDidComplete: invocationDidComplete)
    }

    func invoke<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, T5: Encodable, T6: Encodable, T7: Encodable, T8: Encodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, _ arg5: T5, _ arg6: T6, _ arg7: T7, _ arg8: T8, invocationDidComplete: @escaping (_ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8], invocationDidComplete: invocationDidComplete)
    }

    func invoke<TRes: Decodable>(method: String, resultType: TRes.Type, invocationDidComplete: @escaping (_ result: TRes?, _ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [], resultType: resultType, invocationDidComplete: invocationDidComplete)
    }

    func invoke<T1: Encodable, TRes: Decodable>(method: String, _ arg1: T1, resultType: TRes.Type, invocationDidComplete: @escaping (_ result: TRes?, _ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1], resultType: resultType, invocationDidComplete: invocationDidComplete)
    }

    func invoke<T1: Encodable, T2: Encodable, TRes: Decodable>(method: String, _ arg1: T1, _ arg2: T2, resultType: TRes.Type, invocationDidComplete: @escaping (_ result: TRes?, _ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1, arg2], resultType: resultType, invocationDidComplete: invocationDidComplete)
    }

    func invoke<T1: Encodable, T2: Encodable, T3: Encodable, TRes: Decodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, resultType: TRes.Type, invocationDidComplete: @escaping (_ result: TRes?, _ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1, arg2, arg3], resultType: resultType, invocationDidComplete: invocationDidComplete)
    }

    func invoke<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, TRes: Decodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, resultType: TRes.Type, invocationDidComplete: @escaping (_ result: TRes?, _ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1, arg2, arg3, arg4], resultType: resultType, invocationDidComplete: invocationDidComplete)
    }

    func invoke<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, T5: Encodable, TRes: Decodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, _ arg5: T5, resultType: TRes.Type, invocationDidComplete: @escaping (_ result: TRes?, _ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1, arg2, arg3, arg4, arg5], resultType: resultType, invocationDidComplete: invocationDidComplete)
    }

    func invoke<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, T5: Encodable, T6: Encodable, TRes: Decodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, _ arg5: T5, _ arg6: T6, resultType: TRes.Type, invocationDidComplete: @escaping (_ result: TRes?, _ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1, arg2, arg3, arg4, arg5, arg6], resultType: resultType, invocationDidComplete: invocationDidComplete)
    }

    func invoke<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, T5: Encodable, T6: Encodable, T7: Encodable, TRes: Decodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, _ arg5: T5, _ arg6: T6, _ arg7: T7, resultType: TRes.Type, invocationDidComplete: @escaping (_ result: TRes?, _ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7], resultType: resultType, invocationDidComplete: invocationDidComplete)
    }

    func invoke<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, T5: Encodable, T6: Encodable, T7: Encodable, T8: Encodable, TRes: Decodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, _ arg5: T5, _ arg6: T6, _ arg7: T7, _ arg8: T8, resultType: TRes.Type, invocationDidComplete: @escaping (_ result: TRes?, _ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8], resultType: resultType, invocationDidComplete: invocationDidComplete)
    }

    func on(method: String, callback: @escaping () -> Void) {
        let cb: (ArgumentExtractor) throws -> Void = { argumentExtractor in
            callback()
        }

        self.on(method: method, callback: cb)
    }

    func on<T1: Decodable>(method: String, callback: @escaping (_ arg1: T1) -> Void) {
        let cb: (ArgumentExtractor) throws -> Void = { argumentExtractor in
            let arg1 = try argumentExtractor.getArgument(type: T1.self)
            callback(arg1)
        }

        self.on(method: method, callback: cb)
    }

    func on<T1: Decodable, T2: Decodable>(method: String, callback: @escaping (_ arg1: T1, _ arg2: T2) -> Void) {
        let cb: (ArgumentExtractor) throws -> Void = { argumentExtractor in
            let arg1 = try argumentExtractor.getArgument(type: T1.self)
            let arg2 = try argumentExtractor.getArgument(type: T2.self)
            callback(arg1, arg2)
        }

        self.on(method: method, callback: cb)
    }

    func on<T1: Decodable, T2: Decodable, T3: Decodable>(method: String, callback: @escaping (_ arg1: T1, _ arg2: T2, _ arg3: T3) -> Void) {
        let cb: (ArgumentExtractor) throws -> Void = { argumentExtractor in
            let arg1 = try argumentExtractor.getArgument(type: T1.self)
            let arg2 = try argumentExtractor.getArgument(type: T2.self)
            let arg3 = try argumentExtractor.getArgument(type: T3.self)
            callback(arg1, arg2, arg3)
        }

        self.on(method: method, callback: cb)
    }

    func on<T1: Decodable, T2: Decodable, T3: Decodable, T4: Decodable>(method: String, callback: @escaping (_ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4) -> Void) {
        let cb: (ArgumentExtractor) throws -> Void = { argumentExtractor in
            let arg1 = try argumentExtractor.getArgument(type: T1.self)
            let arg2 = try argumentExtractor.getArgument(type: T2.self)
            let arg3 = try argumentExtractor.getArgument(type: T3.self)
            let arg4 = try argumentExtractor.getArgument(type: T4.self)
            callback(arg1, arg2, arg3, arg4)
        }

        self.on(method: method, callback: cb)
    }

    func on<T1: Decodable, T2: Decodable, T3: Decodable, T4: Decodable, T5: Decodable>(method: String, callback: @escaping (_ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, _ arg5: T5) -> Void) {
        let cb: (ArgumentExtractor) throws -> Void = { argumentExtractor in
            let arg1 = try argumentExtractor.getArgument(type: T1.self)
            let arg2 = try argumentExtractor.getArgument(type: T2.self)
            let arg3 = try argumentExtractor.getArgument(type: T3.self)
            let arg4 = try argumentExtractor.getArgument(type: T4.self)
            let arg5 = try argumentExtractor.getArgument(type: T5.self)

            callback(arg1, arg2, arg3, arg4, arg5)
        }

        self.on(method: method, callback: cb)
    }

    func on<T1: Decodable, T2: Decodable, T3: Decodable, T4: Decodable, T5: Decodable, T6: Decodable>(method: String, callback: @escaping (_ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, _ arg5: T5, _ arg6: T6) -> Void) {
        let cb: (ArgumentExtractor) throws -> Void = { argumentExtractor in
            let arg1 = try argumentExtractor.getArgument(type: T1.self)
            let arg2 = try argumentExtractor.getArgument(type: T2.self)
            let arg3 = try argumentExtractor.getArgument(type: T3.self)
            let arg4 = try argumentExtractor.getArgument(type: T4.self)
            let arg5 = try argumentExtractor.getArgument(type: T5.self)
            let arg6 = try argumentExtractor.getArgument(type: T6.self)

            callback(arg1, arg2, arg3, arg4, arg5, arg6)
        }

        self.on(method: method, callback: cb)
    }

    func on<T1: Decodable, T2: Decodable, T3: Decodable, T4: Decodable, T5: Decodable, T6: Decodable, T7: Decodable>(method: String, callback: @escaping (_ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, _ arg5: T5, _ arg6: T6, _ arg7: T7) -> Void) {
        let cb: (ArgumentExtractor) throws -> Void = { argumentExtractor in
            let arg1 = try argumentExtractor.getArgument(type: T1.self)
            let arg2 = try argumentExtractor.getArgument(type: T2.self)
            let arg3 = try argumentExtractor.getArgument(type: T3.self)
            let arg4 = try argumentExtractor.getArgument(type: T4.self)
            let arg5 = try argumentExtractor.getArgument(type: T5.self)
            let arg6 = try argumentExtractor.getArgument(type: T6.self)
            let arg7 = try argumentExtractor.getArgument(type: T7.self)

            callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
        }

        self.on(method: method, callback: cb)
    }

    func on<T1: Decodable, T2: Decodable, T3: Decodable, T4: Decodable, T5: Decodable, T6: Decodable, T7: Decodable, T8: Decodable>(method: String, callback: @escaping (_ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, _ arg5: T5, _ arg6: T6, _ arg7: T7, _ arg8: T8) -> Void) {
        let cb: (ArgumentExtractor) throws -> Void = { argumentExtractor in
            let arg1 = try argumentExtractor.getArgument(type: T1.self)
            let arg2 = try argumentExtractor.getArgument(type: T2.self)
            let arg3 = try argumentExtractor.getArgument(type: T3.self)
            let arg4 = try argumentExtractor.getArgument(type: T4.self)
            let arg5 = try argumentExtractor.getArgument(type: T5.self)
            let arg6 = try argumentExtractor.getArgument(type: T6.self)
            let arg7 = try argumentExtractor.getArgument(type: T7.self)
            let arg8 = try argumentExtractor.getArgument(type: T8.self)
            callback(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
        }

        self.on(method: method, callback: cb)
    }
}
