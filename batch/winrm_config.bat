@echo off
setlocal EnableDelayedExpansion
:start
cls
::--------------------------------------------------------
::-- ȫ�ֱ���
::--------------------------------------------------------
set item=
set Protocal_Choice=
set Protocal=
set HostName=
set Port=
set UserName=
set Password=
set Choice=
set Hosts=
set GroupName=
set GroupSid=

echo.�鿴������WinRM......
echo.------------------------------------------
echo.0-�鿴WinRM�汾��Ϣ    6-����WinRM-Http
echo.1-�鿴WinRM������Ϣ    7-����Https����֤��
echo.2-�鿴WinRM����״̬    8-�鿴Https����֤��
echo.3-����WinRM����״̬    9-����WinRM-Https
echo.4-�鿴Ĭ�Ϲ���         a-����non-administrator
echo.5-����WinRM            x-�˳�
echo.------------------------------------------
set /p item=��ѡ��:
echo.------------------------------------------

::0-�鿴WinRM�汾��Ϣ
if /i "%item%"=="0" (call winrm id)

::1-�鿴WinRM������Ϣ
if /i "%item%"=="1" (call winrm get winrm/config)

::2-�鿴WinRM����״̬
if /i "%item%"=="2" (call winrm e winrm/config/listener)

::3-����WinRM����״̬
if /i "%item%"=="3" (
  :input_protocal
  set /p Protocal_Choice="����������Э��(1-http,2-https):"
  if not "!Protocal_Choice!"=="1" (if not "!Protocal_Choice!"=="2" goto:input_protocal)
  set /p HostName="��������������:"
  set /p Port="���������Ӷ˿�:"
  set /p UserName="�������û���:"
  set /p Password="���������:"
  echo.------------------------------------------
  if /i "!Protocal_Choice!"=="1" (set Protocal=http) else (if /i "!Protocal_Choice!"=="2" (set Protocal=https))
  echo.��������Ϊ��winrm identify -r:!Protocal!://!HostName!:!Port! -auth:basic -u:!UserName! -p:!Password! -encoding:utf-8
  set /p Choice="ȷ��������Y/y,������˳�:"
  echo.------------------------------------------
  if /i "!Choice!"=="y" (call winrm identify -r:!Protocal!://!HostName!:!Port! -auth:basic -u:!UserName! -p:!Password! -encoding:utf-8)
)

::4-�鿴Ĭ�Ϲ���
if /i "%item%"=="4" (
  net share
)

::5-����WinRM
if /i "%item%"=="5" (
  call winrm delete winrm/config/Listener?Address=*+Transport=HTTP
  call winrm delete winrm/config/Listener?Address=*+Transport=HTTPS
)

::6-����WinRM-Http
if /i "%item%"=="6" (
  :input_port_6
  set /p Port="���������Ӷ˿�:"
  if "!Port!"=="" (goto:input_port_6)
  :input_hosts_6
  set /p Hosts="�������������ӵ�Զ������:��* or host1,host2... or 192.168.1.*��"
  if "!Hosts!"=="" (goto:input_hosts_6)
  call winrm quickconfig -quiet
  call winrm set winrm/config @{MaxTimeoutms ="600000000"}
  call winrm set winrm/config/service/auth @{Basic="true"}
  call winrm set winrm/config/client/auth @{Basic="true"}
  call winrm set winrm/config/service @{AllowUnencrypted="true"}
  call winrm set winrm/config/client @{AllowUnencrypted="true"}
  call winrm set winrm/config/winrs @{MaxMemoryPerShellMB="1024"}
  call winrm set winrm/config/client/DefaultPorts @{HTTP="!Port!"}
  call winrm set winrm/config/client @{TrustedHosts="!Hosts!"}
  call winrm delete winrm/config/Listener?Address=*+Transport=HTTP
  call winrm create winrm/config/listener?Address=*+Transport=HTTP @{Port="!Port!"}
)

::7-����Https����֤��
if /i "%item%"=="7" (
  :input_hostname_7
  set /p HostName="������IP��ַ:"
  if "!HostName!"=="" (goto:input_hostname_7)
  call selfssl.exe /T /N:cn=!HostName! /V:36500 /Q
  call powershell "Get-childItem cert:\LocalMachine\Root\ | Select-String -pattern !HostName!"
)

::8-�鿴Https����֤��
if /i "%item%"=="8" (
  set /p HostName="������IP��ַ:"
  call powershell "Get-childItem cert:\LocalMachine\Root\ | Select-String -pattern !HostName!"
)

::9-����WinRM-Https
if /i "%item%"=="9" (
  :input_hostname_9
  set /p HostName="������IP��ַ:"
  if "!HostName!"=="" (goto:input_hostname_9)
  :input_port_9
  set /p Port="���������Ӷ˿�:"
  if "!Port!"=="" (goto:input_port_9)
  :input_hosts_9
  set /p Hosts="�������������ӵ�Զ������:��* or host1,host2... or 192.168.1.*��"
  if "!Hosts!"=="" (goto:input_hosts_9)
  :input_Thumbprint_9
  set /p Thumbprint="������֤��Thumbprint:"
  if "!Thumbprint!"=="" (goto:input_Thumbprint_9)
  call winrm quickconfig -quiet
  call winrm set winrm/config @{MaxTimeoutms ="600000000"}
  call winrm set winrm/config/service/auth @{Basic="true"}
  call winrm set winrm/config/client/auth @{Basic="true"}
  call winrm set winrm/config/winrs @{MaxMemoryPerShellMB="1024"}
  call winrm set winrm/config/client/DefaultPorts @{HTTPS="!Port!"}
  call winrm set winrm/config/client @{TrustedHosts="!Hosts!"}
  call winrm delete winrm/config/Listener?Address=*+Transport=HTTPS
  call winrm create winrm/config/listener?Address=*+Transport=HTTPS @{Port="!Port!"; Hostname="!HostName!"; CertificateThumbprint="!Thumbprint!"}
  
)

::a-����non-administrator
if /i "%item%"=="a" (
  echo.ǰ��:�ֹ������û��˺�
  echo.������ʵ��:1.���û����뵽administrators�飬2.����Ĭ�Ϲ���ע������ԣ�3.����powershellִ�в���
  echo.ע��:1.ȷ��Ĭ�Ϲ����ѿ���C$��D$...��
  echo.     2.����ǽ����TCP445/139�˿ں�WinRM�˿�����
  echo.--------------------------------------------------------------
  :input_username_a
  set /p UserName="�������û��˺�����:"
  if "!UserName!"=="" (goto:input_username_a)
  call net localgroup administrators !UserName! /add
  call REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1 /f
  call powershell -command set-ExecutionPolicy RemoteSigned
)

if /i "%item%"=="x" (goto:eof) else (echo.&pause&goto:start)

::b-����non-administrators
if /i "%item%"=="b" (
  echo.ǰ��:�ֹ�����WinRM�û��飬����ͨ�û����뵽������
  echo.1.��ʾWinRM�û����sid��2.�������û�����WinRM
  echo.ע��:1.ֻ��ִ�нű�����޷������ļ�
  echo.     2.����ǽ����WinRM�˿�����
  echo.-------------------------------------------------
  :input_groupname_b
  set /p GroupName="������WinRM�û�������:"
  if "!GroupName!"=="" (goto:input_groupname_b)
  call wmic group get name, sid|findstr "!GroupName!"
  :input_groupsid_b
  set /p GroupSid="������WinRM�û���Sid:"
  if "!GroupSid!"=="" (goto:input_groupsid_b)
  call winrm set winrm/config/service @{RootSDDL="O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;!GroupSid!)S:P(AU;FA;GA;;;WD)(AU;SA;GWGX;;;WD)"}
)



