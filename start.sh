#!/usr/bin/env bash
# ==============================================================================
# Script de lancement automatique en 1 clic — Casamance Tourisme & Visites
# Démarre : MySQL (XAMPP) + Backend Spring Boot + Frontend Flutter Web
# Usage dans Git Bash : ./start.sh
# ==============================================================================

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

echo "=================================================================="
echo "  🌴 DÉMARRAGE CASAMANCE TOURISME & VISITES (Lancement 1 Clic)   "
echo "=================================================================="

# 1. Vérifier et démarrer MySQL (XAMPP) si non actif
echo "[1/3] Vérification de la base de données MySQL..."
if netstat -an 2>/dev/null | grep -q ":3306 "; then
    echo "  -> MySQL est déjà actif sur le port 3306. Parfait."
else
    echo "  -> Démarrage de MySQL (XAMPP)..."
    if [ -f "/c/xampp/mysql/bin/mysqld.exe" ]; then
        /c/xampp/mysql/bin/mysqld.exe --defaults-file=/c/xampp/mysql/bin/my.ini --standalone &
        sleep 3
        echo "  -> MySQL démarré avec succès."
    else
        echo "  [AVERTISSEMENT] XAMPP non détecté à C:\\xampp. Assurez-vous que MySQL tourne."
    fi
fi

# 2. Configurer Java 21 et démarrer le Backend Spring Boot (port 8081)
echo "[2/3] Démarrage du Backend Spring Boot (ms-patrimoine)..."
export JAVA_HOME="/c/Program Files/Eclipse Adoptium/jdk-21.0.12.101-hotspot"
export PATH="$JAVA_HOME/bin:$PATH"

if netstat -an 2>/dev/null | grep -q ":8081 "; then
    echo "  -> Le Backend Spring Boot tourne déjà sur le port 8081."
else
    cd "$PROJECT_ROOT/backend"
    /c/Users/user/tools/apache-maven-3.9.9/bin/mvn.cmd spring-boot:run > "$PROJECT_ROOT/backend.log" 2>&1 &
    BACKEND_PID=$!
    echo "  -> Backend lancé en tâche de fond (PID: $BACKEND_PID, logs dans backend.log)."
    cd "$PROJECT_ROOT"
    
    echo "  -> Attente de l'initialisation du backend..."
    for i in {1..20}; do
        if netstat -an 2>/dev/null | grep -q ":8081 "; then
            echo "  -> Backend Spring Boot prêt sur http://127.0.0.1:8081 !"
            break
        fi
        sleep 1
    done
fi

# 3. Démarrer le Frontend Flutter Web (port 8090)
echo "[3/3] Lancement de l'application Flutter Web..."
echo "=================================================================="
echo "  Application accessible sur : http://127.0.0.1:8090              "
echo "  Appuyez sur 'q' ou Ctrl+C dans ce terminal pour quitter.        "
echo "=================================================================="

# Ouvrir le navigateur automatiquement
(sleep 4 && start "http://127.0.0.1:8090") &

# Lancer Flutter
/c/src/flutter/bin/flutter.bat run -d web-server --web-hostname 127.0.0.1 --web-port 8090
