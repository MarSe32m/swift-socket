import Socket
import Foundation

func TCPTest() throws {
    Thread.detachNewThread {
        do {
            try serverProcedure()
        } catch {
            print(error)
        }
    }
    try clientProcedure()
}

fileprivate func serverProcedure() throws {
    let listenSocket = try TCPSocket()
    try listenSocket.open(port: 25565)
    try listenSocket.listen(backlog: 256)

    let clientSocket = try listenSocket.accept()
    print(clientSocket.address)
    var buffer = [UInt8](repeating: 0, count: 1024)
    let bytesReceived = clientSocket.receive(buffer: &buffer)
    print("Server received \(bytesReceived) bytes from client.")
    let sentBytes = clientSocket.send(data: [UInt8](buffer[0..<bytesReceived]))
    print("Server sent \(sentBytes) bytes back to the client.")
    
    withUnsafeTemporaryAllocation(of: UInt8.self, capacity: 1024) { pointer in 
        //let bytesReceived = clientSocket.receive(buffer: pointer.baseAddress, count: pointer.count)
        //print("Server received \(bytesReceived) bytes from client.")
        //let sentBytes = clientSocket.send(data: [UInt8](pointer[0..<bytesReceived]))
        //print("Server sent \(sentBytes) bytes back to the client.")

    }
    
    clientSocket.close()
    listenSocket.close()
}

fileprivate func clientProcedure() throws {
    let socket = try TCPSocket()
    try socket.connect(host: "127.0.0.1", port: 25565)
    var buffer: [UInt8] = [1,2,3,4,54,56,6,3]
    let bytesSent = socket.send(data: buffer)
    print("Client sent \(bytesSent) bytes.")
    let bytesReceived = socket.receive(buffer: &buffer)
    print("Client received \(bytesReceived) bytes.")
    buffer.withUnsafeMutableBufferPointer { bufferPointer in 
        //let bytesReceived = socket.receive(buffer: bufferPointer.baseAddress, count: bufferPointer.count)
        //print("Client received \(bytesReceived) bytes.")
    }
    socket.close()
}