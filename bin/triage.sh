#!/usr/bin/env bash

echo "Starting..."

mkdir -p crashes_uniq

function handle_crash {
    _stdin=`cat $1/stdin`
    _stderr=`cat $1/stderr`
    _stdout=`cat $1/stdout`

    echo $_stdout | grep SyntaxError > /dev/null

    if [[ $? -eq "0" ]]; then
	#echo "Syntax error crash. Discarding"
	return
    fi

    echo "$_stderr" | grep NameError > /dev/null

    if [[ $? -eq "0" ]]; then
	#echo "Semantic error crash. Discarding"
	return
    fi

    echo "$_stderr" | grep NoMethodError > /dev/null

    if [[ $? -eq "0" ]]; then
	#echo "Semantic error crash. Discarding"
	return
    fi

    echo "$_stderr" | grep TypeError > /dev/null

    if [[ $? -eq "0" ]]; then
	#echo "Semantic error crash. Discarding"
	return
    fi

    echo "$_stderr" | grep LocalJumpError > /dev/null

    if [[ $? -eq "0" ]]; then
	#echo "Semantic error crash. Discarding"
	return
    fi

    echo "Possible interesting case"
    hash=`echo "$_stdin" | md5sum | cut -f1 -d ' '`
    echo "$_stdin" > crashes_uniq/crash-$hash
}

for i in crashes/dirs/*; do

    for c in `cat $i`; do
	#echo ====================================================
	handle_crash crashes/$c
	
    done
    
    #break
done
    
