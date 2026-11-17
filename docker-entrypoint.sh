#!/bin/sh
set -e

# Remplacement propre de l'URL cible du backend dans la configuration Nginx
TARGET_URL="${BACKEND_URL:-http://backend:8081/api/}"
sed -i "s|__BACKEND_URL__|${TARGET_URL}|g" /etc/nginx/conf.d/default.conf

exec "$@"
