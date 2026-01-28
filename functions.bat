@echo off
setlocal ENABLEDELAYEDEXPANSION

:: EXAMPLE: Call function with return variable
rem usage: goto :dispatch(functionName, arg1, arg2, ..., returnVarName)
goto :dispatch(add, 7, 5, result)

echo Final result: %result%
goto :eof

:: ----------------- DISPATCH FUNCTION -----------------
:dispatch(%)
set "raw_label=%~0"

:: Get function name and arg string
for /f "tokens=1,2 delims=(" %%a in ("%raw_label%") do (
    set "func=%%a"
    set "arglist=%%b"
)
:: Trim closing ")"
set "arglist=%arglist:)=%"

:: Clear previous args
for /L %%i in (1,1,20) do set "arg%%i="

:: Parse arguments
set /a i=1
for %%A in (%arglist%) do (
    set "arg!i!=%%~A"
    set /a i+=1
)

:: Set up named arguments for convenience (arg1 = first argument, etc.)
set "arg1=%arg1%"
set "arg2=%arg2%"
set "arg3=%arg3%"
set "arg4=%arg4%"
set "arg5=%arg5%"

:: Store the return variable name (assume it's last argument)
set /a returnIndex=i-1
for %%R in (!returnIndex!) do set "retvalname=!arg%%R!"

:: Call the actual function (strip namespace if needed)
goto :func_%func%

:: ----------------- USER FUNCTION DEFINITIONS -----------------

:func_add
:: Adds arg1 and arg2, returns in %retvalname%
set /a result=%arg1% + %arg2%
set "%retvalname%=%result%"
goto :eof

:: ----------------- END -----------------
