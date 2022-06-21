//
//  main.swift
//  
//
//  Created by Sebastian Toivonen on 9.1.2021.
//

@main
struct App {
    public static func main() async throws {
        try UDPTest()
        try await TCPTest()
    }
}
