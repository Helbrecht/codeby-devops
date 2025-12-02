#!/bin/bash
cd /home/test/myfolder
filecount=$(ls | wc -l)
echo "File count: $filecount"
test -f 2.txt && chmod 664 2.txt && echo "Set 664 for 2.txt"

for file in ./*; do
	if [ ! -s "$file" ]; then
		rm "$file"
		echo "Removed null $file"
	fi
done
for file in ./*; do
	if [ -s "$file" ]; then
		sed -i '2,$d' "$file"
		echo "First line is saved in $file"
	fi
done
