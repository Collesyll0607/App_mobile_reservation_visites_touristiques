# ==========================================
# Étape 1 : Construction du Flutter Web
# ==========================================
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copie des fichiers de dépendances d'abord pour optimiser le cache Docker
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copie du reste des sources
COPY . .

# Construction du bundle web optimisé pour la production
RUN flutter build web --release

# ==========================================
# Étape 2 : Serveur de production Nginx
# ==========================================
FROM nginx:alpine

# Copie des fichiers compilés de Flutter Web
COPY --from=build /app/build/web /usr/share/nginx/html

# Copie de la configuration Nginx et du script d'injection dynamique d'URL
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Port d'écoute du serveur web
EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
