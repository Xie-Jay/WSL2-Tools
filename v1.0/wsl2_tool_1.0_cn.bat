::  Reference to Microsoft-Activation-Scripts [ https://github.com/massgravel/Microsoft-Activation-Scripts ].

@setlocal DisableDelayedExpansion
@echo off

::========================================================================================================================================

cls
title WSL2 ���� 1.0
set _elev=
if /i "%~1"=="-el" set _elev=1
for /f "tokens=6 delims=[]. " %%G in ('ver') do set winbuild=%%G
set "_null=1>nul 2>nul"
set "_psc=powershell"
set "EchoRed=%_psc% write-host -back Black -fore Red"
set "EchoGreen=%_psc% write-host -back Black -fore Green"
set "ErrLine=echo: & %EchoRed% ==== ERROR ==== &echo:"

::========================================================================================================================================

for %%i in (powershell.exe) do if "%%~$path:i"=="" (
echo: &echo ==== ERROR ==== &echo:
echo ϵͳ��û�а�װPowershell.
echo ������ֹ...
goto ErrExit
)

::========================================================================================================================================

if %winbuild% LSS 18362 (
%ErrLine%
echo ��⵽��֧�ֵĲ���ϵͳ�汾.
echo ��Ŀ��֧�� Windows 10: �汾 1903 ����߰汾, �����ڲ��汾 18362 ����߰汾.
goto ErrExit
)

::========================================================================================================================================

::  Elevate script as admin and pass arguments and preventing loop
::  Thanks to @hearywarlot [ https://forums.mydigitallife.net/threads/.74332/ ] for the VBS method.
::  Thanks to @abbodi1406 for the powershell method and solving special characters issue in file path name.

set "batf_=%~f0"
set "batp_=%batf_:'=''%"

%_null% reg query HKU\S-1-5-19 && (
goto :_Passed
) || (
if defined _elev goto :_E_Admin
)

set "_vbsf=%temp%\admin.vbs"
set _PSarg="""%~f0""" -el

setlocal EnableDelayedExpansion
(
echo Set strArg=WScript.Arguments.Named
echo Set strRdlproc = CreateObject^("WScript.Shell"^).Exec^("rundll32 kernel32,Sleep"^)
echo With GetObject^("winmgmts:\\.\root\CIMV2:Win32_Process.Handle='" ^& strRdlproc.ProcessId ^& "'"^)
echo With GetObject^("winmgmts:\\.\root\CIMV2:Win32_Process.Handle='" ^& .ParentProcessId ^& "'"^)
echo If InStr ^(.CommandLine, WScript.ScriptName^) ^<^> 0 Then
echo strLine = Mid^(.CommandLine, InStr^(.CommandLine , "/File:"^) + Len^(strArg^("File"^)^) + 8^)
echo End If
echo End With
echo .Terminate
echo End With
echo CreateObject^("Shell.Application"^).ShellExecute "cmd.exe", "/c " ^& chr^(34^) ^& chr^(34^) ^& strArg^("File"^) ^& chr^(34^) ^& strLine ^& chr^(34^), "", "runas", 1
)>"!_vbsf!"

(%_null% cscript //NoLogo "!_vbsf!" /File:"!batf_!" -el) && (
del /f /q "!_vbsf!"
exit /b
) || (
del /f /q "!_vbsf!"
%_null% %_psc% "start cmd.exe -arg '/c \"!_PSarg:'=''!\"' -verb runas" && (
exit /b
) || (
goto :_E_Admin
)
)
exit /b

:_E_Admin
%ErrLine%
echo �˽ű���Ҫ����ԱȨ��.
echo Ϊ��, �Ҽ������˽ű���ѡ��'�Թ���Ա�������'.
goto ErrExit

:_Passed

::========================================================================================================================================

setlocal EnableDelayedExpansion

:MainMenu

cls
title WSL2 ���� 1.0
mode con cols=98 lines=30

echo:
echo:
echo                   _______________________________________________________________
echo                  ^|                                                               ^| 
echo                  ^|                                                               ^|
echo                  ^|      [1] �����ļ�                                             ^|
echo                  ^|      ___________________________________________________      ^|
echo                  ^|                                                               ^|
echo                  ^|      [2] �˿�ת��                                             ^|
echo                  ^|                                                               ^|
echo                  ^|      [3] �������                                             ^|
echo                  ^|                                                               ^|
echo                  ^|      [4] IP ����                                              ^|
echo                  ^|      ___________________________________________________      ^|
echo                  ^|                                                               ^|
echo                  ^|      [5] �˳�                                                 ^|
echo                  ^|                                                               ^|
echo                  ^|_______________________________________________________________^|
echo:          
choice /C:12345 /N /M ">                   �ڼ������������ѡ�� [1,2,3,4,5] : "

if errorlevel  5 goto:Exit
if errorlevel  4 goto:IPSetting 
if errorlevel  3 goto:NetProxy
if errorlevel  2 goto:PortProxy
if errorlevel  1 goto:Readme

::========================================================================================================================================

:ReadMe

start https://github.com/Xie-Jay/WSL2-Tools/blob/main/README-zh_CN.md  &goto MainMenu

::========================================================================================================================================

:PortProxy

cls
title �˿�ת��
mode con cols=98 lines=30

echo:
echo:
echo                      _________________________________________________________   
echo                     ^|                                                         ^|
echo                     ^|                                                         ^|
echo                     ^|     [1] ��Ӵ���˿�                                    ^|
echo                     ^|                                                         ^|
echo                     ^|     [2] ���ô���˿�                                    ^|
echo                     ^|                                                         ^|
echo                     ^|     [3] չʾ����˿�                                    ^|
echo                     ^|                                                         ^|
echo                     ^|     _______________________________________________     ^|
echo                     ^|                                                         ^|
echo                     ^|     [4] �������˵�                                      ^|
echo                     ^|                                                         ^|
echo                     ^|_________________________________________________________^|
echo:                                                                               
choice /C:1234 /N /M ">                     �ڼ������������ѡ�� [1,2,3,4] : "

if errorlevel 4 goto:MainMenu
if errorlevel 3 goto:ShowPortProxy
if errorlevel 2 goto:ResetPortProxy
if errorlevel 1 goto:AddPortProxy

:AddPortProxy
for /f %%j in ('bash.exe -c "hostname -I | awk '{print $1}'"') do (
    set wslip=%%j
)
echo:
set input=
set /p input=">                     ����˿�(�ÿո����):"
set s=%input%
:loop
for /f "tokens=1*" %%a in ("%s%") do (
    netsh interface portproxy add v4tov4 listenport=%%a listenaddress=0.0.0.0 connectport=%%a connectaddress=%wslip% >nul
    set s=%%b
)
if defined s goto :loop
echo:
netsh interface portproxy show v4tov4
echo:
echo                       �������������...
pause >nul
goto PortProxy

:ResetPortProxy
netsh interface portproxy reset 
echo:
echo                       �ɹ�
echo:
echo                       �������������...
pause >nul
goto PortProxy

:ShowPortProxy
echo:
netsh interface portproxy show v4tov4
echo:
echo                       �������������...
pause >nul
goto PortProxy

::========================================================================================================================================

:NetProxy

cls
title �������
mode con cols=98 lines=30

echo:
echo:
echo                      _________________________________________________________   
echo                     ^|                                                         ^|
echo                     ^|                                                         ^|
echo                     ^|     [1] ���ô�������                                    ^|
echo                     ^|                                                         ^|
echo                     ^|     [2] �����������                                    ^|
echo                     ^|                                                         ^|
echo                     ^|     [3] �������ǿ�������                                ^|
echo                     ^|                                                         ^|
echo                     ^|     _______________________________________________     ^|
echo                     ^|                                                         ^|
echo                     ^|     [4] �������˵�                                      ^|
echo                     ^|                                                         ^|
echo                     ^|_________________________________________________________^|
echo:                                                                               
choice /C:1234 /N /M ">                     �ڼ������������ѡ�� [1,2,3,4] : "

if errorlevel 4 goto:MainMenu
if errorlevel 3 goto:SetAlwaysProxy
if errorlevel 2 goto:ClearProxyCommand
if errorlevel 1 goto:SetProxyCommand

:SetProxyCommand
echo:
set input=
set /p input=">                     ���� Http(s) �˿�:"
set http_port=%input%
echo:
set input=
set /p input=">                     ���� Socks �˿�:"
set socks_port=%input%
bash.exe -c "sed -i '/export hostip/d;/alias set_proxy/d;/alias clear_proxy/d' ~/.bashrc"
bash.exe -c "sed -i $'$a export hostip=\$\(cat /etc/resolv.conf |grep \"nameserver\" |cut -f 2 -d \" \"\)' ~/.bashrc"
bash.exe -c "sed -i $'$a alias set_proxy=\'export https_proxy=\"http://${hostip}:%http_port%\";export http_proxy=\"http://${hostip}:%http_port%\";export all_proxy=\"socks5://${hostip}:%socks_port%\";\'' ~/.bashrc"
bash.exe -c "sed -i $'$a alias clear_proxy=\'unset https_proxy;unset http_proxy;unset all_proxy;\'' ~/.bashrc"
bash.exe -c "source ~/.bashrc"
echo:
echo                       �ɹ�
echo                       �򿪴�������: set_proxy
echo                       �رմ�������: clear_proxy
echo:
echo                       �������������...
pause >nul
goto NetProxy

:ClearProxyCommand
bash.exe -c "sed -i '/export hostip/d;/set_proxy/d;/clear_proxy/d' ~/.bashrc"
bash.exe -c "source ~/.bashrc"
echo:
echo                       �ɹ�
echo:
echo                       �������������...
pause >nul
goto NetProxy

:SetAlwaysProxy
echo:
choice /C:YN /N /M ">                     ���ǿ������� [Y,N] : "
if errorlevel 2 bash.exe -c "sed -i '/^set_proxy$/d' ~/.bashrc"
if errorlevel 1 bash.exe -c "sed -i $'$a set_proxy' ~/.bashrc"
bash.exe -c "source ~/.bashrc"
echo:
echo                       �ɹ�
echo:
echo                       �������������...
pause >nul
goto NetProxy

::========================================================================================================================================

:IPSetting

cls
title IP ����
mode con cols=98 lines=30

echo:
echo:
echo                      _________________________________________________________   
echo                     ^|                                                         ^|
echo                     ^|                                                         ^|
echo                     ^|     [1] ��� Linux IP                                   ^|
echo                     ^|                                                         ^|
echo                     ^|     [2] ��� Windows IP                                 ^|
echo                     ^|                                                         ^|
echo                     ^|     [3] ɾ�� Linux IP                                   ^|
echo                     ^|                                                         ^|
echo                     ^|     [4] ɾ�� Windows IP                                 ^|
echo                     ^|                                                         ^|
echo                     ^|     [5] չʾ IP                                         ^|
echo                     ^|                                                         ^|
echo                     ^|     _______________________________________________     ^|
echo                     ^|                                                         ^|
echo                     ^|     [6] �������˵�                                      ^|
echo                     ^|                                                         ^|
echo                     ^|_________________________________________________________^|
echo:                                                                               
choice /C:123456 /N /M ">                     �ڼ������������ѡ�� [1,2,3,4,5,6] : "

if errorlevel 6 goto:MainMenu
if errorlevel 5 goto:ShowIP
if errorlevel 4 goto:DelWindowsIP
if errorlevel 3 goto:DelLinuxIP
if errorlevel 2 goto:AddWindowsIP
if errorlevel 1 goto:AddLinuxIP

:AddLinuxIP
echo:
set input=
set /p input=">                     ���� IP:"
for /f "tokens=1,2,3 delims=." %%a in ("%input%") do (
    set num1=%%a
	set num2=%%b
	set num3=%%c
)
wsl -u root ip addr add %input%/24 broadcast %num1%.%num2%.%num3%.255 dev eth0 label eth0:1
echo:
echo                       �ɹ�
echo:
echo                       �������������...
pause >nul
goto IPSetting

:AddWindowsIP
echo:
set input=
set /p input=">                     ���� IP:"
netsh interface ip add address "vEthernet (WSL)" %input% 255.255.255.0
echo:
echo                       �ɹ�
echo:
echo                       �������������...
pause >nul
goto IPSetting

:DelLinuxIP
echo:
set input=
set /p input=">                     ���� IP:"
for /f "tokens=1,2,3 delims=." %%a in ("%input%") do (
    set num1=%%a
	set num2=%%b
	set num3=%%c
)
wsl -u root ip addr del %input%/24 broadcast %num1%.%num2%.%num3%.255 dev eth0 label eth0:1
echo:
echo                       �ɹ�
echo:
echo                       �������������...
pause >nul
goto IPSetting

:DelWindowsIP
echo:
set input=
set /p input=">                     ���� IP:"
netsh interface ip delete address "vEthernet (WSL)" addr=%input% gateway=all
echo:
echo                       �ɹ�
echo:
echo                       �������������...
pause >nul
goto IPSetting

:ShowIP
echo:
echo Linux   IP:
bash.exe -c "ip addr show eth0 | grep \"inet\\b\" | awk '{print $2}' | cut -d/ -f1"
echo:
echo Windows IP:
for /f "tokens=2 delims=:" %%b in ('netsh interface ip show config "vEthernet (WSL)"^|find /i "ip"') do (
    for /f "tokens=*" %%i in ("%%b") do echo %%i
)
echo:
echo                       �������������...
pause >nul
goto IPSetting

::========================================================================================================================================

:Exit

exit /b

::========================================================================================================================================

:ErrExit

echo:
echo ����������˳�...
pause >nul
exit /b

::========================================================================================================================================

::End::