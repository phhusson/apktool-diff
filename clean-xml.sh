#!/bin/bash

for i in bool dimen integer string;do
	xmlstarlet sel -t -m "//resources/$i" -v '@name' -o = -v 'text()' -n "$1" | sed -Ee 's/\="(.*)"$/\=\1/g' >> "$(dirname "$1")"/${i}.txt
	xmlstarlet ed -L --delete //resources/$i "$1"
done
