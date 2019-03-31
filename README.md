# SwiftSignalRClient

A Swift SignalR Client for the Asp.Net Core version of SignalR

## Installation

### Cocoapods

Add the following lines to your `Podfile`:

```ruby
use_frameworks!
pod 'SwiftSignalRClient', '~> 0.5'
```

Then run:
```sh
pod install
```

### Swift Packacge Manager

Add the following to your `Package` dependencies:

```swift
.package(url: "https://github.com/moozzyk/SignalR-Client-Swift", .upToNextMinor(from: "0.5.0")),
```

Then include `"SwiftSignalRClient"` in your target dependencies. For example:

```swift
.target(name: "MySwiftPackage", dependencies: ["SwiftSignalRClient"]),
```

## Usage

Add `import SwiftSignalRClient` to swift files you would like to use the client in.

A typical implementation looks like the following:

```swift
import Foundation
import SwiftSignalRClient

public class SignalRService {
    private var connection: HubConnection
    
    public init(url: URL) {
        connection = HubConnectionBuilder(url: url).withLogging(minLogLevel: .error).build()
        connection.on(method: "MessageReceived", callback: { (args, typeConverter) in
            do {
                let user = try typeConverter.convertFromWireType(obj: args[0], targetType: String.self)
                let message = try typeConverter.convertFromWireType(obj: args[1], targetType: String.self)
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

## Examples

There are several sample projects in the `Examples` folder. They include:

  - [SignalRClient.xcworkspace](Examples/)
    
    An Xcode workspace that has compiled libraries for macOS (OSX) and iOS, along with the Application targets 'ConnectionSample', 'HubSample', and 'HubSamplePhone'.
    
  - [TestServer](Examples/TestServer)
    
    A .Net solution that creates a SignalR hub that the application targets can be run against.
    
    The `TestServer` Requires [.NET Core SDK 2.1.300](https://www.microsoft.com/net/download/dotnet-core/sdk-2.1.300) or later.
    
    To run, navigate to the `TestServer` folder and execute the following in the terminal:
    
    ```sh
    npm install
    ```
    
    ```C#
    dotnet run
    ```
