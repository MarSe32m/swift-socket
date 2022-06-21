import CSocket

public final class TCPSocket {
    private let handle: Int32
    public var port: UInt16 = 0
    //private var address: UnsafeRawPointer?
    public var address: Address?
    
    private let acceptedSocket: Bool

    public var receiveBuffer = [UInt8](repeating: 0, count: 1500)
    
    public init() throws {
        if !_initializeSocket() {
            throw SocketError.initializationError
        }
        handle = _createTCPSocket()
        if handle <= 0 {
            throw SocketError.handleCreationError
        }
        acceptedSocket = false
    }
    
    private init(handle: Int32, address: Address) {
        self.handle = handle
        self.address = address
        self.acceptedSocket = true
    }

    public final func open(port: UInt16) throws {
        if !_openSocket(handle, port) {
            throw SocketError.socketOpenError
        }
    }
    
    public final func close() {
        _closeSocket(handle)
    }

    public final func listen(backlog: Int) throws {
        if !_listen(handle, Int32(backlog)) {
            throw SocketError.socketListenError
        }
    }

    public final func accept() throws -> TCPSocket {
        let senderAddr = UnsafeMutablePointer<sockaddr_in>.allocate(capacity: 1)
        let handle = _accept(self.handle, senderAddr)
        print(handle)
        if handle < 0 {
            throw SocketError.socketAcceptError
        }
        var a: UInt32 = 0
        var b: UInt32 = 0
        var c: UInt32 = 0
        var d: UInt32 = 0
        var port: UInt32 = 0
        _convert(senderAddr, &a, &b, &c, &d, &port);
        senderAddr.deallocate()
        let address = Address(a, b, c, d, UInt16(port))
        return TCPSocket(handle: handle, address: address)
    }

    public final func connect(host: String, port: UInt16) throws {
        try host.withCString { cString in 
            if !_connect(handle, cString, port) {
                throw SocketError.socketConnectError
            }
        }
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
    
    public final func send(data: [UInt8]) -> Int {
        var msg = data
        return Int(_sendData(handle, &msg, msg.count))
    }
    
    public final func receive(buffer: inout [UInt8]) -> Int {
        return Int(_receiveData(handle, &buffer, buffer.count))
    }

    public final func receive(buffer: UnsafeMutablePointer<UInt8>?, count: Int) -> Int {
        return Int(_receiveData(handle, buffer, count))
    }
    
    deinit {
        if !acceptedSocket {
            _shutdownSocket()
        }
    }
}