#!/bin/bash

base="$(dirname "$(readlink -f -- "$0")")"
rm -f t.xml
find -name \*.xml -print0 |TMPDIR=/tmpfs/ xargs -0 -P 16 -n 1 bash $base/clean.sh
rm -f t.xml

#Rename folders to contain minimum version number
find -type d -name values-\* -or -name layout-\* -or -name drawable-\* -or -name mipmap-\* |while read i;do
	#If it already has one, leave it
	if echo "$i" |grep -E -- '-v[0-9]+' > /dev/null;then
		continue
	#If it doesn't sort by higher version to lower
	elif echo "$i" |grep -E 'sw(600|720)dp' >/dev/null || echo "$i" |grep -E 'h480dp' > /dev/null;then
		mv "$i" "$i-v13"
		echo mv "$i" "$i-v13"
	elif echo "$i" |grep -E '(m|h|no)dpi' >/dev/null;then
		mv "$i" "$i-v4"
		echo mv "$i" "$i-v4"
	fi

done

find -name values-\* |xargs -I toto find toto -name \*.txt -delete
find -name values-\* |xargs -I toto find toto -name \*.xml -exec bash $base/clean-xml.sh '{}' \;
find -name values-\* |xargs -I toto find toto -name \*.txt -exec bash $base/sort.sh '{}' \;
