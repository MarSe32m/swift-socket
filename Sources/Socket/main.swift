//
//  main.swift
//  
//
//  Created by Sebastian Toivonen on 9.1.2021.
//

import Foundation
import CSocket

let socket = try Socket()
try socket.open(port: 25565)
try socket.setNonBlocking()
var data: [UInt8] = [1, 2, 3, 4, 5, 6, 7, 8]
if !socket.send(data: data, address: Address(127, 0, 0, 1, 25565)) {
    print("Couldn't send data!")
}
if #available(macOS 10.12, *) {
    Thread.detachNewThread {
        for i in 0..<1_000_000 {
            socket.send(data: data, address: Address(127, 0, 0, 1, 25565))
            if i % 10_000 == 0 {
                print(i)
            }
        }
        print("Done sending")
    }
} else {
    // Fallback on earlier versions
}

var receivedPackets = 0
while true {
    let (data, address) = socket.receive()
    if let address = address {
        receivedPackets += 1
        print(data, address)
    } else {
        break
    }
}
print("Done", receivedPackets)
