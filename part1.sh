#/bin/bash
# Part 1 of Datalad training material
# modify the script's behavior to make it more robust and fail-safe.
set -eu -o pipefail

# Initialize paths
source env-paths.sh


##### Create datasets ##### #>25
# create the study dataset #>26
datalad create --cfg-proc text2git $study_dir
cd $study_dir

# create subdirectories #>26
mkdir code
mkdir patient_1 patient_2

# create patient 1 with subdirectories and subdataset #>26
cd $study_dir/patient_1
datalad create --dataset .. --cfg-proc text2git inputs
mkdir outputs_01_statistics

# create patient 2 with subdirectories and subdataset #>26
cd $study_dir/patient_2
datalad create --dataset .. --cfg-proc text2git inputs
mkdir outputs_01_statistics

# add dataset description #>26
cp $SRC_DIR/dataset_description.json $study_dir

# show subdatasets #>26
cd $study_dir
datalad subdatasets


##### populate data in datasets ##### #>27
sh $SRC_DIR/create_data_patient1.sh $study_dir/patient_1/inputs
sh $SRC_DIR/create_data_patient2.sh $study_dir/patient_2/inputs


##### Datalad save/status and provenance history (commit log) ##### #>27
cd $study_dir

# show superdataset status #>27
datalad status
datalad save --message "Add description file"
datalad status

# commit in subdatasets #>28
cd $study_dir/patient_1/inputs
# show patient 1 inputs dataset status #>28
datalad status
# save patient 1 data #>28 
datalad save --message "Add raw data"
# The message of the most recent commit may be amended with 'git commit --amend'
# This is useful when the message was not added initially, or needs to be changed

# show updated patient 1 inputs dataset status #>28
datalad status
# show history of actions #>28
git log
# show modification in last commit
# git log -1 --stat
# other log options:
# git log -p  # see changes
# git log  # see everything
# git log --oneline  # concise listing
# git log --graph --decorate --oneline --all --abbrev-commit # provide a graph like report

# save patient 2 data #>28
cd $study_dir/patient_2/inputs
datalad save --message "Add raw data"

# show superdataset status #>28
cd $study_dir
datalad status

# save subdataset changes to superdataset #>28
datalad save --message "Update subdatasets"

# add code #>28
cp $SRC_DIR/stats.py $study_dir/code
cp $SRC_DIR/aggregate.py $study_dir/code

# recursively save datasets in a single command #>28
cd $study_dir
datalad save --message "Add code"


##### git revert #####
# git revert -e <commit>

##### Add a binary file and save recursively ##### #>29
cd $study_dir
#The command generates and displays the first 1000 bytes of random data from /dev/urandom
head -c 1000 /dev/urandom > patient_1/inputs/file.bin 
datalad save --recursive --message "Add binary file"
ls -ltrh patient_1/inputs/file.bin


##### file unlocking ##### #>29
# Unlocking an annex'ed file permits its modification
# if no changes are to be done, lock the file
# otherwise, save the changes via datalad save
cd $study_dir/patient_1/inputs
datalad unlock file.bin
git annex lock file.bin

##### Remove dataset #####
#datalad remove -d $study_dir --reckless kill

# End of part 1
