//
//  main.swift
//  
//
//  Created by Sebastian Toivonen on 9.1.2021.
//

import Foundation
import CSocket
#if os(Windows)
import WinSDK
#endif
let port: UInt16 = 25566
let socket = try Socket()
try socket.open(port: port)
try socket.setNonBlocking()
var data: [UInt8] = [1, 2, 3, 4, 5, 6, 7, 8]
if !socket.send(data: data, address: Address(127, 0, 0, 1, port)) {
    print("Couldn't send data!")
}

var receivedPackets = 0
let maxSent = 1_000_000
while receivedPackets < maxSent {
    let (data, address) = socket.receive()
    if let address = address {
        receivedPackets += 1
        //print(data, address)
    } else {
        break
    }
    socket.send(data: data, address: Address(127, 0, 0, 1, port))
    socket.send(data: data, address: Address(127, 0, 0, 1, port))
    socket.send(data: data, address: Address(127, 0, 0, 1, port))
    socket.send(data: data, address: Address(127, 0, 0, 1, port))
}
print("Done", receivedPackets)
