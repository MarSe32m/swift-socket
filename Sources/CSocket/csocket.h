//
//  Header.h
//  
//
//  Created by Sebastian Toivonen on 9.1.2021.
//

#ifndef csocket_h
#define csocket_h

#include "stdbool.h"
#include "stddef.h"

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

bool _initializeSocket();
void _shutdownSocket();

int _createUDPSocket();
int _createTCPSocket();

bool _openSocket(int handle, unsigned short port);
void _closeSocket(int handle);

bool _connect(int handle, const char* hostname, unsigned short port);
bool _listen(int handle, int backlog);
int _accept(int handle, struct sockaddr_in *clientAddress);

bool _sendDataTo(int handle, const unsigned char* data, size_t length, unsigned int a, unsigned int b, unsigned int c, unsigned int d, unsigned short port);
int _receiveDataFrom(int handle, unsigned char* data, size_t length, unsigned int* a, unsigned int* b, unsigned int* c, unsigned int* d, unsigned int* port);

int _sendData(int handle, const unsigned char* data, size_t length);
int _receiveData(int handle, unsigned char* data, size_t length);

void _convert(struct sockaddr_in* address, unsigned int* a, unsigned int* b, unsigned int* c, unsigned int* d, unsigned int* port);

bool _set_blocking_mode(int handle, bool is_blocking);
bool _set_non_blocking(int handle);


#endif /* csocket_h */