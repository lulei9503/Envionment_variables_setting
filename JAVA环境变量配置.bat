@echo off & pushd %~dp0 & title JAVA环境变量配置
mode con cols=50 lines=35
color 0f

::::::::::::::::::::权限申请 Start::::::::::::::::::::
cls
echo.
echo          *===========================*
echo          #    管理员权限申请中．．． #
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
echo       *     正在调用 UAC 进行权限提升     *
echo       $***********************************$
echo.
echo  ☆ 请选择 [是] 同意批处理调用管理员权限。
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
:::::::::::::::::::::权限申请 End::::::::::::::::::::
echo.--------------------------------------------------
echo			设置java环境变量
echo.--------------------------------------------------
echo   清理旧有环境变量
echo.

::如果有的话，先删除JAVA_HOME
echo 正在删除原有JAVA_HOME··· & ping -n 2 127.1 >nul
(wmic ENVIRONMENT where "name='JAVA_HOME'" delete >nul 2>nul & echo 原有 JAVA_HOME 删除成功。) || echo 未找到 JAVA_HOME。

::如果有的话，先删除ClASSPATH 
echo 正在删除原有ClASSPATH··· & ping -n 2 127.1 >nul
(wmic ENVIRONMENT where "name='CLASSPATH'" delete >nul 2>nul & echo 原有 ClASSPATH 删除成功。) || echo 未找到 ClASSPATH。

::如果有的话，先删除PATH
echo 正在清理PATH··· & ping -n 2 127.1 >nul
::提取注册表PATH值
echo wscript.echo CreateObject ( "WScript.Shell" ).RegRead ( "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\Path" ) > %temp%\pathVaule~.vbs & for /f "delims=" %%a in ( 'cscript //nologo %temp%\pathVaule~.vbs' ) do set "pathValue=%%a"

::设置路径变量
set javaBin_path=%%JAVA_HOME%%\bin
set javaJreBin_path=%%JAVA_HOME%%\jre\bin
set unJava=
::忽略与JAVA无关的变量
:split
for /f "tokens=1,* delims=;" %%i in ("%pathValue%") do (
	if not "%%i"=="%javaBin_path%" (if not "%%i"=="%javaJreBin_path%" (set temp=%%i) else (set temp=)) else (set temp=)
	set pathValue=%%j
)
if "%temp%"=="" goto unadd
set unJava=%unJava%%temp%;
:unadd
if not "%pathValue%"=="" goto split
::将PATH中的JAVA变量删除
set pathValue=%unJava%
(wmic ENVIRONMENT where "name='path' and username='<system>'" set VariableValue="%pathValue%" >nul 2>nul & echo PATH 清理完成。) || echo PATH 清理失败。

echo.
echo					旧有变量清理完成
echo.

pause
echo.

::生成JRE文件夹
if not exist "%~dp0jre" (echo 正在配置Jre··· & bin\jlink.exe --module-path jmods --add-modules java.desktop --output jre & ping -n 2 127.1 >nul & echo Jre安装成功。)

::添加PATH
echo 正在添加PATH··· & ping -n 2 127.1 >nul
(wmic ENVIRONMENT where "name='path' and username='<system>'" set VariableValue="%pathValue%;%%JAVA_HOME%%\bin;%%JAVA_HOME%%\jre\bin;" >nul 2>nul & echo PATH 添加成功。) || echo PATH 添加失败。

:: 创建CLASSPATH
::echo 正在创建CLASSPATH··· & ping -n 2 127.1 >nul
::(wmic ENVIRONMENT create name="CLASSPATH",username="<system>",VariableValue=".;%%JAVA_HOME%%\lib\dt.jar;%%JAVA_HOME%%\lib\tools.jar;" >nul 2>nul & echo CLASSPATH 添加成功。) || echo CLASSPATH 添加失败。

::创建JAVA_HOME
echo 正在创建JAVA_HOME··· & ping -n 2 127.1 >nul
(wmic ENVIRONMENT create name="JAVA_HOME",username="<system>",VariableValue="%cd%" >nul 2>nul & echo JAVA_HOME 添加成功。) || echo JAVA_HOME 添加失败。
echo.
echo					环境变量配置完成
echo.--------------------------------------------------
pause

