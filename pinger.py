#!/usr/local/bin/python3

import os
import subprocess

hosts = ["35.194.248.244", "35.247.252.87", "35.241.84.207", "35.200.228.171", "www.sohu.com"]

def start_ping(host, count):
    p = subprocess.Popen(["ping", "-c", str(count), host], stdout=subprocess.PIPE)
    return p

def get_output(proc):
    proc.wait()

    lines = proc.stdout.readlines()

    output = ''
    size = len(lines)
    i = 0
    for l in lines:
        i = i + 1
        if i > size - 3:
            output += l.decode("utf-8")

    return output

print("\0337");
while True:
    count = 3
    ps = [None] * len(hosts)
    for i in range(len(hosts)):
        ps[i] = start_ping(hosts[i], count)

    rs = [None] * len(hosts)
    for i in range(len(ps)):
        rs[i] = get_output(ps[i])

    print("\0338");
    print('--------------------------------------------------------------------------------')
    for i in range(len(rs)):
        print(rs[i])
