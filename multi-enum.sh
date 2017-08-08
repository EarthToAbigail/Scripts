#!/bin/bash

# This script performs enum4linux with enumeration flags -U -P -S -G -o -n for the IPs specified in a given file.
# It saves it's output to seperate files in the corresponding IP folders in Lab-Notes directory. If
# no folder is there, it will create it.

if [[ -z $1  ]]; then

  printf "\n[*] Usage: $0 [ options ] < /path/to/file.txt >\n"
  printf "[*] Options: -smb , -snmp \n"
  printf "[*] Only specifying the file name will perform SMB and SMTP scans and reports.\n"
  printf "\n"
  exit 0
fi

if [[ $# -lt 2 ]]; then
  file=$1
fi

printf "\n[*] This script performs enum4linux default enumeration flags or snmp-check with default version 1 "
printf "\n[*] for the IPs specified in a given file. If only a file name is given, all scans will be performed."
printf "\n[*] It saves it's output to seperate files in the corresponding IP folders in LAB directory."
printf "\n[*] If no folder is there, it will create it.\n\n"

if [[ $# -lt 2 ]] || [[ $1 == "-smb" ]]; then
  file=$2
  for ip in $( cat $file ); do

    path="/mnt/hgfs/OSCP/LAB/$ip"
    mkdir $path 2>/dev/null
    printf "\n[*] Executing SMB report for $ip...\n"
    filename="$path/$ip-smb.txt"
    enum4linux -U -P -G -S -o -n $ip >"$filename" 2>/dev/null
    printf "[*] Report done. File saved as $ip-smb.txt in $path directory.\n"
    printf "[*] Moving on...\n"
  done

elif [[ $# -lt 3 ]] || [[ $1 == "-snmp" ]]; then
  file=$2
  for ip in $( cat $file ); do
    path="/mnt/hgfs/OSCP/LAB/$ip"
    mkdir $path 2>/dev/null
    printf "\n[*] Executing SNMP report for $ip...\n"
    filename="$path/$ip-snmp.txt"
    snmp-check -w $ip >"$filename" 2>/dev/null
    printf "[*] Report done. File saved as $ip-snmp.txt in $path directory.\n"
    printf "[*] Moving on...\n"
  done
fi

counter=$( wc -l $file |cut -d" " -f 1 )
printf "\nAll reports completed. $counter hosts scanned. All files saved.\n"

exit 0
