#!/bin/bash

source color.sh

#VARIABLES FIELD
executed=0
target=$1
target_ipv4=$(./urltoip.sh $target)

echo -e "\n${bold}${white}Running ${red}Nmap TCP Scan Ports ${white}against ${red}$target${white}...\n${reset}"
tcp_result=$(nmap -Pn -sS "$target" | tee /dev/tty)

#IDENTIFYING AND SELECTING PORTS AND SERVICES RUNNING
tcpports=$(echo "$tcp_result" | grep "/tcp" | grep "open" | cut -d'/' -f1)
tcpservices=$(echo "$tcp_result" | grep "/tcp" | grep "open" | awk '{for (i=4; i<=NF; i++) printf $i " "; print ""}')

for port in $tcpports; do
	if [ $port -eq 443 ]; then #TESTS AGAINST 443
		echo -e "\n\n\n\n${bold}${white}Running ${red}protocols and ciphers ${white}checks against ${red}$target${white}...${reset} \n"
		testssl -s -e -U -p $target; sleep 5
		echo -e "\n\n\n\n${bold}${white}Running ${red}certificates ${white}checks against ${red}$target${white}...${reset} \n"
		sslscan $target_ipv4; sleep 5
		if [ $executed -eq 0 ]; then
			echo -e "\n\n\n\n${bold}${white}Running ${red}banner grabbing ${white}checks against ${red}$target${white}...${reset}\n"
                        echo -e "HEAD / HTTP/1.1" | nc -v $target_ipv4 443; sleep 5
			echo -e "\n\n\n\n${bold}${white}Running ${red}Fuzzing archives and directories ${white}against ${red}$target${white}...${reset} \n"
			ffuf -w /usr/share/seclists/Discovery/Web-Content/raft-large-directories.txt -u https://$target/FUZZ -fc 301,404; sleep 5
 			echo -e "\n\n\n\n${bold}${white}Running ${red}security headers ${white}checks against ${red}$target${white}...${reset} \n"
			python3 /home/sl1mshady/useful_scripts/pentest_tools/shcheck/shcheck.py https://$target; sleep 5
			echo -e "\n\n\n\n${bold}${white}Running ${red}Clickjacking ${white}checks against ${red}$target${white}...${reset} \n"
			python3 /home/sl1mshady/useful_scripts/pentest_tools/clickjack/clickjack.py https://$target; sleep 5
			executed=1
		fi
		echo -e "\n\n\n\n${bold}${white}Running ${red}vulnerability scan ${white}against ${red}$target:443${white}...${reset} \n"
		nikto -h $target -port 443; sleep 5
		echo -e "\n\n\n\n${bold}${white}Running ${red}WAF ${white}checks against ${red}$target:443${white}...${reset} \n"
		wafw00f $target; sleep 5
	fi
	if [ $port -eq 80 ]; then #TESTS AGAINST 80
		if [ $executed -eq 0 ]; then
			echo -e "\n\n\n\n${bold}${white}Running ${red}banner grabbing ${white}checks against ${red}$target${white}...${reset}\n"
			echo -e "HEAD / HTTP/1.1" | nc -v $target_ipv4 80; sleep 5 
 			echo -e "\n\n\n\n${bold}${white}Running ${red}fuzzing archives and directories ${white}against ${red}$target${white}...${reset} \n"
			ffuf -w /usr/share/seclists/Discovery/Web-Content/raft-large-directories.txt -u http://$target/FUZZ -fc 301,404; sleep 5
			echo -e "\n\n\n\n${bold}${white}Running ${red}security headers ${white}checks against ${red}$target${white}...${reset} \n"
			python3 /home/sl1mshady/useful_scripts/pentest_tools/shcheck/shcheck.py http://$target; sleep 5
			echo -e "\n\n\n\n${bold}${white}Running ${red}Clickjacking ${white}checks against ${red}$target${white}...${reset} \n"
                        python3 /home/sl1mshady/useful_scripts/pentest_tools/clickjack/clickjack.py http://$target; sleep 5
			executed=1
		fi
		echo -e "\n\n\n\n${bold}${white}Running ${red}vulnerability scan ${white}against ${red}$target:80${white}...${reset} \n"
		nikto -h $target -port 80; sleep 5
	fi
	if [ $port -eq 22 ]; then #TESTS AGAINST 22
		python3 /home/sl1mshady/useful_scripts/pentest_tools/ssh-audit/ssh-audit.py $target_ipv4
	fi #NEW PORTS TO BE ADDED HERE
done

echo -e "\n\n\n\n${bold}${white}Running ${red}Nmap --script=vuln ${white}to ${red}$target${white}...${reset} \n"
nmap -Pn -sV -p$(echo $tcpports | tr '\n' ' ' | sed 's/ \+/,/g; s/,$//') $target --script=vuln; sleep 10

echo -e "\n\n\n\n${bold}${white}Running ${red}Nmap UDP Scan Ports ${white}to ${red}$target${white}...${reset} \n"
nmap -Pn -sUV -p- $target

echo -e "${bold}${red}Phoenix ${white}is gonna rest now!${reset}"
