# SwiftSignalRClient

A Swift SignalR Client for the Asp.Net Core version of SignalR

**Before filing an issue please check [Frequently Asked Questions](https://github.com/moozzyk/SignalR-Client-Swift/wiki/Frequently-Asked-Questions)**

## NEW - [Swift SignalR Client Course](https://www.udemy.com/course/build-real-time-ios-apps-with-asp-net-core-signalr)

Everything you need to know about using the Swift SignalR Client [in under 60 minutes](https://www.udemy.com/course/build-real-time-ios-apps-with-asp-net-core-signalr)

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

The easiest way to is to use Use XCode UI (`File -> Add Packages...`) 

Alternatively, add the following to your `Package` dependencies:

```swift
.package(url: "https://github.com/moozzyk/SignalR-Client-Swift", .upToNextMinor(from: "0.9.0")),
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

More detailed user's guides:
 - [Swift SignalR Client Course](https://www.udemy.com/course/build-real-time-ios-apps-with-asp-net-core-signalr) - the most complete and up-to-date information on using the Swift SignalR Client
 - [Swift Client for the ASP.Net Core Version of SignalR – Part 1: Getting Started](https://blog.3d-logic.com/2019/07/28/swift-client-for-the-asp-net-core-version-of-signalr-part-1-getting-started/)
 - [Swift Client for the ASP.Net Core Version of SignalR – Part 1: Beyond the Basics](https://blog.3d-logic.com/2019/08/01/swift-client-for-the-asp-net-core-version-of-signalr-part-2-beyond-the-basics/)
 - [Automatic Reconnection in the Swift SignalR Client](https://blog.3d-logic.com/2020/06/28/automatic-reconnection-in-the-swift-signalr-client/)
 
## Examples

There are several sample projects in the `Examples` folder. They include:

  - [SignalRClient.xcodeproj](Examples/)
    
    An Xcode workspace that has compiled libraries for macOS (OSX) and iOS, along with the Application targets 'ConnectionSample', 'HubSample', and 'HubSamplePhone'.
    
  - [TestServer](Examples/TestServer)
    
    A .Net solution that the unit tests and samples can be run against.
    
    The `TestServer` Requires [.NET Core SDK 3.0.100](https://www.microsoft.com/net/download/dotnet-core/sdk-3.0.100) or later.
    
    To run, navigate to the `TestServer` folder and execute the following in the terminal:
    
    ```sh
    % npm install
    % dotnet run
    ```
    
    When running the `TestServer` project on macOS Monterey (12.0 or greater), you may encounter the error: 
    **"Failed to bind to address http://0.0.0.0:5000: address already in use."**. This is due to Apple now advertising an 'AirPlay Receiver' on that port.
    This port can be freed by disabling the receiver: Navigate to _System Preferences > Sharing_ and uncheck _AirPlay Receiver_.

## Hits
[![HitCount](http://hits.dwyl.com/moozzyk/Signalr-Client-Swift.svg)](http://hits.dwyl.com/moozzyk/Signalr-Client-Swift)
