# Hands-on DataLad Training

## Requirements

To use this training,
DataLad (https://www.datalad.org/)
and Git-Annex (https://git-annex.branchable.com/)
must be installed.

If Git-Annex is already installed, the requirements file can be used to install DataLad via pip.

## Background

This training was developed for the 2024 RCS Summer School.

## Usage

Two primary scripts (`part1.sh` and `part2.sh`) exist for the training. `part1.sh` must be run before `part2.sh`.

These scripts create datasets in the directory above the one enclosing these two scripts (as specified by the path environment variables in `env-paths`).

To rerun the scripts, first remove the existing datasets by running `./delete.sh`.
