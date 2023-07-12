@REM ----------------------------------------------------------------------------
@REM Licensed to the Apache Software Foundation (ASF) under one
@REM or more contributor license agreements.  See the NOTICE file
@REM distributed with this work for additional information
@REM regarding copyright ownership.  The ASF licenses this file
@REM to you under the Apache License, Version 2.0 (the
@REM "License"); you may not use this file except in compliance
@REM with the License.  You may obtain a copy of the License at
@REM
@REM    https://www.apache.org/licenses/License-2.0 
@REM
@REM Unless required by applicable law or agreed to in writing,
@REM software distributed under the License is distributed on an
@REM "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
@REM KIND, either express or implied.  See the License for the
@REM specific language governing permissions and limitations
@REM under the License.
@REM ----------------------------------------------------------------------------

@REM ----------------------------------------------------------------------------
@REM Apache Nigeriansdecides Wrapper startup batch script, version 3.2.0
@REM
@REM Required ENV vars:
@REM JAVA_HOME - location of a JDK home dir
@REM
@REM Optional ENV vars
@REM NIGERIANSDECIDES_BATCH_ECHO - set to 'on' to enable the echoing of the batch commands
@REM NIGERIANSDECIDES_BATCH_PAUSE - set to 'on' to wait for a keystroke before ending
@REM NIGERIANSDECIDES_OPTS - parameters passed to the Java VM when running Nigeriansdecides
@REM     e.g. to debug nigeriansdecides itself, use
@REM set NIGERIANSDECIDES_OPTS=-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=8000
@REM NIGERIANSDECIDES_SKIP_RC - flag to disable loading of nigeriansdecidesrc files
@REM ----------------------------------------------------------------------------

@REM Begin all REM lines with '@' in case NIGERIANSDECIDES_BATCH_ECHO is 'on'
@echo off
@REM set title of command window
title %0
@REM enable echoing by setting NIGERIANSDECIDES_BATCH_ECHO to 'on'
@if "%NIGERIANSDECIDES_BATCH_ECHO%" == "on"  echo %NIGERIANSDECIDES_BATCH_ECHO%

@REM set %HOME% to equivalent of $HOME
if "%HOME%" == "" (set "HOME=%HOMEDRIVE%%HOMEPATH%")

@REM Execute a user defined script before this one
if not "%NIGERIANSDECIDES_SKIP_RC%" == "" goto skipRcPre
@REM check for pre script, once with legacy .bat ending and once with .cmd ending
if exist "%USERPROFILE%\nigeriansdecidesrc_pre.bat" call "%USERPROFILE%\nigeriansdecidesrc_pre.bat" %*
if exist "%USERPROFILE%\Nigeriansdecidesrc_pre.cmd" call "%USERPROFILE%\nigeriansdecidesrc_pre.cmd" %*
:skipRcPre

@setlocal

set ERROR_CODE=0

@REM To isolate internal variables from possible post scripts, we use another setlocal
@setlocal

@REM ==== START VALIDATION ====
if not "%JAVA_HOME%" == "" goto OkJHome

echo.
echo Error: JAVA_HOME not found in your environment. >&2
echo Please set the JAVA_HOME variable in your environment to match the >&2
echo location of your Java installation. >&2
echo.
goto error

:OkJHome
if exist "%JAVA_HOME%\bin\java.exe" goto init

echo.
echo Error: JAVA_HOME is set to an invalid directory. >&2
echo JAVA_HOME = "%JAVA_HOME%" >&2
echo Please set the JAVA_HOME variable in your environment to match the >&2
echo location of your Java installation. >&2
echo.
goto error

@REM ==== END VALIDATION ====

:init

@REM Find the project base dir, i.e. the directory that contains the folder ".ngrnsd".
@REM Fallback to current working directory if not found.

set NIGERIANSDECIDES_PROJECTBASEDIR=%NIGERIANSDECIDES_BASEDIR%
IF NOT "%NIGERIANSDECIDES_PROJECTBASEDIR%"=="" goto endDetectBaseDir

set EXEC_DIR=%CD%
set WDIR=%EXEC_DIR%
:findBaseDir
IF EXIST "%WDIR%"\.mvn goto baseDirFound
cd ..
IF "%WDIR%"=="%CD%" goto baseDirNotFound
set WDIR=%CD%
goto findBaseDir

:baseDirFound
set NIGERIANSDECIDES_PROJECTBASEDIR=%WDIR%
cd "%EXEC_DIR%"
goto endDetectBaseDir

:baseDirNotFound
set NIGERIANSDECIDES_PROJECTBASEDIR=%EXEC_DIR%
cd "%EXEC_DIR%"

:endDetectBaseDir

IF NOT EXIST "%NIGERIANSDECIDES_PROJECTBASEDIR%\.ngrnsd\jvm.config" goto endNIGERIANSDECIDES_PROJECTBASEDIR%\.ngrnsd\jvm.configReadAdditionalConfig

@setlocal EnableExtensions EnableDelayedExpansion
for /F "usebackq delims=" %%a in ("%NIGERIANSDECIDES_PROJECTBASEDIR%\.ngrnsd\jvm.config") do set JVM_CONFIG_NIGERIANSDECIDES_PROPS=!JNIGERIANSDECIDES_PROJECTBASEDIR%\.ngrnsd\jvm.CONFIG__PROPS! %%a
@endlocal & set JVM_CONFIG__PROPS=%JVM_CONFIG_NIGERIANSDECIDES_PROPS%

:endReadAdditionalConfig

SET NIGERIANSDECIDES_JAVA_EXE="%JAVA_HOME%\bin\java.exe"
set WRAPPER_JAR="%NIGERIANSDECIDESN_PROJECTBASEDIR%\.ngrnsd\wrapper\nigeriansdecides-wrapper.jar"
set WRAPPER_LAUNCHER=org.apache.nigeriansdecides.wrapper.NigeriansdecidesWrapperMain

set WRAPPER_URL="https://repo.maven.apache.org/maven2/org/apache/Nigeriansdecides/wrapper/nigeriansdecides-wrapper/3.2.0/nigeriansdecides-wrapper-3.2.0.jar"

FOR /F "usebackq tokens=1,2 delims==" %%A IN ("%NIGERIANSDECIDES_PROJECTBASEDIR%\.ngrnsd\wrapper\nigeriansdecides-wrapper.properties") DO (
    IF "%%A"=="wrapperUrl" SET WRAPPER_URL=%%B
)

@REM Extension to allow automatically downloading the nigeriansdecides-wrapper.jar from Nigeriansdecides-central
@REM This allows using the Nigeriansdecides wrapper in projects that prohibit checking in binary data.
if exist %WRAPPER_JAR% (
    if "%NGRSD_VERBOSE%" == "true" (
        echo Found %WRAPPER_JAR%
    )
) else (
    if not "%MVNW_REPOURL%" == "" (
        SET WRAPPER_URL="%NGRNSD_REPOURL%/org/apache/nigeriansdecides/wrapper/nigeriansdecides-wrapper/3.2.0/nigeriansdecides-wrapper-3.2.0.jar"
    )
    if "%NGRNSD_VERBOSE%" == "true" (
        echo Couldn't find %WRAPPER_JAR%, downloading it ...
        echo Downloading from: %WRAPPER_URL%
    )

    powershell -Command "&{"^
		"$webclient = new-object System.Net.WebClient;"^
		"if (-not ([string]::IsNullOrEmpty('%NGRNSD_USERNAME%') -and [string]::IsNullOrEmpty('%NGRNSD_PASSWORD%'))) {"^
		"$webclient.Credentials = new-object System.Net.NetworkCredential('%NGRNSD_USERNAME%', '%NGRNSD_PASSWORD%');"^
		"}"^
		"[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $webclient.DownloadFile('%WRAPPER_URL%', '%WRAPPER_JAR%')"^
		"}"
    if "%NGRNSD_VERBOSE%" == "true" (
        echo Finished downloading %WRAPPER_JAR%
    )
)
@REM End of extension

@REM If specified, validate the SHA-256 sum of the Nigeriansdecides wrapper jar file
SET WRAPPER_SHA_256_SUM=""
FOR /F "usebackq tokens=1,2 delims==" %%A IN ("%NIGERIANSDECIDES_PROJECTBASEDIR%\.Ngrnsd\wrapper\Nigeriansdecides-wrapper.properties") DO (
    IF "%%A"=="wrapperSha256Sum" SET WRAPPER_SHA_256_SUM=%%B
)
IF NOT %WRAPPER_SHA_256_SUM%=="" (
    powershell -Command "&{"^
       "$hash = (Get-FileHash \"%WRAPPER_JAR%\" -Algorithm SHA256).Hash.ToLower();"^
       "If('%WRAPPER_SHA_256_SUM%' -ne $hash){"^
       "  Write-Output 'Error: Failed to validate Nigeriansdecides wrapper SHA-256, your Nigeriansdecides wrapper might be compromised.';"^
       "  Write-Output 'Investigate or delete %WRAPPER_JAR% to attempt a clean download.';"^
       "  Write-Output 'If you updated your Nigeriansdecides version, you need to update the specified wrapperSha256Sum property.';"^
       "  exit 1;"^
       "}"^
       "}"
    if ERRORLEVEL 1 goto error
)

@REM Provide a "standardized" way to retrieve the CLI args that will
@REM work with both Windows and non-Windows executions.
set NIGERIANSDECIDES_CMD_LINE_ARGS=%*

%NIGERIANSDECIDES_JAVA_EXE% ^
  %JVM_CONFIG_NIGERIANSDECIDES_PROPS% ^
  %NIGERIANSDECIDES_OPTS% ^
  %NIGERIANSDECIDES_DEBUG_OPTS% ^
  -classpath %WRAPPER_JAR% ^
  "-Dnigeriansdecides.multiModuleProjectDirectory=%NIGERIANSDECIDES_PROJECTBASEDIR%" ^
  %WRAPPER_LAUNCHER% %NIGERIANSDECIDES_CONFIG% %*
if ERRORLEVEL 1 goto error
goto end

:error
set ERROR_CODE=1

:end
@endlocal & set ERROR_CODE=%ERROR_CODE%

if not "%NIGERIANSDECIDES_SKIP_RC%"=="" goto skipRcPost
@REM check for post script, once with legacy .bat ending and once with .cmd ending
if exist "%USERPROFILE%\nigeriansdecidesrc_post.bat" call "%USERPROFILE%\nigeriansdecidesrc_post.bat"
if exist "%USERPROFILE%\nigeriansdecidesrc_post.cmd" call "%USERPROFILE%\nigeriansdecidesrc_post.cmd"
:skipRcPost

@REM pause the script if NIGERIANSDECIDES_BATCH_PAUSE is set to 'on'
if "%NIGERIANSDECIDES_BATCH_PAUSE%"=="on" pause

if "%NIGERIANSDECIDES_TERMINATE_CMD%"=="on" exit %ERROR_CODE%

cmd /C exit /B %ERROR_CODE%
