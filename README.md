# SignalR-Client-Swift

Swift SignalR Client for Asp.Net Core SignalR server

## Installation

- Install/Update the Carthage package manager
- Create a new file called `Cartfile` in the application folder
- Add the following line to the `Cartfile` to get the latest bits
  
  ```github "moozzyk/SignalR-Client-Swift" master``` 
  
- In terminal go to the application folder and run (`--platform` can be skipped to install for available platforms):
  
  `carthage update --platform macOS` 
  
- In Xcode go to the project settings and add SignalRClient and SockertRocket to "Embedded Binaries"
- In Xcode go to the project settings and add SignalRClient and SockertRocket to "Linked Frameworks and Libraries" (if Xcode didn't do it in the previous step automatically)
- Add 

  ```Swift
  import SignalRClient
  ```
  to the file you want to use SignalR client in to import SignalR client definitions
  
## Samples

The repo contains samples for:

  - [Hubs](https://github.com/moozzyk/SignalR-Client-Swift/tree/master/HubSample)
  - [Sockets](https://github.com/moozzyk/SignalR-Client-Swift/tree/master/SocketsSample)

The samples require a running server. To start the server go to the `TestServer` folder in terminal and run 

```C#
dotnet run
```
