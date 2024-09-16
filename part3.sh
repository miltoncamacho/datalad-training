#/bin/bash
# Part 3 of Datalad training material
# modify the script's behavior to make it more robust and fail-safe.
set -eu -o pipefail

# open up a ssh session in arc or in compute canada unless you have singularity installed in your machine

### REQUIREMENTS ###
# install miniconda and datalad
#
# wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
#
# bash Miniconda3-latest-Linux-x86_64.sh
#
# acknowledge license, keep everything at default
#
# create a conda environment for your datalad
# conda create --name datalad_training python=3.9
# conda activate datalad_training
#
# conda install -c conda-forge datalad
# conda update -c conda-forge datalad
#
# Install the datalad-container library
# pip install datalad-container
#
######################

# Initialize paths
source env-paths.sh

# Datalad clone repository:

##### Create datasets #####
datalad create --cfg-proc text2git $study_dir
cd $study_dir

# create subdirectories
mkdir patient_1

# create patient 1 with subdirectories and subdataset 
cd $study_dir/patient_1
datalad create --dataset .. --cfg-proc text2git inputs
mkdir outputs_multiplication

##### populate data in datasets #####
cd $study_dir
sh $SRC_DIR/create_data_patient1.sh $study_dir/patient_1/inputs
datalad save -r -m "add inputs to patient 1"

# download the image
datalad containers-add multiply-numbers --call-fmt 'singularity exec -B {{pwd}} {img} {cmd}' --url docker://miltoncamacho/multiply-numbers
# the --call-fmt allows you to format how the container will be run, in this case, we care about binding the pwd into the container
# datalad containers-add multiply-numbers --call-fmt 'docker run -v --rm {{pwd}}:/data {img} {cmd}' --url dhub://miltoncamacho/multiply-numbers --update
# for macs with silicon chips
# datalad containers-add multiply-numbers --call-fmt 'docker run -v --rm --platform linux/amd64 {{pwd}}:/data {img} {cmd}' --url dhub://miltoncamacho/multiply-numbers --update

# check the containers
datalad containers-list

# run datalad containers-run 
cd $study_dir
datalad containers-run \
    --message "Multiplication analysis of patient 1" \
    --container-name multiply-numbers \
    --input "patient_1/inputs/sample_01.txt" \
    --output "patient_1/outputs_multiplication/sample_01_multiplied.txt" \
    "python /app/multiply_numbers.py {inputs} {outputs}"

# modify the values of sample01 for patient 1
cp $study_dir/patient_1/outputs_multiplication/sample_01_multiplied.txt $study_dir/patient_1/inputs/sample_01.txt

# save recursive to update the changes on the inputs subdataset
datalad save -r -m "fix: made changes to the sample 01 of inputs for patient 1"

# rerun datalad comand
git log --oneline
RUN_COMMIT=$(git rev-parse @~1)
datalad rerun $RUN_COMMIT