#!/usr/local/bin/python3

import socket
import time
import sys
import getopt

PORT = 5005
server_address = ('0.0.0.0', PORT)

def tcp_recv():
    sock = socket.socket(socket.AF_INET,
                         socket.SOCK_STREAM)
    sock.bind(server_address)
    sock.listen()
    while True:
        conn, addr = sock.accept()
        with conn:
            print('Connected by:', addr)
            last = 0
            size = 0
            while True:
                data = conn.recv(65535)
                if not data:
                    break;
                now = time.time()
                size += len(data)
                if (now - last >= 1):
                    print(f'{size:,}')
                    size = 0
                    last = now

def udp_recv():
    sock = socket.socket(socket.AF_INET,
                         socket.SOCK_DGRAM)


    sock.bind(server_address)

    last = 0
    size = 0

    while True:
        data, address = sock.recvfrom(65535)
        now = time.time()
        size += len(data)
        if (now - last >= 1):
            print(f'{size:,}')
            size = 0
            last = now


def main(argv):
    if argv[0] == "tcp":
        tcp_recv()
    else:
        udp_recv()

if __name__ == "__main__":
    main(sys.argv[1:])
