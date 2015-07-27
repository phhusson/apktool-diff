#!/bin/bash

base="$(dirname "$(readlink -f -- "$0")")"
find -name \*.xml -print0 |TMPDIR=/tmpfs/ xargs -0 -P 16 -n 1 bash $base/clean.sh

#Rename folders to contain minimum version number
find -type d -name values-\* -or -name layout-\* -or drawable-\* |while read i;do
	#If it already has one, leave it
	if echo "$i" |grep -E -- '-v[0-9]+';then
		continue
	#If it doesn't sort by higher version to lower
	elif echo "$i" |grep -E 'sw(600|720)dp';then
		mv "$i" "$i-v13"
	elif echo "$i" |grep -E '(m|h)dpi';then
		mv "$i" "$i-v4"
	fi

done

