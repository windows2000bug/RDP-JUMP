@echo off

REM Script for allowing SSH Tunneling for RDP access w/ SSO.
REM INSTRUCTIONS:
REM Requires plink.exe from https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html
REM Place both rdp-jump.bat and plink.exe in the same folder and then run it.

REM IP or Hostname for JumpBox
set jumpBox=jumpbox.example.com

REM SSH Finger Print for Jump Box
set key="ed25519 255 00:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88"

set myUser=%USERDOMAIN%\%username%
set dPort=3389

REM Random Port Generator
set /a minPort=(%RANDOM%*30000/32768)+20000
REM set /a minPort=27015

echo ######################################################################
echo Warning: Do not close black windows, this can kill your RDP session!!!
echo ######################################################################
if [%1]==[] (
	set /p destHost="Please enter Host to RDP to: "
	set hPath=history\
) else (
	set destHost=%1
	set pPath=..\
	
)

set /a maxPort=%minPort%+1000

setlocal enableextensions enabledelayedexpansion



for /L %%t in (%minPort%,1,%maxPort%) do (
	set /a rPort=%%t
	netstat /o /a /n | find /i "listening" | find ":!rPort!" >nul 2>nul  && (
		REM echo !rPort! is Taken
	) || (
		REM echo !rPort! is Free
		call :openPort
	)
)

:openPort

echo Using Local Port %rPort% to connect to %destHost%
start "sshtunnel-%destHost%-%rPort%" /min %pPath%plink.exe -hostkey %key% -no-antispoof -N  -X -l %myUser% -L %rPort%:%destHost%:%dPort% %jumpBox%

REM Loop through 10 times and wait up to 10 seconds to see if local tunnel is established.
for /L %%a in (1,1,10) do (
	netstat /o /a /n | find /i "listening" | find ":%rPort%" >nul 2>nul && (
  		REM echo %rPort% is open to %destHost%
	) || (
  		echo Wating for Tunnel to establish on %rPort%.
		timeout /t 3 /nobreak > NUL
		if %%a==10 (
			echo Unable to connect to %destHost%, press any key to exit
			pause
			exit
		)
	)
)

echo Connecting...

start "rpdtunnel-%rPort%" mstsc /v:localhost:%rPort%

REM Start 5 second sleep to avoid closing RDP window before it is named
timeout /t 5 /nobreak > NUL

REM setlocal enableextensions enabledelayedexpansion
set loaded=0
set a=0

REM Waits for RDP session to end, when the user logs out, then it will close out the putty session as well
for /L %%n in () do (
	REM tasklist /V /FI "WindowTitle eq localhost:%rPort% - Remote Desktop Connection"
	tasklist /fi "WindowTitle eq localhost:%rPort% - Remote Desktop Connection" | find "mstsc.exe" > nul
	if errorlevel 1 (
		REM echo Error #1
		tasklist /fi "WindowTitle eq Remote Desktop Connection" | find "mstsc.exe" > nul
		if errorlevel 1 (
			REM echo Error #2
			call :counter
			if "!a!" GTR "3" (
				REM echo First Kill
				call :killTunnel
			)
			
		)
		if "!loaded!" EQU "1" (
			(
			echo @echo off
			echo ..\rdp-jump.bat %destHost% 
			)> %hPath%%destHost%.bat
			echo Second Kill
			call :killTunnel
		)
	) else (
		REM echo RDP Session still running
		set loaded=1
	)
	REM echo Looping
	timeout /t 5 /nobreak > NUL
	
)
exit /b



:killTunnel
	echo Killing sshtunnel-%destHost%-%rPort% and exiting...
	taskkill /FI "WindowTitle eq sshtunnel-%destHost%-%rPort%" /T /F
	timeout /t 5 /nobreak > NUL
	exit


:counter
	set /a a=a+1
	REM echo Loop %a%
exit /b
