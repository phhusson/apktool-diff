#!/bin/bash

set -e

f="$(mktemp)"

echo "Processing $1 ..."
xmlstarlet c14n --without-comments "$1" |
	xmlstarlet fo |
	xmlstarlet ed --delete '//comment()' |
	xmlstarlet pyx | #Convert to pyx, easier to grep
		grep -vE -- '^-(\\n|\s|\\t)*$' | #Delete whitespace strings
	xmlstarlet p2x  | #Convert back to xml
	xmlstarlet ed --delete '//@msgid' | #Delete msgid=""
	xmlstarlet ed --delete '//skip' | #Delete <skip/>
	xmlstarlet fo > $f

# 3(.3dp => 3(.3)dip
sed -i -E 's/("[0-9]+(\.[0-9]*)?)dp"/\1dip"/g' $f

# 3d(i)p => 3.0 dip
sed -i -E 's/"(-?[0-9]+)(di?p|mm)"/"\1.0\2"/g' $f

#3sp => 3.0sp
sed -i -E 's/"([0-9]+)sp"/"\1.0sp"/g' $f

# 3px => 3.0px
sed -i -E 's/"([0-9]+)px"/"\1.0px"/g' $f

# 50% => 50.0%
sed -i -E 's/"([0-9]+)%"/"\1.0%"/g' $f

# 50% => 50.0%
sed -i -E 's/"([0-9]+)"/"\1.0"/g' $f

#?attr/ic_toto => ?ic_toto
#?android:attr/ic_toto => ?android:ic_toto
sed -i -E 's;(\?|\?android:)attr/;\1;g' $f

# @*android => @android
sed -i -E 's;@\*android;@android;g' $f

# @+android => @android
sed -i -E 's;@\+android;@android;g' $f

# @+id => @id
sed -i -E 's;@\+id;@id;g' $f

# @@android => @android
sed -i -E 's;@@android;@android;g' $f

# @@string => @string
sed -i -E 's;@@string;@string;g' $f


#---- start: Checking flags equivalencies ----
#TODO: Check those is true by reading framework-res ?
#See framework-res/res/values/attrs.xml [@name="gravity"]

# start|top = 0x00800003 | 0x00000030
# center = 0x00000011
# (start|top) & center == center;
# (start|top) == (start|top|center)

sed -i -E 's;android:gravity="top\|start";android:gravity="start\|center\|top";g' $f
sed -i -E 's;android:gravity="start\|top";android:gravity="start\|center\|top";g' $f

# fill_horizontal | top = 0x00000007 | 0x00000030
# center = 0x00000011
sed -i -E 's;android:gravity="fill_horizontal\|top";android:gravity="fill_horizontal|center|top";g' $f
sed -i -E 's;android:gravity="top\|fill_horizontal";android:gravity="fill_horizontal|center|top";g' $f

sed -i -E 's;android:layout_gravity="fill_horizontal\|top";android:layout_gravity="fill_horizontal|center|top";g' $f
sed -i -E 's;android:layout_gravity="top\|fill_horizontal";android:layout_gravity="fill_horizontal|center|top";g' $f

# start|bottom = 0x00800003 | 0x00000050
# center = 0x00000011
# (start|bottom) & center == center;
# (start|bottom) == (start|bottom|center)
sed -i -E 's;android:gravity="bottom\|start";android:gravity="start\|center\|bottom";g' $f
sed -i -E 's;android:gravity="start\|bottom";android:gravity="start\|center\|bottom";g' $f

sed -i -E 's;android:layout_gravity="bottom\|start";android:layout_gravity="start\|bottom\|center";g' $f
sed -i -E 's;android:layout_gravity="start\|bottom";android:layout_gravity="start\|bottom\|center";g' $f

#Same thing for bottom/end == center
sed -i -E 's;android:layout_gravity="bottom\|end";android:layout_gravity="end\|bottom\|center";g' $f
sed -i -E 's;android:layout_gravity="end\|bottom";android:layout_gravity="end\|bottom\|center";g' $f

sed -i -E 's;android:gravity="end\|bottom";android:gravity="end\|bottom\|center";g' $f
sed -i -E 's;android:gravity="bottom\|end";android:gravity="end\|bottom\|center";g' $f

#Same thing for left/bottom
sed -i -E 's;android:layout_gravity="left\|bottom";android:layout_gravity="bottom\|center\|left";g' $f
sed -i -E 's;android:layout_gravity="bottom\|left";android:layout_gravity="bottom\|center\|left";g' $f

sed -i -E 's;android:layout_gravity="left\|bottom";android:layout_gravity="bottom\|center\|left";g' $f
sed -i -E 's;android:layout_gravity="bottom\|left";android:layout_gravity="bottom\|center\|left";g' $f

#---- end: Checking flags equivalencies ----

#---- start: Checking flags inversions ----
sed -i -E 's;"beginning\|middle";"middle\|beginning";g' $f
sed -i -E 's;"middle\|end";"end\|middle";g' $f
#---- end: Checking flags inversions ----



sed -i -E 's;"fill_parent";"match_parent";g' $f


# #FFF => #fff (just tolower)
sed -i -E 's/"#([0-F]{3,})"/"#\L\1"/g' $f

# #012345 => #01234567 (RGB to RGBA)
sed -i -E 's/"#([0-f]{6})"/"#\1ff"/g' $f

# #1234 => #11223344
sed -i -E 's/"#([0-f])([0-f])([0-f])([0-f])"/"#\1\1\2\2\3\3\4\4"/g' $f

mv -f $f "$1"

echo "Done processing $1"
