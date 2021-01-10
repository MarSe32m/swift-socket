//
//  socket.c
//  
//
//  Created by Sebastian Toivonen on 9.1.2021.
//

#include "csocket.h"

#define PLATFORM_WINDOWS  1
#define PLATFORM_MAC      2
#define PLATFORM_UNIX     3

#if defined(_WIN32)
#define PLATFORM PLATFORM_WINDOWS
#elif defined(__APPLE__)
#define PLATFORM PLATFORM_MAC
#else
#define PLATFORM PLATFORM_UNIX
#endif

#if PLATFORM == PLATFORM_WINDOWS
#include <winsock2.h>
#elif PLATFORM == PLATFORM_MAC || PLATFORM == PLATFORM_UNIX
#include <sys/socket.h>
#include <netinet/in.h>
#include <fcntl.h>
#endif

#if PLATFORM == PLATFORM_WINDOWS
#pragma comment( lib, "wsock32.lib" )
#endif

bool initializeSocket() {
    #if PLATFORM == PLATFORM_WINDOWS
    WSADATA WsaData;
    return WSAStartup(MAKEWORD(2,2), &WsaData) == NO_ERROR;
    #else
    return true;
    #endif
}

void shutdownSocket() {
    #if PLATFORM == PLATFORM_WINDOWS
    WSACleanup();
    #endif
}

int createUDPSocket() {
    return socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
}

bool openSocket(int handle, unsigned short port) {
    struct sockaddr_in address;
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(port);
    
    return bind(handle, (const struct sockaddr*) &address, sizeof(struct sockaddr_in)) >= 0;
}

void closeSocket(int handle) {
#if PLATFORM == PLATFORM_MAC || PLATFORM == PLATFORM_UNIX
    close(handle);
#elif PLATFORM == PLATFORM_WINDOWS
    closesocket(handle);
#endif
}

bool set_blocking_mode(int handle, bool is_blocking) {
#if PLATFORM == PLATFORM_WINDOWS
    DWORD non_blocking = is_blocking ? 0 : 1;
    return NO_ERROR == ioctlsocket(handle, FIONBIO, &non_blocking);
#elif PLATFORM == PLATFORM_MAC || PLATFORM == PLATFORM_UNIX
    const int flags = fcntl(handle, F_GETFL, 0);
    if ((flags & O_NONBLOCK) && !is_blocking) {
        return true;
    }
    if (!(flags & O_NONBLOCK) && is_blocking) {
        return true;
    }
    return 0 == fcntl(socket, F_SETFL, is_blocking ? flags ^ O_NONBLOCK : flags | O_NONBLOCK);
#endif
}

bool set_non_blocking(int handle) {
    #if PLATFORM == PLATFORM_MAC || PLATFORM == PLATFORM_UNIX
        int nonBlocking = 1;
        if (fcntl(handle, F_SETFL, O_NONBLOCK, nonBlocking) == -1) {
            return false;
        }
    #elif PLATFORM == PLATFORM_WINDOWS
        DWORD nonBlocking = 1;
        if (ioctlsocket(handle, FIONBIO, &nonBlocking) != 0 ) {
            return false;
        }
    #endif
    return true;
}

bool sendData(int handle, const unsigned char* data, size_t length, unsigned int a, unsigned int b, unsigned int c, unsigned int d, unsigned short port) {
    unsigned int address = (a << 24) | (b << 16) | (c << 8) | d;
    struct sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(address);
    addr.sin_port = htons(port);
    
    int sent_bytes = sendto(handle, data, length, 0, (const struct sockaddr*)&addr, sizeof(struct sockaddr_in));
    return sent_bytes == length;
}

int receiveData(int handle, unsigned char* data, size_t length, unsigned int* a, unsigned int* b, unsigned int* c, unsigned int* d, unsigned int* port) {
    #if PLATFORM == PLATFORM_WINDOWS
    typedef int socklen_t;
    #endif
    
    struct sockaddr_in from;
    socklen_t fromLength = sizeof(from);

    int bytes = recvfrom(handle, data, length, 0, (struct sockaddr*) &from, &fromLength);
    
    char bytess[8];
    for (int i = 0; i < 8; i++)
        bytess[i] = data[i];
    
    unsigned int from_address = ntohl(from.sin_addr.s_addr);
    *a = (from_address >> 24) & 0xFF;
    *b = (from_address >> 16) & 0xFF;
    *c = (from_address >> 8) & 0xFF;
    *d = (from_address >> 0) & 0xFF;

    *port = ntohs(from.sin_port);
    return bytes;
}
