#!/bin/bash

sort -u "$1" > t
mv -f t "$1"
