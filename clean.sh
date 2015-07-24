#!/bin/bash

set -e

echo "Processing $1 ..."
xmlstarlet c14n --without-comments "$1" \
	|xmlstarlet fo \
	|xmlstarlet ed --delete '//comment()' \
	|xmlstarlet pyx |grep -vE -- '^-(\\n|\s|\\t)*$' |xmlstarlet p2x  \
	|xmlstarlet ed --delete '//@msgid' \
	|xmlstarlet ed --delete '//skip' \
	|xmlstarlet fo > t.xml

# 3d(i)p => 3.0 dip
sed -i -E 's/"([0-9]+)di?p"/"\1.0dip"/g' t.xml

#3sp => 3.0sp
sed -i -E 's/"([0-9]+)sp"/"\1.0sp"/g' t.xml

# 3px => 3.0px
sed -i -E 's/"([0-9]+)px"/"\1.0px"/g' t.xml

# 50% => 50.0%
sed -i -E 's/"([0-9]+)%"/"\1.0%"/g' t.xml

# 50% => 50.0%
sed -i -E 's/"([0-9]+)"/"\1.0"/g' t.xml

#?attr/ic_toto => ?ic_toto
#?android:attr/ic_toto => ?android:ic_toto
sed -i -E 's;(\?|\?android:)attr/;\1;g' t.xml

# @*android => @android
sed -i -E 's;@\*android;@android;g' t.xml

# @+android => @android
sed -i -E 's;@\+android;@android;g' t.xml

# @+id => @id
sed -i -E 's;@\+id;@id;g' t.xml

# @@android => @android
sed -i -E 's;@@android;@android;g' t.xml

# @@string => @string
sed -i -E 's;@@string;@string;g' t.xml

sed -i -E 's;"fill_parent";"match_parent";g' t.xml

mv -f t.xml "$1"

echo "Done processing $1"
