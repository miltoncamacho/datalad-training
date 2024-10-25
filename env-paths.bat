@echo off
REM Get the current script directory
set THIS_DIR=%~dp0
set THIS_DIR=%THIS_DIR:~0,-1%

REM Get the parent directory of the current directory
for %%I in ("%THIS_DIR%") do set SUPER_DIR=%%~dpI
set SUPER_DIR=%SUPER_DIR:~0,-1%

REM Set the SRC_DIR variable (persistent)
setx SRC_DIR "%THIS_DIR%\src"

REM Set the study_dir variable (persistent)
setx study_dir "%SUPER_DIR%\BID"

REM Set the sibling_dir variable (persistent)
setx sibling_dir "%SUPER_DIR%\BID_lab_computer"

echo THIS_DIR is %THIS_DIR%
echo SUPER_DIR is %SUPER_DIR%
echo SRC_DIR is %SRC_DIR%
echo study_dir is %study_dir%
echo sibling_dir is %sibling_dir%