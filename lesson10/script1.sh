#!/bin/bash
cd /home/test
mkdir -p myfolder
cd ./myfolder
echo "HELLO" > "1.txt"
echo "TIME: $(date)" >> "1.txt"
touch 2.txt
chmod 777 2.txt
head /dev/urandom | tr -dc A-Za-z0-9 | head -c 20 > 3.txt
touch 4.txt
touch 5.txt
