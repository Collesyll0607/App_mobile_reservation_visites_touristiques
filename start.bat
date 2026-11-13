@echo off
chcp 65001 > nul
title Casamance Tourisme - Lancement 1 Clic

echo ==================================================================
echo   🌴 DÉMARRAGE CASAMANCE TOURISME ^& VISITES (1 Clic Windows)     
echo ==================================================================

set PROJECT_ROOT=%~dp0
cd /d "%PROJECT_ROOT%"

:: 1. Vérification MySQL
echo [1/3] Verification de MySQL...
netstat -an | find ":3306 " > nul
if %errorlevel% equ 0 (
    echo   -^> MySQL est deja actif sur le port 3306.
) else (
    echo   -^> Demarrage de MySQL via XAMPP...
    if exist "C:\xampp\mysql\bin\mysqld.exe" (
        start "" /b "C:\xampp\mysql\bin\mysqld.exe" --defaults-file="C:\xampp\mysql\bin\my.ini" --standalone
        timeout /t 3 /nobreak > nul
    )
)

:: 2. Démarrage Backend Spring Boot
echo [2/3] Verification du Backend Spring Boot (8081)...
netstat -an | find ":8081 " > nul
if %errorlevel% equ 0 (
    echo   -^> Le Backend tourne deja sur le port 8081.
) else (
    echo   -^> Lancement du Backend ms-patrimoine...
    set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-21.0.12.101-hotspot"
    set "Path=%JAVA_HOME%\bin;%Path%"
    cd /d "%PROJECT_ROOT%backend"
    start "Backend Spring Boot" cmd /k "C:\Users\user\tools\apache-maven-3.9.9\bin\mvn.cmd spring-boot:run"
    cd /d "%PROJECT_ROOT%"
    echo   -^> Attente de l'initialisation du backend (10s)...
    timeout /t 10 /nobreak > nul
)

:: 3. Libération du port 8090 si déjà occupé
for /f "tokens=5" %%a in ('netstat -aon ^| find ":8090 "') do (
    echo   -^> Liberation automatique du port 8090 (PID %%a)...
    taskkill /F /PID %%a > nul 2>&1
)

:: 4. Démarrage Flutter Web
echo [3/3] Lancement de Flutter Web sur http://127.0.0.1:8090...
start "" "http://127.0.0.1:8090"
"C:\src\flutter\bin\flutter.bat" run -d web-server --web-hostname 127.0.0.1 --web-port 8090
