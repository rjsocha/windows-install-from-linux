set INSTALL=<IP-OR-HOST>
set WINVER=2022

wpeinit
Wpeutil InitializeNetwork
wpeutil WaitForNetwork

wpeutil UpdateBootInfo
for /f "tokens=2* delims=	 " %%A in ('reg query HKLM\System\CurrentControlSet\Control /v PEFirmwareType') DO SET Firmware=%%B
if %Firmware%==0x1 SET FW=bios
if %Firmware%==0x2 SET FW=uefi

ipconfig
ping -n 5 %INSTALL%

:LOOP
net use * /delete /yes
net use z: \\%INSTALL%\win%WINVER% install /USER:install /TRANSPORT:TCP
IF EXIST Z:\SETUP.EXE GOTO SETUPAUTO
ping -n 2 127.0.0.1 >NUL
GOTO LOOP

:MENU
@ECHO.
@ECHO FIRMWARE: %FW%
@ECHO.
@ECHO 1. CMD
@ECHO 2. SETUP.EXE
@ECHO 3. SETUP.EXE /unattend:z:\unattend_%FW%.xml
@ECHO 4. EXIT
@ECHO.
@SET /P M=Type 1, 2, 3, or 4 then press ENTER:
@IF %M%==1 GOTO CMD
@IF %M%==2 GOTO SETUP
@IF %M%==3 GOTO SETUPAUTO
@IF %M%==4 GOTO END
@GOTO MENU

:CMD
START /WAIT CMD.EXE
GOTO MENU

:SETUP
Z:
CD \
START /WAIT SETUP.EXE
GOTO MENU

:SETUPAUTO
Z:
CD \
START /WAIT SETUP.EXE /unattend:z:\unattend_%FW%.xml
GOTO MENU

:END
EXIT