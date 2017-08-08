#!/usr/bin/python

import socket
import sys

if len(sys.argv) != 3:

    print("[*] Usage: vrfy.py < ip > < file >")
    sys.exit(0)

else:

    try:
        ip = sys.argv[1]
        file = sys.argv[2]

        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        connect = s.connect((ip, 25))
        banner = s.recv(1024)
        print(banner)

        with open(file, "r") as n:
            users = n.readlines()

            for user in users:
            	if (user == ""):
            		pass
            	else:
	                username = user.strip()
	                print("Attempting with username " + username + "...")
	                s.send("VRFY " + username + "\r\n")
	                response = s.recv(1024)
	                print(response)
        	n.close()
        s.close()

    except KeyboardInterrupt as e:
        print("[-] Interrupted by user... Quitting!")
        sys.exit(1)

sys.exit(0)
