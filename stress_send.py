#!/usr/local/bin/python3

import socket
import time
import sys
import getopt

MESSAGE = "Hello, World!" * 100
PORT = 5005

def tcp_send(dst):
    server_address = (dst, PORT)
    sock = socket.socket(socket.AF_INET,
                         socket.SOCK_STREAM)
    sock.connect(server_address)

    last = 0
    size = 0

    while True:    
        sock.sendall(MESSAGE.encode())
        now = time.time()
        size += len(MESSAGE)
        if (now - last >= 1):
            print(f'{size:,}')
            size = 0
            last = now

def udp_send(dst):
    server_address = (dst, PORT)
    sock = socket.socket(socket.AF_INET,
                         socket.SOCK_DGRAM)

    last = 0
    size = 0

    while True:
        sock.sendto(MESSAGE.encode(), server_address)
        now = time.time()
        size += len(MESSAGE)
        if (now - last >= 1):
            print(f'{size:,}')
            size = 0
            last = now

def main(argv):
    dst = argv[0]
    if argv[1] == "tcp":
        tcp_send(dst)
    else:
        udp_send(dst)

if __name__ == "__main__":
    main(sys.argv[1:])
