@echo off
REM Map a network drive to a shared USB disk on the livebox.
REM 
REM It alleviates the effect of a very well-known and long-lasting bug which
REM remains unfixed by Orange despite many customers complaints : when you
REM plug your USB disk on the rear of tour home livebox, the name of the 
REM volume is no more used. Instead a random name is showed, like usb_54321.
REM This scripts will try to map a network drive using the same letter. Hence
REM you (or your scripts/backup etc.) will be able to use it in more friendful
REM way.
REM 
REM Author: S. Scudeller (sscudeller@gmail.com)
REM Date: 14/10/2018

SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION

SET DRIVENAME=Z

echo Looking up for USB disk on LIVEBOX
REM Fetch shared folders from LIVEBOX
net view livebox > %tmp%\livebox_0.txt
if NOT ERRORLEVEL 0 (
	echo ERROR : failed to fetch shared folders from livebox
	goto :eof
)

REM Searches for the string usb_* in the net view output
findstr usb_* %tmp%\livebox_0.txt > %tmp%\livebox_1.txt
if NOT ERRORLEVEL 0 (
	echo ERROR : failed to find the pattern for the USB disk
	goto :eof
)

REM Extracts the USB disk name from the found line
set USBNAME=
for /f %%i in (%tmp%\livebox_1.txt) do set USBNAME=%%i
if "%USBNAME%"=="" (
	echo ERROR : no USB drive found
	goto :eof
)

echo Mapping %USBNAME% to %DRIVENAME%

REM Unmap the drive, and remap it to the remote USB disk
if exist %DRIVENAME%:\ net use %DRIVENAME%: /delete > NUL
net use %DRIVENAME%: \\livebox\%USBNAME% > NUL
if NOT ERRORLEVEL 0 (
	echo ERROR : failed to map the drive
	goto :eof
)

REM Clean-up
del /f %tmp%\livebox_0.txt
del /f %tmp%\livebox_1.txt