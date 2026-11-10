# Image de base Java 21 LTS
FROM eclipse-temurin:21-jdk

# Mainteneurs : Colle SYLL & Ndèye Thiamba FAYE
LABEL maintainer="Colle SYLL (202300489) & Ndeye Thiamba FAYE (202300488)"

# Port d'écoute du microservice
EXPOSE 8081

# Copie du jar exécutable
COPY target/*.jar app.jar

# Commande de démarrage
ENTRYPOINT ["java", "-jar", "app.jar"]
