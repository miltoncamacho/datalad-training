@echo off
REM Remove the environment variables set with setx
setx SRC_DIR ""
setx study_dir ""
setx sibling_dir ""

REM The following variables will not be persistent, but you can unset them from the current session using:
set THIS_DIR=
set SUPER_DIR=

echo Environment variables removed.