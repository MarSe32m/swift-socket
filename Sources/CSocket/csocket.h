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

bool initializeSocket();
void shutdownSocket();

int createUDPSocket();

bool openSocket(int handle, unsigned short port);
void closeSocket(int handle);

bool set_blocking_mode(int handle, bool is_blocking);

bool set_non_blocking(int handle);

bool sendData(int handle, const unsigned char* data, size_t length, unsigned int a, unsigned int b, unsigned int c, unsigned int d, unsigned short port);

int receiveData(int handle, unsigned char* data, size_t length, unsigned int* a, unsigned int* b, unsigned int* c, unsigned int* d, unsigned int* port);

#endif /* csocket_h */
