#!/usr/bin/env bash

mruby=../cobaya-runs/mruby/bin/mruby

mkdir -p crashes_uniq_not_loops

for crash in crashes_uniq/*; do
    echo -n '.'
    timeout 2s $mruby $crash > /dev/null 2> /dev/null

    if [[ $? != '124' ]]; then
	cp $crash crashes_uniq_not_loops/`basename $crash`
    fi

    #break
done
