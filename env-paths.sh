THIS_DIR=$( cd -- "$( dirname -- "$(realpath "${BASH_SOURCE[0]:-$0}")" )" &> /dev/null && pwd )
SUPER_DIR="${THIS_DIR%/*}"
export SRC_DIR="$THIS_DIR/src"

# set the study directory variable (BID = Brisk Instruction on DataLad)
export study_dir=$SUPER_DIR/BID
# set the sibling directory variable
export sibling_dir=$SUPER_DIR/BID_lab_computer
