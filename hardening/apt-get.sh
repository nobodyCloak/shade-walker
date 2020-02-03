#!/bin/bash

# 1. Add default distro repos
echo "Installing lsb-release"
apt-get install lsb-release -y
lsb-release -a | grep 'Codename' > codename.txt
echo "Adding default repos just in case"
codename="$(cut -f2 -d$'\t' codename.txt)
debian_repo=\"deb http://deb.debian.org/debian $codename main
deb-src http://deb.debian.org/debian $codename main

deb http://deb.debian.org/debian-security/ $codename/updates main
deb-src http://deb.debian.org/debian-security/ $codename/updates main

deb http://deb.debian.org/debian $codename-updates main
deb-src http://deb.debian.org/debian $codename-updates main\""






# empty space to help coordinate
















































echo $debian_repo | sudo tee /etc/apt/sources.list.d/master.list

# 2. Install nmap, htop, 7zip (for easy encryption of sensitive data)
apt-get update
apt-get install apt -y
apt install nmap htop p7zip iptables -y

# 3. Update all packages
# 4. run nmap (pipe into file for later use)

apt update -y & nmap -p- 127.0.0.1 -oN open_ports.txt
wait
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
    sudo iptables -A INPUT -d tcp --dport $port_number -j REJECT
    sudo iptables -A OUTPUT -d tcp --dport $port_number -j REJECT
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

for user in $(cut -f1 -d: /etc/passwd); do
	echo $user
	sudo crontab -u $user -l
done

rm users_list.txt
apt autoremove -y

curl -O rkhunter-1.4.6.tar.gz https://svwh.dl.sourceforge.net/project/rkhunter/rkhunter/1.4.6/rkhunter-1.4.6.tar.gz
wait
tar -zxvf rkhunter-1.4.6.tar.gz
sudo sh rkhunter-1.4.6/installer.sh --install
sudo rkhunter -c --rwo --sk > rkhunter_results.txt
cat rkhunter_results.txt


curl -O maldetect-current.tar.gz http://www.rfxn.com/downloads/maldetect-current.tar.gz
wait
tar -zxvf maldetect-current.tar.gz
cd maldetect-*
sudo sh install.sh

maldetect-*/files/./maldetect


