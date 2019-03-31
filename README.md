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

```swift
.package(url: "https://github.com/moozzyk/SignalR-Client-Swift", .upToNextMinor(from: "0.5.0")),
```

## Usage

Add `import SwiftSignalRClient` to swift files you would like to use the client in.

## Examples

The repo contains samples for:

  - [Hubs](https://github.com/moozzyk/SignalR-Client-Swift/tree/master/Example/HubSample)
  - [HttpConnection](https://github.com/moozzyk/SignalR-Client-Swift/tree/master/Example/ConnectionSample)

The samples require a running server. To start the server go to the [`TestServer`](https://github.com/moozzyk/SignalR-Client-Swift/tree/master/Example/TestServer) folder in terminal and run: 

```C#
dotnet run
```

(Requires [.NET Core SDK 2.1.300](https://www.microsoft.com/net/download/dotnet-core/sdk-2.1.300) or later)
