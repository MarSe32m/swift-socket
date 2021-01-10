//
//  File.swift
//  
//
//  Created by Sebastian Toivonen on 9.1.2021.
//

import CSocket

public enum SocketError: Error {
    case initializationError
    case handleCreationError
    case socketOpenError
    case nonBlockingError
}

public struct Address {
    public let a: UInt32
    public let b: UInt32
    public let c: UInt32
    public let d: UInt32
    public let port: UInt16
    
    public init(_ a: UInt32, _ b: UInt32, _ c: UInt32, _ d: UInt32, _ port: UInt16) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.port = port
    }
}

public final class Socket {
    private let handle: Int32
    public var port: UInt16 = 0
    private var address: UnsafeRawPointer?
    
    public var receiveBuffer = [UInt8](repeating: 0, count: 1500)
    
    public init() throws {
        if !initializeSocket() {
            throw SocketError.initializationError
        }
        handle = createUDPSocket()
        if handle <= 0 {
            throw SocketError.handleCreationError
        }
    }
    
    public final func open(port: UInt16) throws {
        if !openSocket(handle, port) {
            throw SocketError.socketOpenError
        }
    }
    
    public final func close() {
        closeSocket(handle)
    }
    
    public final func setNonBlocking() throws {
        if !set_non_blocking(handle) {
            throw SocketError.nonBlockingError
        }
    }
    
    public final func setBlocking(_ blocking: Bool) throws {
        if set_blocking_mode(handle, blocking) != blocking {
            throw SocketError.nonBlockingError
        }
    }
    
    public final func send(data: [UInt8], address: Address) -> Bool {
        var msg = data
        return sendData(handle, &msg, msg.count, address.a, address.b, address.c, address.d, address.port)
    }
    
    public final func receive() -> (data: [UInt8], sender: Address?) {
        var a: UInt32 = 0
        var b: UInt32 = 0
        var c: UInt32 = 0
        var d: UInt32 = 0
        var port: UInt32 = 0
        let bytes = Int(receiveData(handle, &receiveBuffer, 8, &a, &b, &c, &d, &port))
        if bytes <= 0 {
            return ([], nil)
        }
        let address = Address(a, b, c, d, UInt16(port))
        return (Array(receiveBuffer[0..<bytes]), address)
    }
    
    deinit {
        shutdownSocket()
    }
}
