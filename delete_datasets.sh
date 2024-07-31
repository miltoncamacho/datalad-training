#!/bin/bash
# Delete the parent study dataset

# Initialize paths
source env-paths.sh

if [ -d "$study_dir" ]; then
    datalad remove -d $study_dir --reckless kill
fi
if [ -d "$sibling_dir" ]; then
    datalad remove -d $sibling_dir --reckless kill
fi
