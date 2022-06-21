//
//  UDPSocket.swift
//  
//
//  Created by Sebastian Toivonen on 9.1.2021.
//

import CSocket

public final class UDPSocket {
    private let handle: Int32
    public var port: UInt16 = 0
    private var address: UnsafeRawPointer?
    
    public var receiveBuffer = [UInt8](repeating: 0, count: 1500)
    
    public init() throws {
        if !_initializeSocket() {
            throw SocketError.initializationError
        }
        handle = _createUDPSocket()
        if handle <= 0 {
            throw SocketError.handleCreationError
        }
    }
    
    public final func open(port: UInt16) throws {
        if !_openSocket(handle, port) {
            throw SocketError.socketOpenError
        }
    }
    
    public final func close() {
        _closeSocket(handle)
    }
    
    public final func setNonBlocking() throws {
        if !_set_non_blocking(handle) {
            throw SocketError.nonBlockingError
        }
    }
    
    public final func setBlocking(_ blocking: Bool) throws {
        if _set_blocking_mode(handle, blocking) != blocking {
            throw SocketError.nonBlockingError
        }
    }
    
    public final func send(data: [UInt8], address: Address) -> Bool {
        var msg = data
        return _sendDataTo(handle, &msg, msg.count, address.a, address.b, address.c, address.d, address.port)
    }
    
    public final func receive() -> (data: [UInt8], sender: Address?) {
        var a: UInt32 = 0
        var b: UInt32 = 0
        var c: UInt32 = 0
        var d: UInt32 = 0
        var port: UInt32 = 0
        let bytes = Int(_receiveDataFrom(handle, &receiveBuffer, 8, &a, &b, &c, &d, &port))
        if bytes <= 0 {
            return ([], nil)
        }
        let address = Address(a, b, c, d, UInt16(port))
        return (Array(receiveBuffer[0..<bytes]), address)
    }
    
    deinit {
        _shutdownSocket()
    }
}
