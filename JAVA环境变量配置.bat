@echo off & pushd %~dp0 & title JAVA������������
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
echo			����java��������
echo.--------------------------------------------------
echo   ������л�������
echo.

::����еĻ�����ɾ��JAVA_HOME
echo ����ɾ��ԭ��JAVA_HOME������ & ping -n 2 127.1 >nul
(wmic ENVIRONMENT where "name='JAVA_HOME'" delete >nul 2>nul & echo ԭ�� JAVA_HOME ɾ���ɹ���) || echo δ�ҵ� JAVA_HOME��

::����еĻ�����ɾ��ClASSPATH 
echo ����ɾ��ԭ��ClASSPATH������ & ping -n 2 127.1 >nul
(wmic ENVIRONMENT where "name='CLASSPATH'" delete >nul 2>nul & echo ԭ�� ClASSPATH ɾ���ɹ���) || echo δ�ҵ� ClASSPATH��

::����еĻ�����ɾ��PATH
echo ��������PATH������ & ping -n 2 127.1 >nul
::��ȡע���PATHֵ
echo wscript.echo CreateObject ( "WScript.Shell" ).RegRead ( "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\Path" ) > %temp%\pathVaule~.vbs & for /f "delims=" %%a in ( 'cscript //nologo %temp%\pathVaule~.vbs' ) do set "pathValue=%%a"

::����·������
set javaBin_path=%%JAVA_HOME%%\bin
set javaJreBin_path=%%JAVA_HOME%%\jre\bin
set unJava=
::������JAVA�޹صı���
:split
for /f "tokens=1,* delims=;" %%i in ("%pathValue%") do (
	if not "%%i"=="%javaBin_path%" (if not "%%i"=="%javaJreBin_path%" (set temp=%%i) else (set temp=)) else (set temp=)
	set pathValue=%%j
)
if "%temp%"=="" goto unadd
set unJava=%unJava%%temp%;
:unadd
if not "%pathValue%"=="" goto split
::��PATH�е�JAVA����ɾ��
set pathValue=%unJava%
(wmic ENVIRONMENT where "name='path' and username='<system>'" set VariableValue="%pathValue%" >nul 2>nul & echo PATH ������ɡ�) || echo PATH ����ʧ�ܡ�

echo.
echo					���б����������
echo.

pause
echo.

::����JRE�ļ���
if not exist "%~dp0jre" (echo ��������Jre������ & bin\jlink.exe --module-path jmods --add-modules java.desktop --output jre & ping -n 2 127.1 >nul & echo Jre��װ�ɹ���)

::���PATH
echo �������PATH������ & ping -n 2 127.1 >nul
(wmic ENVIRONMENT where "name='path' and username='<system>'" set VariableValue="%pathValue%;%%JAVA_HOME%%\bin;%%JAVA_HOME%%\jre\bin;" >nul 2>nul & echo PATH ��ӳɹ���) || echo PATH ���ʧ�ܡ�

:: ����CLASSPATH
::echo ���ڴ���CLASSPATH������ & ping -n 2 127.1 >nul
::(wmic ENVIRONMENT create name="CLASSPATH",username="<system>",VariableValue=".;%%JAVA_HOME%%\lib\dt.jar;%%JAVA_HOME%%\lib\tools.jar;" >nul 2>nul & echo CLASSPATH ��ӳɹ���) || echo CLASSPATH ���ʧ�ܡ�

::����JAVA_HOME
echo ���ڴ���JAVA_HOME������ & ping -n 2 127.1 >nul
(wmic ENVIRONMENT create name="JAVA_HOME",username="<system>",VariableValue="%cd%" >nul 2>nul & echo JAVA_HOME ��ӳɹ���) || echo JAVA_HOME ���ʧ�ܡ�
echo.
echo					���������������
echo.--------------------------------------------------
pause

