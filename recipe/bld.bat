@echo off

IF NOT DEFINED PYTHON (set "PYTHON=python")
IF DEFINED PKG_VERSION (set SKLEARNEX_VERSION=%PKG_VERSION%)
IF NOT DEFINED DALROOT (set DALROOT=%PREFIX%)
IF NOT DEFINED MPIROOT IF "%NO_DIST%"=="" (set MPIROOT=%PREFIX%\Library)

rem reset preferred compilers to avoid usage of icx/icpx by default in all cases
set CC=cl.exe
set CXX=cl.exe

rem source compiler if DPCPPROOT is set outside of conda-build
IF DEFINED DPCPPROOT (
    echo "Sourcing DPCPPROOT"
    call "%DPCPPROOT%\env\vars.bat"
) ELSE IF EXIST "%BUILD_PREFIX%\Library\bin\icx.exe" (
    set "DPCPPROOT=%BUILD_PREFIX%\Library"
    set "LIB=%BUILD_PREFIX%\Library\lib;%BUILD_PREFIX%\compiler\lib;%LIB%"
    set "PATH=%BUILD_PREFIX%\Library\bin;%PATH%"
)

rem Inside conda-build %SRC_DIR% is set: stage files for pack.bat to claim
rem per output. Direct invocation (build-and-test-*.yml): install in-place.
IF NOT "%SRC_DIR%"=="" (
    set "SKLEARNEX_STAGE=%SRC_DIR%\__sklearnex_stage"
    if exist "%SRC_DIR%\__sklearnex_stage" rmdir /s /q "%SRC_DIR%\__sklearnex_stage"
    mkdir "%SRC_DIR%\__sklearnex_stage"
    %PYTHON% setup.py install --single-version-externally-managed --record "%SRC_DIR%\__sklearnex_stage\record.txt" --root "%SRC_DIR%\__sklearnex_stage"
) ELSE (
    %PYTHON% setup.py install --single-version-externally-managed --record record.txt
)
