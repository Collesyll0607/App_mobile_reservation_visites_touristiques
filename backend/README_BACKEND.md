# ⚙️ Backend Spring Boot (`ms-patrimoine`) & Base MySQL

Ce dossier contient le microservice REST Spring Boot connecté à MySQL (`patrimoinedb`).

## Comment démarrer la base de données et le backend sur un nouveau PC (Collé ou Ndeye Thiamba)

1. **Démarrer MySQL via XAMPP :**
   - Ouvrir **XAMPP Control Panel** et cliquer sur **Start** à côté de **Apache** et **MySQL** (port `3306`, utilisateur `root`, sans mot de passe).
2. **Démarrer le Backend Spring Boot (`ms-patrimoine`) :**
   - Ouvrir le dossier `backend/` dans **IntelliJ IDEA** (ou dans un terminal avec Maven installé : `mvn spring-boot:run`).
   - Lancer la classe `MsPatrimoineApplication`.
3. **Création automatique de la base MySQL :**
   - Au premier démarrage, Spring Boot crée automatiquement la base **`patrimoinedb`** dans phpMyAdmin, toutes les tables (`patrimoines`, `utilisateurs`, `comptes_mobile`, `avis_mobile`) et insère les 5 sites de Casamance, les avis et les comptes de test (`aissatou.fall@gmail.com` / `passer123` et `touriste@uasz.sn` / `123456`).
4. **Vérifier dans phpMyAdmin :**
   - Aller sur `http://localhost/phpmyadmin` et cliquer sur `patrimoinedb`.

## Endpoints REST disponibles (Port `8081`)
- `GET /api/patrimoines` : Liste des sites touristiques
- `POST /api/auth/login` : Connexion (table `utilisateurs` + `comptes_mobile`)
- `POST /api/auth/register` : Inscription d'un nouveau touriste dans MySQL
- `POST /api/auth/reset-password` : Réinitialisation de mot de passe oublié
- `GET /api/avis/site/{id}` & `POST /api/avis` : Avis et notes sur les sites
