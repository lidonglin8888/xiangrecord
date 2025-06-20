@echo off
REM 环境切换脚本 - Windows版本
REM 用于快速切换Spring Boot应用的运行环境

setlocal enabledelayedexpansion

REM 设置颜色
set "RED=[31m"
set "GREEN=[32m"
set "YELLOW=[33m"
set "BLUE=[34m"
set "NC=[0m"

REM 显示帮助信息
if "%1"=="" goto :show_help
if "%1"=="-h" goto :show_help
if "%1"=="--help" goto :show_help

REM 获取环境参数
set "ENV=%1"

REM 验证环境参数
if "%ENV%"=="dev" goto :valid_env
if "%ENV%"=="prod" goto :valid_env
if "%ENV%"=="test" goto :valid_env

echo %RED%错误: 无效的环境参数 '%ENV%'%NC%
echo 支持的环境: dev, prod, test
goto :show_help

:valid_env
echo %BLUE%正在切换到 %ENV% 环境...%NC%
echo.

REM 设置项目根目录
set "PROJECT_ROOT=%~dp0.."
cd /d "%PROJECT_ROOT%"

REM 检查Maven是否可用
mvn --version >nul 2>&1
if errorlevel 1 (
    echo %RED%错误: Maven未安装或不在PATH中%NC%
    echo 请先安装Maven并配置环境变量
    exit /b 1
)

REM 根据环境设置不同的启动参数
if "%ENV%"=="dev" (
    echo %GREEN%开发环境配置:%NC%
    echo - 使用H2内存数据库
    echo - 启用热重载
    echo - 启用H2控制台
    echo - 详细日志输出
    echo - 启用Swagger文档
    echo.
    set "SPRING_PROFILES=dev"
    set "JVM_OPTS=-Xms256m -Xmx512m -Dspring.profiles.active=dev"
    set "MAVEN_OPTS=-Dspring-boot.run.profiles=dev"
) else if "%ENV%"=="prod" (
    echo %YELLOW%生产环境配置:%NC%
    echo - 使用MySQL数据库
    echo - 优化JVM参数
    echo - 禁用开发工具
    echo - 生产级日志配置
    echo - 禁用Swagger文档
    echo.
    set "SPRING_PROFILES=prod"
    set "JVM_OPTS=-Xms512m -Xmx1024m -XX:+UseG1GC -Dspring.profiles.active=prod"
    set "MAVEN_OPTS=-Dspring-boot.run.profiles=prod"
) else if "%ENV%"=="test" (
    echo %BLUE%测试环境配置:%NC%
    echo - 使用H2内存数据库
    echo - 随机端口
    echo - 测试数据初始化
    echo - 简化日志输出
    echo.
    set "SPRING_PROFILES=test"
    set "JVM_OPTS=-Xms128m -Xmx256m -Dspring.profiles.active=test"
    set "MAVEN_OPTS=-Dspring-boot.run.profiles=test"
)

REM 设置环境变量
set SPRING_PROFILES_ACTIVE=%SPRING_PROFILES%

REM 显示当前配置
echo %GREEN%当前配置:%NC%
echo SPRING_PROFILES_ACTIVE=%SPRING_PROFILES_ACTIVE%
echo JVM_OPTS=%JVM_OPTS%
echo.

REM 询问是否启动应用
set /p "START_APP=是否立即启动应用? (y/n): "
if /i "%START_APP%"=="y" goto :start_app
if /i "%START_APP%"=="yes" goto :start_app

echo %GREEN%环境已切换到 %ENV%，可以手动启动应用%NC%
echo 启动命令: mvn spring-boot:run
goto :end

:start_app
echo %GREEN%正在启动应用...%NC%
echo.

REM 启动Spring Boot应用
mvn spring-boot:run %MAVEN_OPTS%

if errorlevel 1 (
    echo %RED%应用启动失败%NC%
    exit /b 1
) else (
    echo %GREEN%应用启动成功%NC%
)

goto :end

:show_help
echo.
echo %GREEN%环境切换脚本%NC%
echo.
echo %YELLOW%用法:%NC%
echo   switch-env.bat ^<environment^>
echo.
echo %YELLOW%支持的环境:%NC%
echo   dev   - 开发环境 (H2数据库, 热重载, 详细日志)
echo   prod  - 生产环境 (MySQL数据库, 优化配置, 生产日志)
echo   test  - 测试环境 (H2数据库, 测试配置, 简化日志)
echo.
echo %YELLOW%示例:%NC%
echo   switch-env.bat dev
echo   switch-env.bat prod
echo   switch-env.bat test
echo.
echo %YELLOW%选项:%NC%
echo   -h, --help    显示此帮助信息
echo.

:end
endlocal
pause