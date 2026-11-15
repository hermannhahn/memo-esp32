@echo off
setlocal enabledelayedexpansion

set UPDATE_VERSION_TYPE=patch
set RESET_UPDATES_FLAG=

:loop_args
if "%~1"=="" goto end_loop_args
if /i "%~1"=="major"          ( set UPDATE_VERSION_TYPE=major )
if /i "%~1"=="--major"        ( set UPDATE_VERSION_TYPE=major )
if /i "%~1"=="minor"          ( set UPDATE_VERSION_TYPE=minor )
if /i "%~1"=="--minor"        ( set UPDATE_VERSION_TYPE=minor )
if /i "%~1"=="patch"          ( set UPDATE_VERSION_TYPE=patch )
if /i "%~1"=="--patch"        ( set UPDATE_VERSION_TYPE=patch )
if /i "%~1"=="-v"             ( set "UPDATE_VERSION_TYPE=%~2" & shift )
if /i "%~1"=="--version"      ( set "UPDATE_VERSION_TYPE=%~2" & shift )
if /i "%~1"=="--reset-updates" ( set RESET_UPDATES_FLAG=-resetUpdates )
shift
goto loop_args
:end_loop_args

if not "!UPDATE_VERSION_TYPE!"=="major" (
    if not "!UPDATE_VERSION_TYPE!"=="minor" (
        if not "!UPDATE_VERSION_TYPE!"=="patch" (
            set UPDATE_VERSION_TYPE=patch
        )
    )
)

powershell -ExecutionPolicy Bypass -File "%~dp0publish.ps1" -v "!UPDATE_VERSION_TYPE!" !RESET_UPDATES_FLAG!
