How to run
----------


> find -name \*.xml -print0 |xargs -0 -P 8 -n 1 bash ../clean.sh
> diff -ur res.src res.dst
