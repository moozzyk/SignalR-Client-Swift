# SwiftSignalRClient

A Swift SignalR Client for the Asp.Net Core version of SignalR

**Before filing an issue please check [Frequently Asked Questions](https://github.com/moozzyk/SignalR-Client-Swift/wiki/Frequently-Asked-Questions)**

## Installation

### Cocoapods

Add the following lines to your `Podfile`:

```ruby
use_frameworks!
pod 'SwiftSignalRClient'
```

Then run:
```sh
pod install
```

### Swift Package Manager

Add the following to your `Package` dependencies:

```swift
.package(url: "https://github.com/moozzyk/SignalR-Client-Swift", .upToNextMinor(from: "0.6.0")),
```

Then include `"SignalRClient"` in your target dependencies. For example:

```swift
.target(name: "MySwiftPackage", dependencies: ["SignalRClient"]),
```

### Carthage

Add the following lines to your `Cartfile`:

```
github "moozzyk/SignalR-Client-Swift"
```

Then run:
```sh
carthage update
```

## Usage

Add `import SwiftSignalRClient` (or `import SignalRClient` if you are using Swift Package Manager) to swift files you would like to use the client in.

A typical implementation looks like the following:

```swift
import Foundation
import SwiftSignalRClient

public class SignalRService {
    private var connection: HubConnection
    
    public init(url: URL) {
        connection = HubConnectionBuilder(url: url).withLogging(minLogLevel: .error).build()
        connection.on(method: "MessageReceived", callback: { (user: String, message: String) in
            do {
                self.handleMessage(message, from: user)
            } catch {
                print(error)
            }
        })
        
        connection.start()
    }
    
    private func handleMessage(_ message: String, from user: String) {
        // Do something with the message.
    }
}
```

More detailed user's guide:
 - [Swift Client for the ASP.Net Core Version of SignalR – Part 1: Getting Started](https://blog.3d-logic.com/2019/07/28/swift-client-for-the-asp-net-core-version-of-signalr-part-1-getting-started/)
 - [Swift Client for the ASP.Net Core Version of SignalR – Part 1: Beyond the Basics](https://blog.3d-logic.com/2019/08/01/swift-client-for-the-asp-net-core-version-of-signalr-part-2-beyond-the-basics/)
 - [Automatic Reconnection in the Swift SignalR Client](https://blog.3d-logic.com/2020/06/28/automatic-reconnection-in-the-swift-signalr-client/)
 
## Examples

There are several sample projects in the `Examples` folder. They include:

  - [SignalRClient.xcworkspace](Examples/)
    
    An Xcode workspace that has compiled libraries for macOS (OSX) and iOS, along with the Application targets 'ConnectionSample', 'HubSample', and 'HubSamplePhone'.
    
  - [TestServer](Examples/TestServer)
    
    A .Net solution that the unit tests and samples can be run against.
    
    The `TestServer` Requires [.NET Core SDK 3.0.100](https://www.microsoft.com/net/download/dotnet-core/sdk-3.0.100) or later.
    
    To run, navigate to the `TestServer` folder and execute the following in the terminal:
    
    ```sh
    npm install
    ```
    
    ```C#
    dotnet run
    ```

## Migration from versions before 0.6.0

The way of handling serialization/deserialization of values sent/received from the server changed in version 0.6.0. The `TypeConverter` protocol has been removed in favor of the `Encodable`/`Decodable` protocols. The client now can serialize and send to the server any value that conforms to the `Encodable` protocol and is able to deserialize any value received from the server as long as the target type for the value conforms to the `Decodable` protocol (in most cases you don't need to distinguish between these protocols and you can just make your types conform to the `Codable` protocol. Also primitive types already conform to the `Codable` protocol so they work out of the box). One of the consequences of this change is that the signature of the client side method handlers changed and the code needs to be adjusted when moving to the version 0.6.0. Here is how:

Before version 0.6.0 registering a handler for the client side method could look like this:

```Swift
self.chatHubConnection!.on(method: "NewMessage", callback: {args, typeConverter in
    let user = try! typeConverter.convertFromWireType(obj: args[0], targetType: String.self)
    let message = try! typeConverter.convertFromWireType(obj: args[1], targetType: String.self)
    self.appendMessage(message: "\(user!): \(message!)")
})
```

After installing version 0.6.0 or newer it needs to be changed to:

```Swift
self.chatHubConnection!.on(method: "NewMessage", callback: {(user: String, message: String) in
    self.appendMessage(message: "\(user): \(message)")
})
```

Here is the summary of the changes:
- remove the `typeConverter` parameter
- replace `args` parameter with a list of actual parameters (make sure to provide parameter types)
- remove calls to `typeConverter` methods
- remove code to handle optional types (if applicabale)

Note: if your client side method takes more than 8 parameters you will need to use a lower level primitve to add a handler for this method. 

Version 0.6.0 also adds some syntactic sugar for the APIs to invoke server side hub methods (i.e. `invoke`, `send`, `stream`). This is not a breaking change - the old methods will continue to work but in version 0.6.0 you can now pass the values as separate arguments instead of creating an array which is much nicer. For instance nvoking a hub method:

```Swift
chatHubConnection?.invoke(method: "Broadcast", arguments: [name, message]) { error in
    if let e = error {
        self.appendMessage(message: "Error: \(e)")
    }
}
```

can now be changed to:

```Swift
chatHubConnection?.invoke(method: "Broadcast", name, message) { error in
    if let e = error {
        self.appendMessage(message: "Error: \(e)")
    }
}
```

The new APIs support up to 8 parameters. If you have a hub method taking more than 8 parameters you will need to use a lower level primitives that take an array containing parameter values.

## Disclaimer

I am providing code in the repository to you under an open source license. Because this is my personal repository, the license you receive to my code is from me and not my employer (Facebook)

## Hits
[![HitCount](http://hits.dwyl.com/moozzyk/Signalr-Client-Swift.svg)](http://hits.dwyl.com/moozzyk/Signalr-Client-Swift)
