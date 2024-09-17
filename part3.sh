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
# if using docker:
#   datalad containers-add multiply-numbers --url dhub://miltoncamacho/multiply-numbers
# if using mac with silicon chip
#   we need to add the flag <--platform linux/amd64) inside the docker.py script from the datalad_containers library in my case: /Users/milton/Downloads/heudiconv-new-test/multiecho-proc/env/lib/python3.11/site-packages/datalad_container/adapter/docker.py
# def cli_run(namespace):
#     image_id = load(namespace.path, namespace.repo_tag, namespace.config)
#     prefix = ["docker", "run",
#               # Add the platform flag here
#               "--platform", "linux/amd64",  <<<<<<<<<<<<----------------------------# this is the line that matters
#               # FIXME: The -v/-w settings are convenient for testing, but they
#               # should be configurable.
#               "-v", "{}:/tmp".format(os.getcwd()),
#               "-w", "/tmp",
#               "--rm",
#               "--interactive"]
#     if not on_windows:
#         # Make it possible for the output files to be added to the
#         # dataset without the user needing to manually adjust the
#         # permissions.
#         prefix.extend(["-u", "{}:{}".format(os.getuid(), os.getgid())])

#     if sys.stdin.isatty():
#         prefix.append("--tty")
#     prefix.append(image_id)
#     cmd = prefix + namespace.cmd
#     lgr.debug("Running %r", cmd)
#     sp.check_call(cmd)

# check the containers
datalad containers-list

# run datalad containers-run 
cd $study_dir
# if using singularity
datalad containers-run \
    --message "Multiplication analysis of patient 1" \
    --container-name multiply-numbers \
    --input "patient_1/inputs/sample_01.txt" \
    --output "patient_1/outputs_multiplication/sample_01_multiplied.txt" \
    "python /app/multiply_numbers.py {inputs} {outputs}"
# if using docker
datalad containers-run \
    --message "Multiplication analysis of patient 1" \
    --container-name multiply-numbers \
    --input "patient_1/inputs/sample_01.txt" \
    --output "patient_1/outputs_multiplication/sample_01_multiplied.txt" \
    "{inputs} {outputs}"

# modify the values of sample01 for patient 1
cp $study_dir/patient_1/outputs_multiplication/sample_01_multiplied.txt $study_dir/patient_1/inputs/sample_01.txt

# save recursive to update the changes on the inputs subdataset
datalad save -r -m "fix: made changes to the sample 01 of inputs for patient 1"

# rerun datalad comand
git log --oneline
RUN_COMMIT=$(git rev-parse @~1)
datalad rerun $RUN_COMMIT