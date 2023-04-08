@echo off & pushd %~dp0 & title Python环境变量配置
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
echo			设置Python环境变量
echo.--------------------------------------------------
echo   清理旧有环境变量
echo.

::如果有的话，先删除Python_HOME
echo 正在删除原有Python_HOME··· & ping -n 2 127.1 >nul
(wmic ENVIRONMENT where "name='Python_HOME'" delete >nul 2>nul & echo 原有 Python_HOME 删除成功。) || echo 未找到 Python_HOME。

::如果有的话，先删除PATH
echo 正在清理PATH··· & ping -n 2 127.1 >nul
::提取注册表PATH值
echo wscript.echo CreateObject ( "WScript.Shell" ).RegRead ( "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\Path" ) > %temp%\pathVaule~.vbs & for /f "delims=" %%a in ( 'cscript //nologo %temp%\pathVaule~.vbs' ) do set "pathValue=%%a"

::设置路径变量
set Python_path=%%Python_HOME%%
set PythonScripts_path=%%Python_HOME%%\Scripts
set unPython=
::忽略与Python无关的变量
:split
for /f "tokens=1,* delims=;" %%i in ("%pathValue%") do (
	if not "%%i"=="%Python_path%" (if not "%%i"=="%PythonScripts_path%" (set temp=%%i) else (set temp=)) else (set temp=)
	set pathValue=%%j
)
if "%temp%"=="" goto unadd
set unPython=%unPython%%temp%;
:unadd
if not "%pathValue%"=="" goto split
::将PATH中的JAVA变量删除
set pathValue=%unPython%
(wmic ENVIRONMENT where "name='path' and username='<system>'" set VariableValue="%pathValue%" >nul 2>nul & echo PATH 清理完成。) || echo PATH 清理失败。

echo.
echo					旧有变量清理完成
echo.
pause

echo.

::添加PATH
echo 正在添加PATH··· & ping -n 2 127.1 >nul
(wmic ENVIRONMENT where "name='path' and username='<system>'" set VariableValue="%pathValue%;%%Python_HOME%%;%%Python_HOME%%\Scripts;" >nul 2>nul & echo PATH 添加成功。) || echo PATH 添加失败。

::创建Python_HOME
echo 正在创建Python_HOME··· & ping -n 2 127.1 >nul
(wmic ENVIRONMENT create name="Python_HOME",username="<system>",VariableValue="%cd%" >nul 2>nul & echo Python_HOME 添加成功。) || echo JAVA_HOME 添加失败。

echo.
pause

echo.

::安装Pip
echo 正在安装Pip··· & ping -n 2 127.1 >nul
powershell curl -o "get-pip.py" "https://bootstrap.pypa.io/get-pip.py"
python get-pip.py

::修改Pth文件
echo 正在修改Pth文件··· & ping -n 2 127.1 >nul
dir "python*._pth" /b > "pthNameTemp.txt"
for /f "usebackq delims=" %%a in ( "pthNameTemp.txt" ) do (set pthName=%%a)
del pthNameTemp.txt
if exist "%pthName%" (
	for /f "usebackq delims=" %%a in ( "%pthName%" ) do ( if not "%%a"=="import site" (echo %%a>>pthFileTemp.txt) )
	)
del %pthName%
ren pthFileTemp.txt %pthName%
echo import site>>%pthName%
echo 修改Pth文件完成。

echo.
echo					环境变量配置完成
echo.--------------------------------------------------
pause


