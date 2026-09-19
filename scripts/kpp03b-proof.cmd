@echo off
setlocal
set "NODE=C:\Program Files\nodejs\node.exe"
set "LOGDIR=%TEMP%\duta-kpp03b-proof"
if not exist "%LOGDIR%" mkdir "%LOGDIR%"
if "%1"=="build" (
  "%NODE%" node_modules\next\dist\bin\next build > "%LOGDIR%\next-build.log" 2>&1
  set "RESULT=%ERRORLEVEL%"
  echo LOG=%LOGDIR%\next-build.log
  echo EXIT=%RESULT%
  exit /b %RESULT%
)
if "%1"=="test" (
  "%NODE%" node_modules\vitest\vitest.mjs run --reporter=verbose > "%LOGDIR%\vitest.log" 2>&1
  set "RESULT=%ERRORLEVEL%"
  echo LOG=%LOGDIR%\vitest.log
  echo EXIT=%RESULT%
  exit /b %RESULT%
)
echo Usage: kpp03b-proof.cmd build^|test
exit /b 64
