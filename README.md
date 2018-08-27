# SwiftSignalRClient

A Swift SignalR Client for the Asp.Net Core version of SignalR

## Installation

### Cocoapods

- add the following lines to your `Podfile`:
  ```ruby
  use_frameworks!
  pod 'SwiftSignalRClient'
  ```
- run:
  ```
  pod install
  ```

Add `#import SwiftSignalRClient` to swift files you would like to use the client in.

## Samples

The repo contains samples for:

  - [Hubs](https://github.com/moozzyk/SignalR-Client-Swift/tree/master/HubSample)
  - [HttpConnection](https://github.com/moozzyk/SignalR-Client-Swift/tree/master/ConnectionSample)

The samples require a running server. To start the server go to the `TestServer` folder in terminal and run: 

```C#
dotnet run
```

(Requires [.NET Core SDK 2.1.300](https://www.microsoft.com/net/download/dotnet-core/sdk-2.1.300) or later)
