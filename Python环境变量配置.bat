@echo off & pushd %~dp0 & title Python������������
mode con cols=50 lines=35
color 0f

::::::::::::::::::::Ȩ������ Start::::::::::::::::::::
cls
echo.
echo          *===========================*
echo          #    ����ԱȨ�������У����� #
echo          *===========================*

:init
setlocal disabledelayedexpansion
set cmdinvoke=1
set winsysfolder=system32
set "batchpath=%~0"
for %%k in ( %0 ) do set batchname=%%~nk
set "vbsgetprivileges=%temp%\oegetpriv_%batchname%.vbs"
setlocal enabledelayedexpansion

:checkprivileges
net file 1>nul 2>nul
if '%errorlevel%' == '0' ( goto gotprivileges ) else ( goto getprivileges )

:getprivileges
if '%1'=='elev' ( echo elev & shift /1 & goto gotprivileges)

echo.
echo       $***********************************$
echo       *     ���ڵ��� UAC ����Ȩ������     *
echo       $***********************************$
echo.
echo  �� ��ѡ�� [��] ͬ����������ù���ԱȨ�ޡ�
echo.

echo set uac = createobject^( "shell.application"^ ) > "%vbsgetprivileges%"
echo args = "elev " >> "%vbsgetprivileges%"
echo for each strarg in wscript.arguments >> "%vbsgetprivileges%"
echo args = args ^& strarg ^& " "  >> "%vbsgetprivileges%"
echo next >> "%vbsgetprivileges%"

if '%cmdinvoke%'=='1' goto invokecmd 

echo uac.shellexecute "!batchpath!", args, "", "runas", 1 >> "%vbsgetprivileges%"
goto execelevation

:invokecmd
echo args = "/c """ + "!batchpath!" + """ " + args >> "%vbsgetprivileges%"
echo uac.shellexecute "%systemroot%\%winsysfolder%\cmd.exe", args, "", "runas", 1 >> "%vbsgetprivileges%"

:execelevation
"%systemroot%\%winsysfolder%\wscript.exe" "%vbsgetprivileges%" %*
exit /b

:gotprivileges
setlocal & cd /d %~dp0
if '%1'=='elev' ( del "%vbsgetprivileges%" 1>nul 2>nul & shift /1)
cls
:::::::::::::::::::::Ȩ������ End::::::::::::::::::::
echo.--------------------------------------------------
echo			����Python��������
echo.--------------------------------------------------
echo   ������л�������
echo.

::����еĻ�����ɾ��Python_HOME
echo ����ɾ��ԭ��Python_HOME������ & ping -n 2 127.1 >nul
(wmic ENVIRONMENT where "name='Python_HOME'" delete >nul 2>nul & echo ԭ�� Python_HOME ɾ���ɹ���) || echo δ�ҵ� Python_HOME��

::����еĻ�����ɾ��PATH
echo ��������PATH������ & ping -n 2 127.1 >nul
::��ȡע���PATHֵ
echo wscript.echo CreateObject ( "WScript.Shell" ).RegRead ( "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\Path" ) > %temp%\pathVaule~.vbs & for /f "delims=" %%a in ( 'cscript //nologo %temp%\pathVaule~.vbs' ) do set "pathValue=%%a"

::����·������
set Python_path=%%Python_HOME%%
set PythonScripts_path=%%Python_HOME%%\Scripts
set unPython=
::������Python�޹صı���
:split
for /f "tokens=1,* delims=;" %%i in ("%pathValue%") do (
	if not "%%i"=="%Python_path%" (if not "%%i"=="%PythonScripts_path%" (set temp=%%i) else (set temp=)) else (set temp=)
	set pathValue=%%j
)
if "%temp%"=="" goto unadd
set unPython=%unPython%%temp%;
:unadd
if not "%pathValue%"=="" goto split
::��PATH�е�JAVA����ɾ��
set pathValue=%unPython%
(wmic ENVIRONMENT where "name='path' and username='<system>'" set VariableValue="%pathValue%" >nul 2>nul & echo PATH ������ɡ�) || echo PATH ����ʧ�ܡ�

echo.
echo					���б����������
echo.
pause

echo.

::���PATH
echo �������PATH������ & ping -n 2 127.1 >nul
(wmic ENVIRONMENT where "name='path' and username='<system>'" set VariableValue="%pathValue%;%%Python_HOME%%;%%Python_HOME%%\Scripts;" >nul 2>nul & echo PATH ��ӳɹ���) || echo PATH ���ʧ�ܡ�

::����Python_HOME
echo ���ڴ���Python_HOME������ & ping -n 2 127.1 >nul
(wmic ENVIRONMENT create name="Python_HOME",username="<system>",VariableValue="%cd%" >nul 2>nul & echo Python_HOME ��ӳɹ���) || echo JAVA_HOME ���ʧ�ܡ�

echo.
pause

echo.

::��װPip
echo ���ڰ�װPip������ & ping -n 2 127.1 >nul
powershell curl -o "get-pip.py" "https://bootstrap.pypa.io/get-pip.py"
python get-pip.py

::�޸�Pth�ļ�
echo �����޸�Pth�ļ������� & ping -n 2 127.1 >nul
dir "python*._pth" /b > "pthNameTemp.txt"
for /f "usebackq delims=" %%a in ( "pthNameTemp.txt" ) do (set pthName=%%a)
del pthNameTemp.txt
if exist "%pthName%" (
	for /f "usebackq delims=" %%a in ( "%pthName%" ) do ( if not "%%a"=="import site" (echo %%a>>pthFileTemp.txt) )
	)
del %pthName%
ren pthFileTemp.txt %pthName%
echo import site>>%pthName%
echo �޸�Pth�ļ���ɡ�

echo.
echo					���������������
echo.--------------------------------------------------
pause


