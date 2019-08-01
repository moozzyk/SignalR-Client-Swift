import Cocoa
import SignalRClient

let hubConnection = HubConnectionBuilder(url: URL(string: "http://localhost:5000/playground")!)
    .withLogging(minLogLevel: .info)
    .build()

hubConnection.on(method: "AddMessage") {(user: String, message: String) in
    print(">>> \(user): \(message)")
}

hubConnection.start()
// NOTE: break here before to make this sample work and prevent errors
// caused by trying to invoke server side methods before starting the
// connection completed

// invoking a hub method and receiving a result
hubConnection.invoke(method: "Add", 2, 3, resultType: Int.self) { result, error in
    if let error = error {
        print("error: \(error)")
    } else {
        print("Add result: \(result!)")
    }
}

// invoking a hub method that does not return a result
hubConnection.invoke(method: "Broadcast", "Playground user", "Sending a message") { error in
    if let error = error {
        print("error: \(error)")
    } else {
        print("Broadcast invocation completed without errors")
    }
}

hubConnection.send(method: "Broadcast", "Playground user", "Testing send") { error in
    if let error = error {
        print("Send failed: \(error)")
    }
}

let streamHandle = hubConnection.stream(method: "StreamNumbers", 1, 10000, itemType: Int.self,
                                        streamItemReceived: { item in print(">>> \(item!)") }) { error in
        print("Stream closed.")
        if let error = error {
            print("Error: \(error)")
        }
    }

DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
    hubConnection.cancelStreamInvocation(streamHandle: streamHandle) { error in
        print("Canceling stream invocation failed: \(error)")
    }
}

DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
    hubConnection.stop()
}
