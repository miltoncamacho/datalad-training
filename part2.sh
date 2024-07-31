#/bin/bash
# Part 2 of Datalad training material
# modify the script's behavior to make it more robust and fail-safe.
set -eu -o pipefail

# Initialize paths
source env-paths.sh


##### DataLad run! ##### #>45
cd $study_dir
datalad run \
    --message "Statistical analysis of patient 1" \
    --input "patient_1/inputs/sample_*" \
    --output "patient_1/outputs_01_statistics/summary.csv" \
    "python3 code/stats.py -i {inputs} -o {outputs}"
datalad run \
    --message "Statistical analysis of patient 2" \
    --input "patient_2/inputs/sample_*" \
    --output "patient_2/outputs_01_statistics/summary.csv" \
    "python3 code/stats.py -i {inputs} -o {outputs}"


##### Rerun commands ##### #>46-47-48
cd $study_dir

# modify an input file in patient 1 #>46-47-48
sed -i'.bak' 's/4/3/g' patient_1/inputs/sample_01.txt  # replace 4 with 3
rm patient_1/inputs/sample_01.txt.bak
datalad save --recursive --message "Modify patient 1 input"

# get run commit #>46-47-48
git log --oneline
RUN_COMMIT=$(git rev-parse @~2)
echo "Run commit: $RUN_COMMIT"
# rerun analysis #>46-47-48
datalad rerun $RUN_COMMIT


##### External dataset ##### #>49
cd $study_dir

# install an external dataset #>50
datalad install \
    --dataset . \
    --source https://github.com/OpenNeuroDatasets/ds004767.git patient_web

# view web dataset with annexed information #>50
cd patient_web
datalad status --annex all

# Get a single file #>50
datalad get sub-00xCNDR01/anat/sub-00xCNDR01_T2w.nii.gz

# view web dataset #>50
datalad status --annex all

# Get a data directory #>50
datalad get sub-00xCNDR02
# Use -r/--recursive option to recursively install subdatasets
# Be careful when recursively downloading full datasets
# You may be downloading more data than you expect!

# view web dataset #>50
datalad status --annex all

# "drop" a file (i.e. delete the file contents to clear up space) #>50
datalad drop sub-00xCNDR01/anat/sub-00xCNDR01_T2w.nii.gz

# view updated web dataset #>50
datalad status --annex all

# Lookup remote data storage locations #>50
git annex whereis sub-00xCNDR01/anat/sub-00xCNDR01_T2w.nii.gz
# Note that this command does not contact remotes to verify if they still have the file contents.
# It only reports on the last information that was received from remotes.


##### Add file from the internet ##### #>51
# Note that there is no data provenance of the downloaded files
cd $study_dir
mkdir other
datalad download-url \
    http://gutenberg.ca/ebooks/andersen-ugly/andersen-ugly-00-t.txt \
    --dataset . \
    --message "Add The Ugly Duckling" \
    --path other/ugly_duckling.txt
datalad download-url \
    https://upload.wikimedia.org/wikipedia/commons/e/ed/USS_Constitution_fires_a_17-gun_salute.jpg \
    --dataset . \
    --message "Add image of USS Constitution" \
    --path other/uss_constitution.jpg


##### Create sibling ##### #>52

# create sibling (with description on the sibling) #>53
datalad install \
    --description "Lab computer" \
    --recursive \
    --source $study_dir \
    $sibling_dir

# create patient 3 #>53
cd $sibling_dir
mkdir patient_3
cd patient_3
datalad create --dataset .. --cfg-proc text2git inputs
mkdir outputs_01_statistics
sh $SRC_DIR/create_data_patient3.sh inputs
cd ..
datalad save --recursive --message "Add raw patient 3 data and code"

# run patient 3 analysis #>53
datalad run \
    --message "Statistical analysis of patient 3" \
    --input "patient_3/inputs/sample_*" \
    --output "patient_3/outputs_01_statistics/summary.csv" \
    "python3 code/stats.py -i {inputs} -o {outputs}"


##### View siblings ##### #>53

# view siblings in sibling directory #>53
cd $sibling_dir
datalad siblings

# view siblings in original directory #>53
cd $study_dir
datalad siblings
# Note that there is only the sibling labelled "here"


##### Add sibling to original dataset ##### #>53
cd $study_dir
datalad siblings add \
    --dataset . \
    --name lab_computer \
    --url $sibling_dir

# view siblings in original directory #>53
datalad siblings


##### Get data from a sibling ##### #>54
cd $study_dir

# fetch updates from sibling
datalad update --sibling lab_computer --how fetch
# note: with "--how fetch" the dataset is not updated with the changes
# the dataset is simply made aware of the changes

# view the modified files between the two siblings
datalad diff --to remotes/lab_computer/main
# view the changes between the two siblings
git --no-pager diff remotes/lab_computer/main

# merge changes from sibling into dataset
datalad update --sibling lab_computer --how merge
# note: "--how merge" will updated the dataset
# and will force you to handle conflicts

# fetch contents of patient 3
cd patient_3/inputs
datalad get .

# End of part 2
