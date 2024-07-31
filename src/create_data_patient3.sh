#!/bin/bash
# create data files for patient 3

# parse inputs
FILE_DIR=$1

# patient 3 settings
MIN_RAND=0
MAX_RAND=100
NUM_RANDS=100
NUM_FILES=5

# create data
THIS_DIR=$( cd -- "$( dirname -- "$(realpath "${BASH_SOURCE[0]:-$0}")" )" &> /dev/null && pwd )
$THIS_DIR/create_data.sh \
    $MIN_RAND \
    $MAX_RAND \
    $NUM_RANDS \
    $NUM_FILES \
    $FILE_DIR
