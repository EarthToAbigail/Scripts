#!/bin/bash

# Performs a custom serie of nmap scans to get a general idea of a given network range.
# It starts by a nmap ping sweep of the given network and saves the results in a grepable output to
# a file. It then proceeds to scan the most popular services on all hosts responding and returns version
# informations.

# Print usage if no arguments are provided.
if [[ -z $1 ]]; then

  printf "\n[*] Performs a custom serie of scans to get a general idea of a given network range."
  printf "\n[*] Usage ex:  $0 10.11.1.1-255"
  printf "\n[*] The sweep will be done over a range of 1-255.\n"
  exit 0
fi

# Save the file name for the report in a variable.
file="network-overview.txt"

# Nmap Ping Sweep. Output is saved to a file in a grepable format.
printf "\n[*] Initializing a Ping sweep..."

ips=$(nmap -sn $1 -oG network-scan.txt)

printf "\n[*] IPs responding: \n"

cat network-scan.txt |grep "Host" |cut -d " " -f 2 > network-list.txt
cat network-list.txt
printf "\n"

counter=$(wc -l network-list.txt |cut -d" " -f 1)
printf "[*] $counter hosts are UP.\n"

printf "\nNetwork-Sweep Report\n" >$file
printf "\n[*] $counter hosts are UP. (See 'network-list.txt' for full list of IPs)\n" >>$file

# Nmap version scan for ports 80, 443, 139, 445
printf "\n[*] Scanning found hosts for ports 80 and 443 (http, https), 139 and 445 (netbios, smb)... "
printf "\n[*] Hosts with open ports 80, 443, 139 or 445 found with version info: \n"

printf "\nHosts with open ports 80 (http), 443 (https) or 139 (netbios), 445 (smb) found with version info: \n" >>$file

for ip in $( cat network-list.txt ); do

  results=$( nmap -sV -p 80,443,139,445 $ip | grep "open " )

  if [[ ! -z $results ]]; then
    printf "\n[+] $ip\n$results\n" >>$file
    printf "\n[+] $ip\n$results\n"
  fi

done
printf "\n"

# Perform a simple nbtscan
printf "\n[*] Performing nbtscan on network...\n"
printf "\nNBTSCAN Results:\n" >>$file

results=$( nbtscan $1 )
printf "\n$results\n"
printf "\n$results\n" >>$file

# Perform SMTP enumeration
printf "\n[*] Scanning for open port 25 and performing user enumeration...\n"
printf "\nHosts with open port 25 and user enumeration attempt:\n" >>$file

for ip in $( cat network-list.txt ); do

  results=$( nmap -sV -p 25 $ip --open |grep "open " )

  if [[ ! -z $results ]]; then
    printf "\n[+] $ip\n$results\n" >>$file
    printf "\n[+] $ip\n$results\n"
    printf "[*] Attempting user enumeration...\n"
    enum=$( nmap --script smtp-enum-users.nse $ip )
    printf "$enum\n"
    printf "$enum\n" >>$file
  fi
done

# Perform open port 161 detection
printf "\n[*] Scanning for open udp port 161 and performing version detection...\n"
printf "\nHosts with open udp port 161 and version detection:\n" >>$file

for ip in $( cat network-list.txt ); do

  results=$( nmap -sV -sU -p 161 $ip --open |grep "open " )
  if [[ ! -z $results ]]; then
    printf "\n[+] $ip\n$results\n" >>$file
    printf "\n[+] $ip\n$results\n"
  fi
done

printf "\n"
printf "[+] Network sweep completed succesfully!\n"
# Remove network-scan.txt to leave only the clean list of IPs.
rm network-scan.txt

exit 0
