#!/bin/bash
# create data files

MIN_RAND=$1
MAX_RAND=$2
NUM_RANDS=$3
NUM_FILES=$4
FILE_DIR=$5

function random_numbers () {
    # create a set of random integer between a and b
    a=$1
    b=$2
    num_rands=$3
    range=$(($b-$a+1))
    for column in $(seq 1 1 $num_rands); do
        number=$RANDOM
        let "number %= $range"
        echo $(($number + $a))
    done
}

for index in $(seq -f "%02g" 1 $NUM_FILES); do
    file_name=sample_$index.txt
    file_path=$FILE_DIR/$file_name
    random_numbers $MIN_RAND $MAX_RAND $NUM_RANDS > $file_path
done
