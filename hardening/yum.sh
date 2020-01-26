#!/bin/bash

centOS_repo="[base]
name=CentOS-$releasever - Base
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=
$basearch&repo=os
#baseurl=http://mirror.centos.org/centos/$releasever/os/$basearch/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
priority=1

#released updates 
[updates]
name=CentOS-$releasever - Updates
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=
$basearch&repo=updates
#baseurl=http://mirror.centos.org/centos/$releasever/updates/$basearch/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
priority=1

#packages used/produced in the build but not released
[addons]
name=CentOS-$releasever - Addons
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=
$basearch&repo=addons
#baseurl=http://mirror.centos.org/centos/$releasever/addons/$basearch/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
priority=1

#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=
$basearch&repo=extras
#baseurl=http://mirror.centos.org/centos/$releasever/extras/$basearch/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
priority=1

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=
$basearch&repo=centosplus
#baseurl=http://mirror.centos.org/centos/$releasever/centosplus/$basearch/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
priority=2

#contrib - packages by Centos Users
[contrib]
name=CentOS-$releasever - Contrib
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=
$basearch&repo=contrib
#baseurl=http://mirror.centos.org/centos/$releasever/contrib/$basearch/
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
priority=2"

echo "$centOS_repo" > /etc/yum.repos.d/Centos-Base1.repo

# make sure that default centOS repos are there (so we can for sure install normal packages like nmap and htop)

yum install nmap htop -y
yum update -y & nmap 127.0.0.1 > open_ports.txt
wait
grep -A 200 PORT open_ports.txt | grep '\n' | grep -v Nmap | grep -o '[0-9]*' > open_port_numbers.txt
cat open_ports.txt

while IFS= read -r port_number; do
    iptables -A INPUT -d tcp --dport $port_number -j REJECT
    iptables -A OUTPUT -d tcp --dport $port_number -j REJECT
    # iptables -A INPUT -d udp --dport $port_number -j REJECT
    # iptables -A OUTPUT -d udp --dport $port_number -j REJECT
done < open_port_numbers.txt
cut -d: -f1 /etc/passwd > users_list.txt
while IFS= read -r required_user; do
    echo -n "Input users that need bash access (including root). Enter 'done' when done"
    read required_user
    sed '/$required_user/d' users_list.txt > new_users_list.txt
    mv new_users_list.txt users_list.txt
    if [ "$required_user" == "done" ];
    break
    fi
done

while IFS= read -r users; do
    usermod -s /sbin/nologin $users
done < users_list


#!/bin/bash
nmap localhost > open_ports.txt
grep -A 200 PORT open_ports.txt | grep '\n' | grep -v Nmap | grep -o '[0-9]*' > open_port_numbers.txt
cat open_ports.txt
while True; do
	echo -n "Input port numbers that must not be closed. Number only."
	read port_number
	sed '/$port_number/d' open_port_numbers.txt > new_open_port_numbers.txt
	mv new_open_port_numbers.txt open_port_numbers.txt
	if [ "$port_number" == "done" ]; then
	break
	fi
done



