public enum SocketError: Error {
    case initializationError
    case handleCreationError
    case socketOpenError
    case socketConnectError
    case socketListenError
    case socketAcceptError
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