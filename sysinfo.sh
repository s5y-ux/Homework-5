#!/bin/bash
FORMAT="\t   \e[1m%-20s\e[0m%s\n"

printf "\t(*)=============================(*)\n"
printf "$FORMAT" "User:" "$(whoami)"
printf "$FORMAT" "Date:" "$(date)"
printf "$FORMAT" "Hostname:" "$(hostname)"
printf "$FORMAT" "Uptime:" "$(uptime -p)"
printf "$FORMAT" "Users Logged In:" "$(users)"
printf "$FORMAT" "Default Shell:" "$SHELL"  
printf "\t(*)=============================(*)\n"

