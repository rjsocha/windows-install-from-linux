set INSTALL=smb.install.socha.it
set WINVER=2025

mkdir \wyga
expand wyga.cab /F:* %SYSTEMDRIVE%\wyga\ >nul
set PATH=%SYSTEMDRIVE%\wyga\bin;%PATH%

reg add HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules /f /v "01-VNC" /t REG_SZ /d "v2.33|Action=Allow|Active=TRUE|Dir=In|Protocol=6|LPort=10090|Name=VNC|" >nul
reg add HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules /f /v "02-ICMP" /t REG_SZ /d "v2.33|Action=Allow|Active=TRUE|Dir=In|Protocol=1|ICMP4=8:*|Name=ICMPv4Ping|" >nul

drvload %SYSTEMDRIVE%\wyga\drv\virtio\netkvm\%WINVER%\netkvm.inf
drvload %SYSTEMDRIVE%\wyga\drv\virtio\sriov\%WINVER%\vioprot.inf
drvload %SYSTEMDRIVE%\wyga\drv\virtio\vioscsi\%WINVER%\vioscsi.inf
drvload %SYSTEMDRIVE%\wyga\drv\virtio\viostor\%WINVER%\viostor.inf

wpeinit
Wpeutil InitializeNetwork
wpeutil WaitForNetwork

start %SYSTEMDRIVE%\wyga\vnc\winvnc.exe -run


wpeutil UpdateBootInfo
:: delims is tab and space
for /f "tokens=2* delims=	 " %%A in ('reg query HKLM\System\CurrentControlSet\Control /v PEFirmwareType') DO SET Firmware=%%B
if %Firmware%==0x1 SET FW=bios
if %Firmware%==0x2 SET FW=uefi

ping -n 5 %INSTALL%

@ipconfig

:LOOP
net use * /delete /yes
net use z: \\%INSTALL%\%WINVER% install /USER:install /TRANSPORT:TCP
IF EXIST Z:\SETUP.EXE GOTO SETUPAUTO
ping -n 3 127.0.0.1 >NUL
GOTO LOOP

:MENU
@ECHO.
@ECHO FIRMWARE: %FW%
@ECHO.
@ipconfig
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
@ipconfig
Z:
CD \
START /WAIT SETUP.EXE /unattend:z:\unattend_%FW%.xml
GOTO MENU

:END
EXIT
