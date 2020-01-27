#!/bin/bash

# 1. Add default distro repos

debian_repo=""

echo $debian_repo > /etc/yum.repos.d/Centos-Base1.repo

# 2. Install nmap, htop, 7zip (for easy encryption of sensitive data)
apt-get install apt -y

apt install nmap htop p7zip iptables -y

# 3. Update all packages
# 4. run nmap (pipe into file for later use)

apt update -y & nmap 127.0.0.1 > open_ports.txt
wait
apt autoremove -y
grep -A 200 PORT open_ports.txt | grep '\n' | grep -v Nmap | grep -o '[0-9]*' > open_port_numbers.txt
cat open_ports.txt

while True; do
	echo -n "Input port numbers that must NOT be closed. Number only. Enter 'done' when done"
	read port_number
	sed /$port_number/d open_port_numbers.txt > new_open_port_numbers.txt
	mv new_open_port_numbers.txt open_port_numbers.txt
	if [ $port_number = "done" ]; then
	break
	fi
done

# 5. block unnecessary open ports (iptables)

while IFS= read -r port_number; do
    iptables -A INPUT -d tcp --dport $port_number -j REJECT
    iptables -A OUTPUT -d tcp --dport $port_number -j REJECT
    # iptables -A INPUT -d udp --dport $port_number -j REJECT
    # iptables -A OUTPUT -d udp --dport $port_number -j REJECT
done < open_port_numbers.txt

rm open_port_numbers.txt && rm open_ports.txt
nmap 127.0.0.1

cut -d: -f1 /etc/passwd > users_list.txt

while IFS= read -r required_user; do
    echo -n "Input users that need bash access (including root). Enter 'done' when done"
    read required_user
    sed /$required_user/d users_list.txt > new_users_list.txt
    mv new_users_list.txt users_list.txt
    if [ $required_user = "done" ];
    break
    fi
done

# 7. Remove all unnecessary shell access for users


while IFS= read -r users; do
    usermod -s /sbin/nologin $users
done < users_list.txt

rm users_list.txt

curl -O rkhunter-1.4.6.tar.gz https://svwh.dl.sourceforge.net/project/rkhunter/rkhunter/1.4.6/rkhunter-1.4.6.tar.gz
