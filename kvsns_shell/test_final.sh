#!/bin/bash

set -xe

input="liste.txt"
path="kvsns://dir2"

while IFS= read -r line
do
    filename=`echo "$line" | sed 's/[[:space:]]//g'`
    name=`basename $filename`
    echo "--> #$filename#  #$name#"
    filesize=$(stat -c%s "$filename")
    echo "Size of $filename = $filesize bytes."

    echo "test cp from $filename to $path/$name-bulk"
    unset NO_BULK
    ./kvsns_cp $filename $path/$name-bulk 2>/dev/null 1>/dev/null

    echo "test cp from $filename to $path/$name-nobulk"
    export NO_BULK=1
    ./kvsns_cp $filename $path/$name-nobulk 2>/dev/null 1>/dev/null

    echo "test cp from $path/$name-bulk to /tmp/$name-bulk-bulk"
    unset NO_BULK
    ./kvsns_cp $path/$name-bulk /tmp/$name-bulk-bulk 2>/dev/null 1>/dev/null

    echo "test cp from $path/$name-bulk to /tmp/$name-bulk-nobulk"
    export NO_BULK=1
    ./kvsns_cp $path/$name-bulk /tmp/$name-bulk-nobulk 2>/dev/null 1>/dev/null

    echo "test cp from $path/$name-nobulk to /tmp/$name-nobulk-bulk"
    unset NO_BULK
    ./kvsns_cp $path/$name-nobulk /tmp/$name-nobulk-bulk 2>/dev/null 1>/dev/null

    echo "test cp from $path/$name-nobulk to /tmp/$name-nobulk-nobulk"
    export NO_BULK=1
    ./kvsns_cp $path/$name-nobulk /tmp/$name-nobulk-nobulk 2>/dev/null 1>/dev/null

    echo "print md5sums and type of each file"
    sudo md5sum $filename /tmp/$name-bulk-bulk /tmp/$name-bulk-nobulk /tmp/$name-nobulk-bulk /tmp/$name-nobulk-nobulk
    sudo file $filename /tmp/$name-bulk-bulk /tmp/$name-bulk-nobulk /tmp/$name-nobulk-bulk /tmp/$name-nobulk-nobulk

    echo "rm each created file"
    sudo rm /tmp/$name-bulk-bulk /tmp/$name-bulk-nobulk /tmp/$name-nobulk-bulk /tmp/$name-nobulk-nobulk
done < "$input"
