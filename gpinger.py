#!/Library/Frameworks/Python.framework/Versions/3.6/bin/python3

import os
import subprocess
import tkinter as tk  # imports
from tkinter import ttk
from tkinter import *

hosts = [
    "35.194.248.244", "35.247.252.87", "35.241.84.207", "35.200.228.171",
    "35.204.30.91", "149.28.28.119", "www.sohu.com", "112.213.117.196"
]


def start_ping(host):
    proc = subprocess.Popen(["ping", host], stdout=subprocess.PIPE)
    return proc


def get_output(proc):
    return proc.stdout.readline().decode("utf-8")


def create_tab(host, tab_control):
    tab = ttk.Frame(tab_control)
    tab.pack(fill="both", expand=True)
    text = Text(tab)
    text.pack(fill="both", side=LEFT, expand=True)
    scrollbar = ttk.Scrollbar(tab, command=text.yview)
    scrollbar.pack(fill="y", side=RIGHT)
    text['yscrollcommand'] = scrollbar.set
    tab_control.add(tab, text=host)
    return start_ping(host), text



win = tk.Tk()  # Create instance
p = PhotoImage(file='/Users/darwin/tools/scripts/ping_pong_72px_501075_easyicon.net.png')
win.tk.call('wm', 'iconphoto', win._w, p)
win.title("Pinger")  # Add a title
tabControl = ttk.Notebook(win)  # Create Tab Control

pl = [None] * len(hosts)
i = 0
for h in hosts:
    pl[i] = create_tab(hosts[i], tabControl)
    i += 1


def clock():
    for p in pl:
        proc = p[0]
        text = p[1]
        text.configure(state='normal')
        text.insert(END, get_output(proc))
        text.configure(state='disabled')
        text.see("end")
    win.after(1000, clock)  # run itself again after 1000 ms


clock()
tabControl.pack(expand=1, fill="both")
win.mainloop()
