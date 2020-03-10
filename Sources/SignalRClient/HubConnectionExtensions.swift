//
//  HubConnectionExtensions.swift
//  SignalRClient
//
//  Created by Pawel Kadluczka on 6/11/19.
//

import Foundation

public extension HubConnection {
    /**
     Invokes a server side hub method with no parameters that does not return a result.

     The `invoke` method invokes a server side hub method and returns the status of the invocation. The `error` parameter of the `invocationDidComplete` callback will be `nil` if the invocation was successful. Otherwise it will contain failue details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not connected when invoking the method), or remote - e.g. the hub method on the server side threw an exception.

     - parameter method: the name of the server side hub method to invoke
     - parameter invocationDidComplete: a completion handler that will be invoked when the invocation has completed
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     */
    func invoke(method: String, invocationDidComplete: @escaping (_ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [], invocationDidComplete: invocationDidComplete)
    }

    /**
     Invokes a server side hub method with 1 parameter that does not return a result.

     The `invoke` method invokes a server side hub method and returns the status of the invocation. The `error` parameter of the `invocationDidComplete` callback will be `nil` if the invocation was successful. Otherwise it will contain failue details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not connected when invoking the method), or remote - e.g. the hub method on the server side threw an exception.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter invocationDidComplete: a completion handler that will be invoked when the invocation has completed
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     */
    func invoke<T1: Encodable>(method: String, _ arg1: T1, invocationDidComplete: @escaping (_ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1], invocationDidComplete: invocationDidComplete)
    }

    /**
     Invokes a server side hub method with 2 parameters that does not return a result.

     The `invoke` method invokes a server side hub method and returns the status of the invocation. The `error` parameter of the `invocationDidComplete` callback will be `nil` if the invocation was successful. Otherwise it will contain failue details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not connected when invoking the method), or remote - e.g. the hub method on the server side threw an exception.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter arg2: second argument of the hub method
     - parameter invocationDidComplete: a completion handler that will be invoked when the invocation has completed
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     */
    func invoke<T1: Encodable, T2: Encodable>(method: String, _ arg1: T1, _ arg2: T2, invocationDidComplete: @escaping (_ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1, arg2], invocationDidComplete: invocationDidComplete)
    }

    /**
     Invokes a server side hub method with 3 parameters that does not return a result.

     The `invoke` method invokes a server side hub method and returns the status of the invocation. The `error` parameter of the `invocationDidComplete` callback will be `nil` if the invocation was successful. Otherwise it will contain failue details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not connected when invoking the method), or remote - e.g. the hub method on the server side threw an exception.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter arg2: second argument of the hub method
     - parameter arg3: third argument of the hub method
     - parameter invocationDidComplete: a completion handler that will be invoked when the invocation has completed
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     */
    func invoke<T1: Encodable, T2: Encodable, T3: Encodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, invocationDidComplete: @escaping (_ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1, arg2, arg3], invocationDidComplete: invocationDidComplete)
    }

    /**
     Invokes a server side hub method with 4 parameters that does not return a result.

     The `invoke` method invokes a server side hub method and returns the status of the invocation. The `error` parameter of the `invocationDidComplete` callback will be `nil` if the invocation was successful. Otherwise it will contain failue details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not connected when invoking the method), or remote - e.g. the hub method on the server side threw an exception.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter arg2: second argument of the hub method
     - parameter arg3: third argument of the hub method
     - parameter arg4: fourth argument of the hub method
     - parameter invocationDidComplete: a completion handler that will be invoked when the invocation has completed
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     */
    func invoke<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, invocationDidComplete: @escaping (_ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1, arg2, arg3, arg4], invocationDidComplete: invocationDidComplete)
    }

    /**
     Invokes a server side hub method with 5 parameters that does not return a result.

     The `invoke` method invokes a server side hub method and returns the status of the invocation. The `error` parameter of the `invocationDidComplete` callback will be `nil` if the invocation was successful. Otherwise it will contain failue details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not connected when invoking the method), or remote - e.g. the hub method on the server side threw an exception.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter arg2: second argument of the hub method
     - parameter arg3: third argument of the hub method
     - parameter arg4: fourth argument of the hub method
     - parameter arg5: fifth argument of the hub method
     - parameter invocationDidComplete: a completion handler that will be invoked when the invocation has completed
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     */
    func invoke<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, T5: Encodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, _ arg5: T5, invocationDidComplete: @escaping (_ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1, arg2, arg3, arg4, arg5], invocationDidComplete: invocationDidComplete)
    }

    /**
     Invokes a server side hub method with 6 parameters that does not return a result.

     The `invoke` method invokes a server side hub method and returns the status of the invocation. The `error` parameter of the `invocationDidComplete` callback will be `nil` if the invocation was successful. Otherwise it will contain failue details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not connected when invoking the method), or remote - e.g. the hub method on the server side threw an exception.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter arg2: second argument of the hub method
     - parameter arg3: third argument of the hub method
     - parameter arg4: fourth argument of the hub method
     - parameter arg5: fifth argument of the hub method
     - parameter arg6: sixth argument of the hub method
     - parameter invocationDidComplete: a completion handler that will be invoked when the invocation has completed
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     */
    func invoke<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, T5: Encodable, T6: Encodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, _ arg5: T5, _ arg6: T6, invocationDidComplete: @escaping (_ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1, arg2, arg3, arg4, arg5, arg6], invocationDidComplete: invocationDidComplete)
    }

    /**
     Invokes a server side hub method with 7 parameters that does not return a result.

     The `invoke` method invokes a server side hub method and returns the status of the invocation. The `error` parameter of the `invocationDidComplete` callback will be `nil` if the invocation was successful. Otherwise it will contain failue details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not connected when invoking the method), or remote - e.g. the hub method on the server side threw an exception.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter arg2: second argument of the hub method
     - parameter arg3: third argument of the hub method
     - parameter arg4: fourth argument of the hub method
     - parameter arg5: fifth argument of the hub method
     - parameter arg6: sixth argument of the hub method
     - parameter arg7: seventh argument of the hub method
     - parameter invocationDidComplete: a completion handler that will be invoked when the invocation has completed
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     */
    func invoke<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, T5: Encodable, T6: Encodable, T7: Encodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, _ arg5: T5, _ arg6: T6, _ arg7: T7, invocationDidComplete: @escaping (_ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7], invocationDidComplete: invocationDidComplete)
    }

    /**
     Invokes a server side hub method with 8 parameters that does not return a result.

     The `invoke` method invokes a server side hub method and returns the status of the invocation. The `error` parameter of the `invocationDidComplete` callback will be `nil` if the invocation was successful. Otherwise it will contain failue details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not connected when invoking the method), or remote - e.g. the hub method on the server side threw an exception.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter arg2: second argument of the hub method
     - parameter arg3: third argument of the hub method
     - parameter arg4: fourth argument of the hub method
     - parameter arg5: fifth argument of the hub method
     - parameter arg6: sixth argument of the hub method
     - parameter arg7: seventh argument of the hub method
     - parameter arg8: eighth argument of the hub method
     - parameter invocationDidComplete: a completion handler that will be invoked when the invocation has completed
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     */
    func invoke<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, T5: Encodable, T6: Encodable, T7: Encodable, T8: Encodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, _ arg5: T5, _ arg6: T6, _ arg7: T7, _ arg8: T8, invocationDidComplete: @escaping (_ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8], invocationDidComplete: invocationDidComplete)
    }

    /**
     Invokes a server side hub method with no parameters that returns a result.

     The `invoke` method invokes a server side hub method and returns the result of the invocation or error. If the server side method completed successfully the `invocationDidComplete` callback will be called with the result returned by the method and `nil` error. Otherwise the `error` parameter of the `invocationDidComplete` callback will contain failure details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not started when invoking the method), or remote - e.g. the hub method threw an error.

     - parameter method: the name of the server side hub method to invoke
     - parameter resultType: the type of the result returned by the hub method
     - parameter invocationDidComplete:  a completion handler that will be invoked when the invocation has completed
     - parameter result: the result returned by the hub method
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     */
    func invoke<TRes: Decodable>(method: String, resultType: TRes.Type, invocationDidComplete: @escaping (_ result: TRes?, _ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [], resultType: resultType, invocationDidComplete: invocationDidComplete)
    }

    /**
     Invokes a server side hub method with 1 parameter that returns a result.

     The `invoke` method invokes a server side hub method and returns the result of the invocation or error. If the server side method completed successfully the `invocationDidComplete` callback will be called with the result returned by the method and `nil` error. Otherwise the `error` parameter of the `invocationDidComplete` callback will contain failure details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not started when invoking the method), or remote - e.g. the hub method threw an error.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter resultType: the type of the result returned by the hub method
     - parameter invocationDidComplete:  a completion handler that will be invoked when the invocation has completed
     - parameter result: the result returned by the hub method
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     */
    func invoke<T1: Encodable, TRes: Decodable>(method: String, _ arg1: T1, resultType: TRes.Type, invocationDidComplete: @escaping (_ result: TRes?, _ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1], resultType: resultType, invocationDidComplete: invocationDidComplete)
    }

    /**
     Invokes a server side hub method with 2 parameters that returns a result.

     The `invoke` method invokes a server side hub method and returns the result of the invocation or error. If the server side method completed successfully the `invocationDidComplete` callback will be called with the result returned by the method and `nil` error. Otherwise the `error` parameter of the `invocationDidComplete` callback will contain failure details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not started when invoking the method), or remote - e.g. the hub method threw an error.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter arg2: second argument of the hub method
     - parameter resultType: the type of the result returned by the hub method
     - parameter invocationDidComplete:  a completion handler that will be invoked when the invocation has completed
     - parameter result: the result returned by the hub method
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     */
    func invoke<T1: Encodable, T2: Encodable, TRes: Decodable>(method: String, _ arg1: T1, _ arg2: T2, resultType: TRes.Type, invocationDidComplete: @escaping (_ result: TRes?, _ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1, arg2], resultType: resultType, invocationDidComplete: invocationDidComplete)
    }

    /**
     Invokes a server side hub method with 3 parameters that returns a result.

     The `invoke` method invokes a server side hub method and returns the result of the invocation or error. If the server side method completed successfully the `invocationDidComplete` callback will be called with the result returned by the method and `nil` error. Otherwise the `error` parameter of the `invocationDidComplete` callback will contain failure details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not started when invoking the method), or remote - e.g. the hub method threw an error.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter arg2: second argument of the hub method
     - parameter arg3: third argument of the hub method
     - parameter resultType: the type of the result returned by the hub method
     - parameter invocationDidComplete:  a completion handler that will be invoked when the invocation has completed
     - parameter result: the result returned by the hub method
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     */
    func invoke<T1: Encodable, T2: Encodable, T3: Encodable, TRes: Decodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, resultType: TRes.Type, invocationDidComplete: @escaping (_ result: TRes?, _ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1, arg2, arg3], resultType: resultType, invocationDidComplete: invocationDidComplete)
    }

    /**
     Invokes a server side hub method with 4 parameters that returns a result.

     The `invoke` method invokes a server side hub method and returns the result of the invocation or error. If the server side method completed successfully the `invocationDidComplete` callback will be called with the result returned by the method and `nil` error. Otherwise the `error` parameter of the `invocationDidComplete` callback will contain failure details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not started when invoking the method), or remote - e.g. the hub method threw an error.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter arg2: second argument of the hub method
     - parameter arg3: third argument of the hub method
     - parameter arg4: fourth argument of the hub method
     - parameter resultType: the type of the result returned by the hub method
     - parameter invocationDidComplete:  a completion handler that will be invoked when the invocation has completed
     - parameter result: the result returned by the hub method
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     */
    func invoke<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, TRes: Decodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, resultType: TRes.Type, invocationDidComplete: @escaping (_ result: TRes?, _ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1, arg2, arg3, arg4], resultType: resultType, invocationDidComplete: invocationDidComplete)
    }

    /**
     Invokes a server side hub method with 5 parameters that returns a result.

     The `invoke` method invokes a server side hub method and returns the result of the invocation or error. If the server side method completed successfully the `invocationDidComplete` callback will be called with the result returned by the method and `nil` error. Otherwise the `error` parameter of the `invocationDidComplete` callback will contain failure details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not started when invoking the method), or remote - e.g. the hub method threw an error.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter arg2: second argument of the hub method
     - parameter arg3: third argument of the hub method
     - parameter arg4: fourth argument of the hub method
     - parameter arg5: fifth argument of the hub method
     - parameter resultType: the type of the result returned by the hub method
     - parameter invocationDidComplete:  a completion handler that will be invoked when the invocation has completed
     - parameter result: the result returned by the hub method
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     */
    func invoke<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, T5: Encodable, TRes: Decodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, _ arg5: T5, resultType: TRes.Type, invocationDidComplete: @escaping (_ result: TRes?, _ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1, arg2, arg3, arg4, arg5], resultType: resultType, invocationDidComplete: invocationDidComplete)
    }

    /**
     Invokes a server side hub method with 6 parameters that returns a result.

     The `invoke` method invokes a server side hub method and returns the result of the invocation or error. If the server side method completed successfully the `invocationDidComplete` callback will be called with the result returned by the method and `nil` error. Otherwise the `error` parameter of the `invocationDidComplete` callback will contain failure details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not started when invoking the method), or remote - e.g. the hub method threw an error.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter arg2: second argument of the hub method
     - parameter arg3: third argument of the hub method
     - parameter arg4: fourth argument of the hub method
     - parameter arg5: fifth argument of the hub method
     - parameter arg6: sixth argument of the hub method
     - parameter resultType: the type of the result returned by the hub method
     - parameter invocationDidComplete:  a completion handler that will be invoked when the invocation has completed
     - parameter result: the result returned by the hub method
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     */
    func invoke<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, T5: Encodable, T6: Encodable, TRes: Decodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, _ arg5: T5, _ arg6: T6, resultType: TRes.Type, invocationDidComplete: @escaping (_ result: TRes?, _ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1, arg2, arg3, arg4, arg5, arg6], resultType: resultType, invocationDidComplete: invocationDidComplete)
    }

    /**
     Invokes a server side hub method with 7 parameters that returns a result.

     The `invoke` method invokes a server side hub method and returns the result of the invocation or error. If the server side method completed successfully the `invocationDidComplete` callback will be called with the result returned by the method and `nil` error. Otherwise the `error` parameter of the `invocationDidComplete` callback will contain failure details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not started when invoking the method), or remote - e.g. the hub method threw an error.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter arg2: second argument of the hub method
     - parameter arg3: third argument of the hub method
     - parameter arg4: fourth argument of the hub method
     - parameter arg5: fifth argument of the hub method
     - parameter arg6: sixth argument of the hub method
     - parameter arg7: seventh argument of the hub method
     - parameter resultType: the type of the result returned by the hub method
     - parameter invocationDidComplete:  a completion handler that will be invoked when the invocation has completed
     - parameter result: the result returned by the hub method
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     */
    func invoke<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, T5: Encodable, T6: Encodable, T7: Encodable, TRes: Decodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, _ arg5: T5, _ arg6: T6, _ arg7: T7, resultType: TRes.Type, invocationDidComplete: @escaping (_ result: TRes?, _ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7], resultType: resultType, invocationDidComplete: invocationDidComplete)
    }

    /**
     Invokes a server side hub method with 8 parameters that returns a result.

     The `invoke` method invokes a server side hub method and returns the result of the invocation or error. If the server side method completed successfully the `invocationDidComplete` callback will be called with the result returned by the method and `nil` error. Otherwise the `error` parameter of the `invocationDidComplete` callback will contain failure details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not started when invoking the method), or remote - e.g. the hub method threw an error.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter arg2: second argument of the hub method
     - parameter arg3: third argument of the hub method
     - parameter arg4: fourth argument of the hub method
     - parameter arg5: fifth argument of the hub method
     - parameter arg6: sixth argument of the hub method
     - parameter arg7: seventh argument of the hub method
     - parameter arg8: eighth argument of the hub method
     - parameter resultType: the type of the result returned by the hub method
     - parameter invocationDidComplete:  a completion handler that will be invoked when the invocation has completed
     - parameter result: the result returned by the hub method
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     */
    func invoke<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, T5: Encodable, T6: Encodable, T7: Encodable, T8: Encodable, TRes: Decodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, _ arg5: T5, _ arg6: T6, _ arg7: T7, _ arg8: T8, resultType: TRes.Type, invocationDidComplete: @escaping (_ result: TRes?, _ error: Error?) -> Void) {
        self.invoke(method: method, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8], resultType: resultType, invocationDidComplete: invocationDidComplete)
    }

    /**
     Invokes a server side hub method without parameters in a fire-and-forget manner.

     When a hub method is invoked in a fire-and-forget manner the client never receives any result of the invocation nor is notified about the invocation status.

     - parameter method: the name of the server side hub method to invoke
     - parameter sendDidComplete: a completion handler that allows to track whether the client was able to successfully initiate the invocation. If the invocation was successfully initiated the `error` will be `nil`. Otherwise the `error` will contain failure details
     - parameter error: contains failure details if the invocation was not initiated successfully. `nil` otherwise
     */
    func send(method: String, sendDidComplete: @escaping (_ error: Error?) -> Void = {_ in}) {
        self.send(method: method, arguments: [], sendDidComplete: sendDidComplete)
    }

    /**
     Invokes a server side hub method with 1 parameter in a fire-and-forget manner.

     When a hub method is invoked in a fire-and-forget manner the client never receives any result of the invocation nor is notified about the invocation status.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter sendDidComplete: a completion handler that allows to track whether the client was able to successfully initiate the invocation. If the invocation was successfully initiated the `error` will be `nil`. Otherwise the `error` will contain failure details
     - parameter error: contains failure details if the invocation was not initiated successfully. `nil` otherwise
     */
    func send<T1: Encodable>(method: String, _ arg1: T1, sendDidComplete: @escaping (_ error: Error?) -> Void = {_ in}) {
        self.send(method: method, arguments: [arg1], sendDidComplete: sendDidComplete)
    }

    /**
     Invokes a server side hub method with 2 parameters in a fire-and-forget manner.

     When a hub method is invoked in a fire-and-forget manner the client never receives any result of the invocation nor is notified about the invocation status.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter arg2: second argument of the hub method
     - parameter sendDidComplete: a completion handler that allows to track whether the client was able to successfully initiate the invocation. If the invocation was successfully initiated the `error` will be `nil`. Otherwise the `error` will contain failure details
     - parameter error: contains failure details if the invocation was not initiated successfully. `nil` otherwise
     */
    func send<T1: Encodable, T2: Encodable>(method: String, _ arg1: T1, _ arg2: T2, sendDidComplete: @escaping (_ error: Error?) -> Void = {_ in}) {
        self.send(method: method, arguments: [arg1, arg2], sendDidComplete: sendDidComplete)
    }

    /**
     Invokes a server side hub method with 3 parameters in a fire-and-forget manner.

     When a hub method is invoked in a fire-and-forget manner the client never receives any result of the invocation nor is notified about the invocation status.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter arg2: second argument of the hub method
     - parameter arg3: third argument of the hub method
     - parameter sendDidComplete: a completion handler that allows to track whether the client was able to successfully initiate the invocation. If the invocation was successfully initiated the `error` will be `nil`. Otherwise the `error` will contain failure details
     - parameter error: contains failure details if the invocation was not initiated successfully. `nil` otherwise
     */
    func send<T1: Encodable, T2: Encodable, T3: Encodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, sendDidComplete: @escaping (_ error: Error?) -> Void = {_ in}) {
        self.send(method: method, arguments: [arg1, arg2, arg3], sendDidComplete: sendDidComplete)
    }

    /**
     Invokes a server side hub method with 4 parameters in a fire-and-forget manner.

     When a hub method is invoked in a fire-and-forget manner the client never receives any result of the invocation nor is notified about the invocation status.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter arg2: second argument of the hub method
     - parameter arg3: third argument of the hub method
     - parameter arg4: fourth argument of the hub method
     - parameter sendDidComplete: a completion handler that allows to track whether the client was able to successfully initiate the invocation. If the invocation was successfully initiated the `error` will be `nil`. Otherwise the `error` will contain failure details
     - parameter error: contains failure details if the invocation was not initiated successfully. `nil` otherwise
     */
    func send<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, sendDidComplete: @escaping (_ error: Error?) -> Void = {_ in}) {
        self.send(method: method, arguments: [arg1, arg2, arg3, arg4], sendDidComplete: sendDidComplete)
    }

    /**
     Invokes a server side hub method with 5 parameters in a fire-and-forget manner.

     When a hub method is invoked in a fire-and-forget manner the client never receives any result of the invocation nor is notified about the invocation status.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter arg2: second argument of the hub method
     - parameter arg3: third argument of the hub method
     - parameter arg4: fourth argument of the hub method
     - parameter arg5: fifth argument of the hub method
     - parameter sendDidComplete: a completion handler that allows to track whether the client was able to successfully initiate the invocation. If the invocation was successfully initiated the `error` will be `nil`. Otherwise the `error` will contain failure details
     - parameter error: contains failure details if the invocation was not initiated successfully. `nil` otherwise
     */
    func send<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, T5: Encodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, _ arg5: T5, sendDidComplete: @escaping (_ error: Error?) -> Void = {_ in}) {
        self.send(method: method, arguments: [arg1, arg2, arg3, arg4, arg5], sendDidComplete: sendDidComplete)
    }

    /**
     Invokes a server side hub method with 6 parameters in a fire-and-forget manner.

     When a hub method is invoked in a fire-and-forget manner the client never receives any result of the invocation nor is notified about the invocation status.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter arg2: second argument of the hub method
     - parameter arg3: third argument of the hub method
     - parameter arg4: fourth argument of the hub method
     - parameter arg5: fifth argument of the hub method
     - parameter arg6: sixth argument of the hub method
     - parameter sendDidComplete: a completion handler that allows to track whether the client was able to successfully initiate the invocation. If the invocation was successfully initiated the `error` will be `nil`. Otherwise the `error` will contain failure details
     - parameter error: contains failure details if the invocation was not initiated successfully. `nil` otherwise
     */
    func send<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, T5: Encodable, T6: Encodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, _ arg5: T5, _ arg6: T6, sendDidComplete: @escaping (_ error: Error?) -> Void = {_ in}) {
        self.send(method: method, arguments: [arg1, arg2, arg3, arg4, arg5, arg6], sendDidComplete: sendDidComplete)
    }

    /**
     Invokes a server side hub method with 7 parameters in a fire-and-forget manner.

     When a hub method is invoked in a fire-and-forget manner the client never receives any result of the invocation nor is notified about the invocation status.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter arg2: second argument of the hub method
     - parameter arg3: third argument of the hub method
     - parameter arg4: fourth argument of the hub method
     - parameter arg5: fifth argument of the hub method
     - parameter arg6: sixth argument of the hub method
     - parameter arg7: seventh argument of the hub method
     - parameter sendDidComplete: a completion handler that allows to track whether the client was able to successfully initiate the invocation. If the invocation was successfully initiated the `error` will be `nil`. Otherwise the `error` will contain failure details
     - parameter error: contains failure details if the invocation was not initiated successfully. `nil` otherwise
     */
    func send<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, T5: Encodable, T6: Encodable, T7: Encodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, _ arg5: T5, _ arg6: T6, _ arg7: T7, sendDidComplete: @escaping (_ error: Error?) -> Void = {_ in}) {
        self.send(method: method, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7], sendDidComplete: sendDidComplete)
    }

    /**
     Invokes a server side hub method with 8 parameters in a fire-and-forget manner.

     When a hub method is invoked in a fire-and-forget manner the client never receives any result of the invocation nor is notified about the invocation status.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter arg2: second argument of the hub method
     - parameter arg3: third argument of the hub method
     - parameter arg4: fourth argument of the hub method
     - parameter arg5: fifth argument of the hub method
     - parameter arg6: sixth argument of the hub method
     - parameter arg7: seventh argument of the hub method
     - parameter arg8: eighth argument of the hub method
     - parameter sendDidComplete: a completion handler that allows to track whether the client was able to successfully initiate the invocation. If the invocation was successfully initiated the `error` will be `nil`. Otherwise the `error` will contain failure details
     - parameter error: contains failure details if the invocation was not initiated successfully. `nil` otherwise
     */
    func send<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, T5: Encodable, T6: Encodable, T7: Encodable, T8: Encodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, _ arg5: T5, _ arg6: T6, _ arg7: T7, _ arg8: T8, sendDidComplete: @escaping (_ error: Error?) -> Void = {_ in}) {
        self.send(method: method, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8], sendDidComplete: sendDidComplete)
    }

    /**
     Allows registering callbacks for client side hub methods with no parameters.

     - parameter method: the name of the client side method to register the callback for
     - parameter callback: a callback that will be called when the client side method is invoked from the server
     */
    func on(method: String, callback: @escaping () -> Void) {
        let cb: (ArgumentExtractor) throws -> Void = { argumentExtractor in
            callback()
        }

        self.on(method: method, callback: cb)
    }

    /**
     Allows registering callbacks for client side hub methods with 1 parameter.

     - parameter method: the name of the client side method to register the callback for
     - parameter callback: a callback that will be called when the client side method is invoked from the server
     - parameter arg1: first argument of the client side hub method
     - note: the callback parameters may need to be typed if the types cannot be inferred e.g.:
     ```
     hubConnection.on(method: "AddMessage") {(user: String, message: String) in
        print(">>> \(user): \(message)")
     }
     ```
     */
    func on<T1: Decodable>(method: String, callback: @escaping (_ arg1: T1) -> Void) {
        let cb: (ArgumentExtractor) throws -> Void = { argumentExtractor in
            let arg1 = try argumentExtractor.getArgument(type: T1.self)
            callback(arg1)
        }

        self.on(method: method, callback: cb)
    }

    /**
     Allows registering callbacks for client side hub methods with 2 parameters.

     - parameter method: the name of the client side method to register the callback for
     - parameter callback: a callback that will be called when the client side method is invoked from the server
     - parameter arg1: first argument of the client side hub method
     - parameter arg2: second argument of the client side hub method
     - note: the callback parameters may need to be typed if the types cannot be inferred e.g.:
     ```
     hubConnection.on(method: "AddMessage") {(user: String, message: String) in
        print(">>> \(user): \(message)")
     }
     ```
     */
    func on<T1: Decodable, T2: Decodable>(method: String, callback: @escaping (_ arg1: T1, _ arg2: T2) -> Void) {
        let cb: (ArgumentExtractor) throws -> Void = { argumentExtractor in
            let arg1 = try argumentExtractor.getArgument(type: T1.self)
            let arg2 = try argumentExtractor.getArgument(type: T2.self)
            callback(arg1, arg2)
        }

        self.on(method: method, callback: cb)
    }

    /**
     Allows registering callbacks for client side hub methods with 3 parameters.

     - parameter method: the name of the client side method to register the callback for
     - parameter callback: a callback that will be called when the client side method is invoked from the server
     - parameter arg1: first argument of the client side hub method
     - parameter arg2: second argument of the client side hub method
     - parameter arg3: third argument of the client side hub method
     - note: the callback parameters may need to be typed if the types cannot be inferred e.g.:
     ```
     hubConnection.on(method: "AddMessage") {(user: String, message: String) in
        print(">>> \(user): \(message)")
     }
     ```
     */
    func on<T1: Decodable, T2: Decodable, T3: Decodable>(method: String, callback: @escaping (_ arg1: T1, _ arg2: T2, _ arg3: T3) -> Void) {
        let cb: (ArgumentExtractor) throws -> Void = { argumentExtractor in
            let arg1 = try argumentExtractor.getArgument(type: T1.self)
            let arg2 = try argumentExtractor.getArgument(type: T2.self)
            let arg3 = try argumentExtractor.getArgument(type: T3.self)
            callback(arg1, arg2, arg3)
        }

        self.on(method: method, callback: cb)
    }

    /**
     Allows registering callbacks for client side hub methods with 4 parameters.

     - parameter method: the name of the client side method to register the callback for
     - parameter callback: a callback that will be called when the client side method is invoked from the server
     - parameter arg1: first argument of the client side hub method
     - parameter arg2: second argument of the client side hub method
     - parameter arg3: third argument of the client side hub method
     - parameter arg4: fourth argument of the client side hub method
     - note: the callback parameters may need to be typed if the types cannot be inferred e.g.:
     ```
     hubConnection.on(method: "AddMessage") {(user: String, message: String) in
        print(">>> \(user): \(message)")
     }
     ```
     */
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

    /**
     Allows registering callbacks for client side hub methods with 5 parameters.

     - parameter method: the name of the client side method to register the callback for
     - parameter callback: a callback that will be called when the client side method is invoked from the server
     - parameter arg1: first argument of the client side hub method
     - parameter arg2: second argument of the client side hub method
     - parameter arg3: third argument of the client side hub method
     - parameter arg4: fourth argument of the client side hub method
     - parameter arg5: fifth argument of the client side hub method
     - note: the callback parameters may need to be typed if the types cannot be inferred e.g.:
     ```
     hubConnection.on(method: "AddMessage") {(user: String, message: String) in
        print(">>> \(user): \(message)")
     }
     ```
     */
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

    /**
     Allows registering callbacks for client side hub methods with 6 parameters.

     - parameter method: the name of the client side method to register the callback for
     - parameter callback: a callback that will be called when the client side method is invoked from the server
     - parameter arg1: first argument of the client side hub method
     - parameter arg2: second argument of the client side hub method
     - parameter arg3: third argument of the client side hub method
     - parameter arg4: fourth argument of the client side hub method
     - parameter arg5: fifth argument of the client side hub method
     - parameter arg6: sixth argument of the client side hub method
     - note: the callback parameters may need to be typed if the types cannot be inferred e.g.:
     ```
     hubConnection.on(method: "AddMessage") {(user: String, message: String) in
        print(">>> \(user): \(message)")
     }
     ```
     */
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

    /**
     Allows registering callbacks for client side hub methods with 7 parameters.

     - parameter method: the name of the client side method to register the callback for
     - parameter callback: a callback that will be called when the client side method is invoked from the server
     - parameter arg1: first argument of the client side hub method
     - parameter arg2: second argument of the client side hub method
     - parameter arg3: third argument of the client side hub method
     - parameter arg4: fourth argument of the client side hub method
     - parameter arg5: fifth argument of the client side hub method
     - parameter arg6: sixth argument of the client side hub method
     - parameter arg7: seventh argument of the client side hub method
     - note: the callback parameters may need to be typed if the types cannot be inferred e.g.:
     ```
     hubConnection.on(method: "AddMessage") {(user: String, message: String) in
        print(">>> \(user): \(message)")
     }
     ```
     */
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

    /**
     Allows registering callbacks for client side hub methods with 8 parameters.

     - parameter method: the name of the client side method to register the callback for
     - parameter callback: a callback that will be called when the client side method is invoked from the server
     - parameter arg1: first argument of the client side hub method
     - parameter arg2: second argument of the client side hub method
     - parameter arg3: third argument of the client side hub method
     - parameter arg4: fourth argument of the client side hub method
     - parameter arg5: fifth argument of the client side hub method
     - parameter arg6: sixth argument of the client side hub method
     - parameter arg7: seventh argument of the client side hub method
     - parameter arg8: eighth argument of the client side hub method
     - note: the callback parameters may need to be typed if the types cannot be inferred e.g.:
     ```
     hubConnection.on(method: "AddMessage") {(user: String, message: String) in
        print(">>> \(user): \(message)")
     }
     ```
     */
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

    /**
     Invokes a streaming server side hub method with no parameters.

     The `stream` method invokes a streaming server side hub method. It takes two callbacks
     - `streamItemReceived` - invoked each time a stream item is received
     - `invocationDidComplete` - invoked when the invocation of the streaming method has completed. If the streaming method completed successfully or was cancelled the callback will be called with `nil` error. Otherwise the `error` parameter of the `invocationDidComplete` callback will contain failure details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not started when invoking the method), or remote - e.g. the hub method threw an error.

     - parameter method: the name of the server side hub method to invoke
     - parameter streamItemReceived: a handler that will be invoked each time a stream item is received
     - parameter invocationDidComplete: a completion handler that will be invoked when the invocation has completed
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     - returns: a `StreamHandle` that can be used to cancel the hub method associated with this invocation
     - note: the `streamItemReceived` parameter may need to be typed if the type cannot be inferred e.g.:
     ```
     hubConnection.stream(method: "StreamNumbers", 10, 1, streamItemReceived: { (item: Int) in print("\(item)" }) { error in print("\(error)") }
     ```
     */
    func stream<TItemType: Decodable>(method: String, streamItemReceived: @escaping (_ item: TItemType) -> Void, invocationDidComplete: @escaping (_ error: Error?) -> Void) -> StreamHandle {
        return self.stream(method: method, arguments: [], streamItemReceived: streamItemReceived, invocationDidComplete: invocationDidComplete)
    }

    /**
     Invokes a streaming server side hub method with 1 parameter.

     The `stream` method invokes a streaming server side hub method. It takes two callbacks
     - `streamItemReceived` - invoked each time a stream item is received
     - `invocationDidComplete` - invoked when the invocation of the streaming method has completed. If the streaming method completed successfully or was cancelled the callback will be called with `nil` error. Otherwise the `error` parameter of the `invocationDidComplete` callback will contain failure details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not started when invoking the method), or remote - e.g. the hub method threw an error.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter streamItemReceived: a handler that will be invoked each time a stream item is received
     - parameter invocationDidComplete: a completion handler that will be invoked when the invocation has completed
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     - returns: a `StreamHandle` that can be used to cancel the hub method associated with this invocation
     - note: the `streamItemReceived` parameter may need to be typed if the type cannot be inferred e.g.:
     ```
     hubConnection.stream(method: "StreamNumbers", 10, 1, streamItemReceived: { (item: Int) in print("\(item)" }) { error in print("\(error)") }
     ```
     */
    func stream<T1: Encodable, TItemType: Decodable>(method: String, _ arg1: T1, streamItemReceived: @escaping (_ item: TItemType) -> Void, invocationDidComplete: @escaping (_ error: Error?) -> Void) -> StreamHandle {
        return self.stream(method: method, arguments: [arg1], streamItemReceived: streamItemReceived, invocationDidComplete: invocationDidComplete)
    }

    /**
     Invokes a streaming server side hub method with 2 parameters.

     The `stream` method invokes a streaming server side hub method. It takes two callbacks
     - `streamItemReceived` - invoked each time a stream item is received
     - `invocationDidComplete` - invoked when the invocation of the streaming method has completed. If the streaming method completed successfully or was cancelled the callback will be called with `nil` error. Otherwise the `error` parameter of the `invocationDidComplete` callback will contain failure details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not started when invoking the method), or remote - e.g. the hub method threw an error.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter arg2: second argument of the hub method
     - parameter streamItemReceived: a handler that will be invoked each time a stream item is received
     - parameter invocationDidComplete: a completion handler that will be invoked when the invocation has completed
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     - returns: a `StreamHandle` that can be used to cancel the hub method associated with this invocation
     - note: the `streamItemReceived` parameter may need to be typed if the type cannot be inferred e.g.:
     ```
     hubConnection.stream(method: "StreamNumbers", 10, 1, streamItemReceived: { (item: Int) in print("\(item)" }) { error in print("\(error)") }
     ```
     */
    func stream<T1: Encodable, T2: Encodable, TItemType: Decodable>(method: String, _ arg1: T1, _ arg2: T2, streamItemReceived: @escaping (_ item: TItemType) -> Void, invocationDidComplete: @escaping (_ error: Error?) -> Void) -> StreamHandle {
        return self.stream(method: method, arguments: [arg1, arg2], streamItemReceived: streamItemReceived, invocationDidComplete: invocationDidComplete)
    }

    /**
     Invokes a streaming server side hub method with 3 parameters.

     The `stream` method invokes a streaming server side hub method. It takes two callbacks
     - `streamItemReceived` - invoked each time a stream item is received
     - `invocationDidComplete` - invoked when the invocation of the streaming method has completed. If the streaming method completed successfully or was cancelled the callback will be called with `nil` error. Otherwise the `error` parameter of the `invocationDidComplete` callback will contain failure details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not started when invoking the method), or remote - e.g. the hub method threw an error.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter arg2: second argument of the hub method
     - parameter arg3: third argument of the hub method
     - parameter streamItemReceived: a handler that will be invoked each time a stream item is received
     - parameter invocationDidComplete: a completion handler that will be invoked when the invocation has completed
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     - returns: a `StreamHandle` that can be used to cancel the hub method associated with this invocation
     - note: the `streamItemReceived` parameter may need to be typed if the type cannot be inferred e.g.:
     ```
     hubConnection.stream(method: "StreamNumbers", 10, 1, streamItemReceived: { (item: Int) in print("\(item)" }) { error in print("\(error)") }
     ```
     */
    func stream<T1: Encodable, T2: Encodable, T3: Encodable, TItemType: Decodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, streamItemReceived: @escaping (_ item: TItemType) -> Void, invocationDidComplete: @escaping (_ error: Error?) -> Void) -> StreamHandle {
        return self.stream(method: method, arguments: [arg1, arg2, arg3], streamItemReceived: streamItemReceived, invocationDidComplete: invocationDidComplete)
    }

    /**
     Invokes a streaming server side hub method with 4 parameters.

     The `stream` method invokes a streaming server side hub method. It takes two callbacks
     - `streamItemReceived` - invoked each time a stream item is received
     - `invocationDidComplete` - invoked when the invocation of the streaming method has completed. If the streaming method completed successfully or was cancelled the callback will be called with `nil` error. Otherwise the `error` parameter of the `invocationDidComplete` callback will contain failure details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not started when invoking the method), or remote - e.g. the hub method threw an error.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter arg2: second argument of the hub method
     - parameter arg3: third argument of the hub method
     - parameter arg4: fourth argument of the hub method
     - parameter streamItemReceived: a handler that will be invoked each time a stream item is received
     - parameter invocationDidComplete: a completion handler that will be invoked when the invocation has completed
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     - returns: a `StreamHandle` that can be used to cancel the hub method associated with this invocation
     - note: the `streamItemReceived` parameter may need to be typed if the type cannot be inferred e.g.:
     ```
     hubConnection.stream(method: "StreamNumbers", 10, 1, streamItemReceived: { (item: Int) in print("\(item)" }) { error in print("\(error)") }
     ```
     */
    func stream<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, TItemType: Decodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, streamItemReceived: @escaping (_ item: TItemType) -> Void, invocationDidComplete: @escaping (_ error: Error?) -> Void) -> StreamHandle {
        return self.stream(method: method, arguments: [arg1, arg2, arg3, arg4], streamItemReceived: streamItemReceived, invocationDidComplete: invocationDidComplete)
    }

    /**
     Invokes a streaming server side hub method with 5 parameters.

     The `stream` method invokes a streaming server side hub method. It takes two callbacks
     - `streamItemReceived` - invoked each time a stream item is received
     - `invocationDidComplete` - invoked when the invocation of the streaming method has completed. If the streaming method completed successfully or was cancelled the callback will be called with `nil` error. Otherwise the `error` parameter of the `invocationDidComplete` callback will contain failure details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not started when invoking the method), or remote - e.g. the hub method threw an error.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter arg2: second argument of the hub method
     - parameter arg3: third argument of the hub method
     - parameter arg4: fourth argument of the hub method
     - parameter arg5: fifth argument of the hub method
     - parameter streamItemReceived: a handler that will be invoked each time a stream item is received
     - parameter invocationDidComplete: a completion handler that will be invoked when the invocation has completed
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     - returns: a `StreamHandle` that can be used to cancel the hub method associated with this invocation
     - note: the `streamItemReceived` parameter may need to be typed if the type cannot be inferred e.g.:
     ```
     hubConnection.stream(method: "StreamNumbers", 10, 1, streamItemReceived: { (item: Int) in print("\(item)" }) { error in print("\(error)") }
     ```
     */
    func stream<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, T5: Encodable, TItemType: Decodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, _ arg5: T5, streamItemReceived: @escaping (_ item: TItemType) -> Void, invocationDidComplete: @escaping (_ error: Error?) -> Void) -> StreamHandle {
        return self.stream(method: method, arguments: [arg1, arg2, arg3, arg4, arg5], streamItemReceived: streamItemReceived, invocationDidComplete: invocationDidComplete)
    }

    /**
     Invokes a streaming server side hub method with 6 parameters.

     The `stream` method invokes a streaming server side hub method. It takes two callbacks
     - `streamItemReceived` - invoked each time a stream item is received
     - `invocationDidComplete` - invoked when the invocation of the streaming method has completed. If the streaming method completed successfully or was cancelled the callback will be called with `nil` error. Otherwise the `error` parameter of the `invocationDidComplete` callback will contain failure details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not started when invoking the method), or remote - e.g. the hub method threw an error.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter arg2: second argument of the hub method
     - parameter arg3: third argument of the hub method
     - parameter arg4: fourth argument of the hub method
     - parameter arg5: fifth argument of the hub method
     - parameter arg6: sixth argument of the hub method
     - parameter streamItemReceived: a handler that will be invoked each time a stream item is received
     - parameter invocationDidComplete: a completion handler that will be invoked when the invocation has completed
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     - returns: a `StreamHandle` that can be used to cancel the hub method associated with this invocation
     - note: the `streamItemReceived` parameter may need to be typed if the type cannot be inferred e.g.:
     ```
     hubConnection.stream(method: "StreamNumbers", 10, 1, streamItemReceived: { (item: Int) in print("\(item)" }) { error in print("\(error)") }
     ```
     */
    func stream<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, T5: Encodable, T6: Encodable, TItemType: Decodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, _ arg5: T5, _ arg6: T6, streamItemReceived: @escaping (_ item: TItemType) -> Void, invocationDidComplete: @escaping (_ error: Error?) -> Void) -> StreamHandle {
        return self.stream(method: method, arguments: [arg1, arg2, arg3, arg4, arg5, arg6], streamItemReceived: streamItemReceived, invocationDidComplete: invocationDidComplete)
    }

    /**
     Invokes a streaming server side hub method with 7 parameters.

     The `stream` method invokes a streaming server side hub method. It takes two callbacks
     - `streamItemReceived` - invoked each time a stream item is received
     - `invocationDidComplete` - invoked when the invocation of the streaming method has completed. If the streaming method completed successfully or was cancelled the callback will be called with `nil` error. Otherwise the `error` parameter of the `invocationDidComplete` callback will contain failure details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not started when invoking the method), or remote - e.g. the hub method threw an error.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter arg2: second argument of the hub method
     - parameter arg3: third argument of the hub method
     - parameter arg4: fourth argument of the hub method
     - parameter arg5: fifth argument of the hub method
     - parameter arg6: sixth argument of the hub method
     - parameter arg7: seventh argument of the hub method
     - parameter streamItemReceived: a handler that will be invoked each time a stream item is received
     - parameter invocationDidComplete: a completion handler that will be invoked when the invocation has completed
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     - returns: a `StreamHandle` that can be used to cancel the hub method associated with this invocation
     - note: the `streamItemReceived` parameter may need to be typed if the type cannot be inferred e.g.:
     ```
     hubConnection.stream(method: "StreamNumbers", 10, 1, streamItemReceived: { (item: Int) in print("\(item)" }) { error in print("\(error)") }
     ```
     */
    func stream<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, T5: Encodable, T6: Encodable, T7: Encodable, TItemType: Decodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, _ arg5: T5, _ arg6: T6, _ arg7: T7, streamItemReceived: @escaping (_ item: TItemType) -> Void, invocationDidComplete: @escaping (_ error: Error?) -> Void) -> StreamHandle {
        return self.stream(method: method, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7], streamItemReceived: streamItemReceived, invocationDidComplete: invocationDidComplete)
    }

    /**
     Invokes a streaming server side hub method with 8 parameters.

     The `stream` method invokes a streaming server side hub method. It takes two callbacks
     - `streamItemReceived` - invoked each time a stream item is received
     - `invocationDidComplete` - invoked when the invocation of the streaming method has completed. If the streaming method completed successfully or was cancelled the callback will be called with `nil` error. Otherwise the `error` parameter of the `invocationDidComplete` callback will contain failure details. Note that the failure can be local - e.g. the invocation was not initiated successfully (for example the connection was not started when invoking the method), or remote - e.g. the hub method threw an error.

     - parameter method: the name of the server side hub method to invoke
     - parameter arg1: first argument of the hub method
     - parameter arg2: second argument of the hub method
     - parameter arg3: third argument of the hub method
     - parameter arg4: fourth argument of the hub method
     - parameter arg5: fifth argument of the hub method
     - parameter arg6: sixth argument of the hub method
     - parameter arg7: seventh argument of the hub method
     - parameter arg8: eighth argument of the hub method
     - parameter streamItemReceived: a handler that will be invoked each time a stream item is received
     - parameter invocationDidComplete: a completion handler that will be invoked when the invocation has completed
     - parameter error: contains failure details if the invocation was not initiated successfully or the hub method threw an exception. `nil` otherwise
     - returns: a `StreamHandle` that can be used to cancel the hub method associated with this invocation
     - note: the `streamItemReceived` parameter may need to be typed if the type cannot be inferred e.g.:
     ```
     hubConnection.stream(method: "StreamNumbers", 10, 1, streamItemReceived: { (item: Int) in print("\(item)" }) { error in print("\(error)") }
     ```
     */
    func stream<T1: Encodable, T2: Encodable, T3: Encodable, T4: Encodable, T5: Encodable, T6: Encodable, T7: Encodable, T8: Encodable, TItemType: Decodable>(method: String, _ arg1: T1, _ arg2: T2, _ arg3: T3, _ arg4: T4, _ arg5: T5, _ arg6: T6, _ arg7: T7, _ arg8: T8, streamItemReceived: @escaping (_ item: TItemType) -> Void, invocationDidComplete: @escaping (_ error: Error?) -> Void) -> StreamHandle {
        return self.stream(method: method, arguments: [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8], streamItemReceived: streamItemReceived, invocationDidComplete: invocationDidComplete)
    }
}
