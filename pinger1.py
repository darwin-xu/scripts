#!/usr/local/bin/python3

import os
import subprocess

hosts = ["35.194.248.244", "35.247.252.87", "35.241.84.207", "35.200.228.171", "www.sohu.com"]
qs = [None] * len(hosts)

def start_ping(host):
    p = subprocess.Popen(["ping", host], stdout=subprocess.PIPE)
    return p

def get_output(proc):
    line = proc.stdout.readline().decode("utf-8")
    return line

print("\0337");
p = start_ping(hosts[0])
r = []
while True:
    r.append(get_output(p))

    if len(r) > 10:
        r.pop(0)

    print("\0338");
    for rr in r:
        print(rr, end='')
