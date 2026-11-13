# 🌴 Guide Technique & Manuel d'Ingénierie — Casamance Tourisme & Visites

> **Projet de Fin d'Études / Mémoire Licence 3 Informatique (Génie Logiciel)**  
> **Auteurs :** Colle SYLL & Ndeye Thiamba FAYE  
> **Application :** Plateforme Web & Mobile de Découverte et de Réservation de Visites Touristiques et Culturelles en Casamance.

---

## 📑 Sommaire
1. [Présentation Générale & Vision](#1-présentation-générale--vision)
2. [Architecture Technique Globale](#2-architecture-technique-globale)
3. [Direction Artistique & Design System](#3-direction-artistique--design-system)
4. [Répartition des Rôles & Fonctionnalités Détaillées](#4-répartition-des-rôles--fonctionnalités-détaillées)
5. [Structure Complète du Code Source](#5-structure-complète-du-code-source)
6. [Backend Spring Boot & API REST](#6-backend-spring-boot--api-rest)
7. [Base de Données & Données Initiales](#7-base-de-données--données-initiales)
8. [Frontend Flutter & Gestion d'État](#8-frontend-flutter--gestion-détat)
9. [Guide de Démarrage Rapide (3 Modes)](#9-guide-de-démarrage-rapide-3-modes)
10. [Dépannage & Bonnes Pratiques](#10-dépannage--bonnes-pratiques)

---

## 1. Présentation Générale & Vision

L'application **Casamance Tourisme & Visites** a été conçue pour valoriser la richesse culturelle, historique et naturelle de la région de Casamance (Sénégal). 

### Objectifs principaux :
- Offrir une expérience utilisateur de niveau international basée sur le concept **« African Tropical Luxury Travel »**.
- Permettre aux touristes nationaux et internationaux d'explorer les sites incontournables (Ziguinchor, Cap Skirring, Oussouye, Karabane, etc.).
- Faciliter la planification et la réservation de visites guidées avec choix de guide local et d'horaires.
- Intégrer les moyens de paiement mobile locaux sénégalais (**Wave**, **Orange Money**) et la délivrance d'un **e-ticket avec QR Code**.
- Fournir une carte GPS interactive géolocalisée de la Casamance.

---

## 2. Architecture Technique Globale

Le projet repose sur une architecture **3-Tiers découplée et conteneurisable** :

```
┌─────────────────────────────────────────────────────────────┐
│                    CLIENTS UTILISATEURS                     │
│    Desktop Web (Chrome, Edge)  |  Mobile (Android / iOS)    │
└──────────────────────────────┬──────────────────────────────┘
                               │ HTTPS / JSON REST
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                   FRONTEND FLUTTER WEB/MOBILE               │
│  - Framework: Flutter 3.24+ / Dart                          │
│  - Design System: African Tropical Luxury Travel             │
│  - Moteur de rendu: CanvasKit / HTML                        │
│  - Port Web: 8090 (ou 80 via Nginx sous Docker)            │
└──────────────────────────────┬──────────────────────────────┘
                               │ HTTP REST calls (/api/...)
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                   BACKEND SPRING BOOT 3                     │
│  - Java 21 LTS + Spring Boot 3.3.4                          │
│  - Spring Data JPA / Hibernate                              │
│  - Sécurité & Validation REST                               │
│  - Port Backend: 8081                                       │
└──────────────────────────────┬──────────────────────────────┘
                               │ JDBC (Port 3306)
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                   BASE DE DONNÉES MYSQL 8                   │
│  - Schéma: `patrimoinedb`                                    │
│  - Persistance des utilisateurs, sites, réservations & avis │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. Direction Artistique & Design System

Le style visuel a été entièrement refondu pour quitter l'apparence générique et adopter une identité digne des magazines de voyage haut de gamme (*African Tropical Luxury Travel*).

### Palette Chromatique Officielle
| Couleur | Code HEX | Usage dans l'application |
| :--- | :--- | :--- |
| **Vert Émeraude** | `#145C42` | Couleur primaire d'accentuation, boutons d'action majeurs |
| **Vert Forêt Profond** | `#123B2E` | Hero, barres de navigation et éléments d'immersion |
| **Ivoire Végétal** | `#FAF8F1` | Arrière-plan principal, chaleur et douceur de lecture |
| **Sable Casamançais** | `#E9DDC7` | Cartes, bordures délicates, séparateurs |
| **Terracotta Solaire** | `#C8754D` | Badges, étoiles d'avis, prix et call-to-actions secondaires |
| **Texte Profond** | `#202820` | Typographie principale pour un contraste et lisibilité optimaux |

### Typographie
- **Titres éditoriaux & Hero :** `Playfair Display` (serif élégant).
- **Corps de texte & UI :** `Inter` ou `Plus Jakarta Sans` (sans-serif moderne, optimisé pour la lecture sur écrans mobiles et desktop).

### Composants Clés de la Page d'Accueil (`home_screen.dart`)
1. **Header Flottant Verre Dépoli (Glassmorphism) :** Navigation transparente sur le Hero, devenant opaque avec flou doux au défilement.
2. **Hero Panoramique 75vh :** Photographie plein cadre de pirogue sur les bolongs de Casamance, badge *« Sénégal • Casamance »*, typographie Playfair et micro-carte flottante de Karabane.
3. **Barre de Recherche Flottante :** Filtres compacts par destination, type d'expérience et date.
4. **Grille Asymétrique Magazine :** Mise en avant d'une grande carte vedette et de cartes secondaires harmonieuses.
5. **Section Éditoriale « L'Âme de la Casamance » :** Découverte thématique (Bolongs, Cases à impluvium, Rituels Diola, Artisanat).

---

## 4. Répartition des Rôles & Fonctionnalités Détaillées

Le projet a été développé en binôme selon une répartition claire des fonctionnalités :

### 👩‍💻 Binôme 1 : Colle SYLL (`features_colle/` & Socle API)
* **Authentification & Profil (`auth/`) :** Inscription, connexion, gestion de session utilisateur en mémoire/stockage local (`auth_service.dart`).
* **Catalogue du Patrimoine (`catalogue/`) :** 
  - Page d'accueil luxe (`home_screen.dart`).
  - Liste filtrable et recherche en direct (`sites_list_screen.dart`).
  - Fiche détaillée du site avec galerie photo, tarification, horaires et infos pratiques (`site_detail_screen.dart`).
* **Système d'Avis & Notations (`reviews/`) :** Consultation des retours d'expérience, dépôt d'avis avec note de 1 à 5 étoiles (`reviews_section.dart`).
* **Exploration Géographique GPS (`map/`) :** Carte interactive pointant les coordonnées GPS réelles des sites de Casamance (`map_explore_screen.dart`).
* **Écran de démarrage (`splash/`) :** Animation d'introduction à l'ouverture de l'application.

### 👩‍💻 Binôme 2 : Ndeye Thiamba FAYE (`features_thiamba/`)
* **Favoris & Wishlist (`favorites/`) :** Ajout/retrait de sites coups de cœur avec persistance (`favorites_service.dart`).
* **Tunnel de Réservation (`reservation/`) :** Formulaire de réservation de visite avec sélection de date, créneau horaire, nombre de personnes et option guide local (`booking_form_screen.dart`).
* **Paiement Mobile Sécurisé (`payment/`) :** Intégration de l'interface de paiement simulant **Wave** et **Orange Money Sénégal** avec confirmation instantanée (`payment_screen.dart`).
* **Billetterie & QR Code (`ticketing/`) :** Génération du billet électronique officiel avec passagers, référence unique et QR Code scannable (`ticket_qr_screen.dart`).
* **Gestion des Visites Utilisateur (`my_bookings/`) :** Historique complet des réservations en cours et passées.
* **Espace Guide Local (`guide_dashboard_screen.dart`) :** Tableau de bord pour les guides locaux de Casamance.

---

## 5. Structure Complète du Code Source

```
PROJET_MEMOIRE/
├── backend/                             # ☕ Backend Spring Boot
│   ├── pom.xml                          # Dépendances Maven (Java 21, Spring Boot, MySQL)
│   ├── Dockerfile                       # Image multi-stage backend JRE 21
│   └── src/main/
│       ├── java/sn/zig/patrimoine/
│       │   ├── MsPatrimoineApplication.java   # Point d'entrée Spring Boot
│       │   ├── MsDataInitializer.java         # Seed automatique des données patrimoniales
│       │   ├── controller/                    # Contrôleurs REST
│       │   │   ├── AuthMobileController.java
│       │   │   ├── AvisMobileController.java
│       │   │   ├── PatrimoineController.java
│       │   │   └── ReservationMobileController.java
│       │   ├── model/                         # Entités JPA
│       │   │   ├── Patrimoine.java
│       │   │   ├── ReservationMobile.java
│       │   │   ├── AvisMobile.java
│       │   │   ├── UtilisateurBdd.java
│       │   │   └── CompteMobile.java
│       │   ├── repository/                    # Interfaces Spring Data JPA
│       │   └── service/                       # Logique métier et implémentations
│       └── resources/
│           └── application.yml          # Configuration DataSource, Hibernate et Port 8081
│
├── lib/                                 # 📱 Frontend Flutter
│   ├── main.dart                        # Point d'entrée de l'application Flutter
│   ├── core/                            # Socle transverse
│   │   ├── config/api_config.dart       # Détection auto localhost / Android / Web
│   │   ├── models/                      # Modèles Dart miroir des entités JPA
│   │   ├── theme/app_theme.dart         # Design System Luxury (Playfair, Inter, Couleurs)
│   │   ├── utils/site_media_helper.dart # Banques d'images HD certifiées Casamance
│   │   └── widgets/casamance_widgets.dart
│   ├── features_colle/                  # Modules Colle SYLL
│   │   ├── auth/                        # Login, Register, Profile
│   │   ├── catalogue/                   # HomeScreen Luxe, SitesList, SiteDetail
│   │   ├── map/                         # Carte interactive GPS
│   │   ├── reviews/                     # Avis & Notations
│   │   └── splash/                      # Splash Screen
│   └── features_thiamba/                # Modules Ndeye Thiamba FAYE
│       ├── favorites/                   # Gestion des favoris
│       ├── reservation/                 # Formulaire de réservation
│       ├── payment/                     # Paiement Wave / Orange Money
│       ├── ticketing/                   # E-Ticket avec QR Code
│       ├── my_bookings/                 # Historique des réservations
│       └── guide/                       # Espace dédié aux guides
│
├── assets/                              # Images, logos et icônes locaux
├── web/                                 # Fichiers d'hébergement Web (index.html, manifest)
├── Dockerfile                           # Compilation Flutter Web + Nginx Alpine
├── nginx.conf                           # Configuration serveur Web et reverse-proxy /api/
├── docker-compose.yml                   # Orchestration globale 1 commande
├── start.sh                             # Démarrage 1-clic pour Git Bash / macOS / Linux
├── start.bat                            # Démarrage 1-clic pour Windows (double-clic)
└── pubspec.yaml                         # Dépendances Flutter (google_fonts, qr_flutter, etc.)
```

---

## 6. Backend Spring Boot & API REST

Le backend écoute sur le port **`8081`** et expose les endpoints suivants :

### 1. Patrimoine & Sites Touristiques (`/api/patrimoines`)
- `GET /api/patrimoines` : Récupérer tous les sites touristiques.
- `GET /api/patrimoines/{id}` : Récupérer le détail d'un site.
- `GET /api/patrimoines/search?motCle=...` : Recherche par mot-clé (nom, région, ville).
- `GET /api/patrimoines/categorie/{cat}` : Filtrer par catégorie (Nature, Culture, Plage, etc.).
- `POST /api/patrimoines` : Ajouter un nouveau site (rôle admin).

### 2. Authentification Mobile (`/api/auth`)
- `POST /api/auth/register` : Inscription d'un nouvel utilisateur.
- `POST /api/auth/login` : Authentification et récupération du profil.

### 3. Réservations (`/api/reservations`)
- `POST /api/reservations` : Créer une nouvelle réservation de visite.
- `GET /api/reservations/user/{email}` : Obtenir les réservations d'un utilisateur.
- `PUT /api/reservations/{id}/annuler` : Annulation d'une visite.

### 4. Avis & Évaluations (`/api/avis`)
- `GET /api/avis/patrimoine/{id}` : Lister tous les avis associés à un site.
- `POST /api/avis` : Soumettre un nouvel avis vérifié avec note de 1 à 5.

---

## 7. Base de Données & Données Initiales

La base de données MySQL est automatiquement initialisée via `MsDataInitializer.java` au premier démarrage.

### Sites préchargés dans la base :
1. **Île de Karabane :** Ancien comptoir colonial, église historique et plages bordées de cocotiers.
2. **Cap Skirring :** Plages infinies de sable fin et spot international de détente.
3. **Cases à Impluvium d'Enampore :** Chef-d'œuvre de l'architecture traditionnelle Diola.
4. **Forêt Sacrée & Royaume d'Oussouye :** Cœur spirituel de la royauté traditionnelle Diola.
5. **Marché Artisanal de Ziguinchor :** Ébénisterie, vannerie, tissus traditionnels et batiks.
6. **Parc National de la Basse-Casamance :** Écosystème riche en oiseaux migrateurs et faune locale.
7. **Pointe Saint-Georges :** Observation des lamentins et coucher de soleil sur le fleuve Casamance.

---

## 8. Frontend Flutter & Gestion d'État

### Résilience Réseau & Support Multi-Plateforme
Le fichier `lib/core/config/api_config.dart` calcule dynamiquement l'URL de base de l'API selon le contexte d'exécution :
- **Web (Chrome / Edge) :** `http://127.0.0.1:8081`
- **Émulateur Android officiel :** `http://10.0.2.2:8081`
- **Appareil Physique :** Adresse IP locale de votre machine (ex: `http://192.168.1.X:8081`)

### Mode Hors-Ligne & Données de Secours
Si le backend est éteint ou inaccessible, le service Flutter bascule en toute transparence sur un catalogue local de secours avec images certifiées haute définition. **L'application ne crash jamais et n'affiche aucun écran blanc.**

---

## 9. Guide de Démarrage Rapide (3 Modes)

Vous avez 3 manières ultra-simples de lancer le projet complet :

### 🟢 MODE 1 : Lancement 1-Clic via Git Bash (Recommandé)
Ouvrez simplement votre terminal **Git Bash** à la racine du projet et tapez :
```bash
./start.sh
```
*Le script démarre MySQL, lance Spring Boot, attend qu'il soit prêt, démarre Flutter Web et ouvre votre navigateur sur `http://127.0.0.1:8090`.*

---

### 🟢 MODE 2 : Lancement 1-Clic via Double-Clic Windows
Dans l'Explorateur de fichiers Windows, rendez-vous dans le dossier `PROJET_MEMOIRE` et **double-cliquez sur `start.bat`**.

---

### 🐳 MODE 3 : Lancement 1-Clic via Docker Compose
Si vous disposez de Docker Desktop, vous n'avez besoin d'installer aucun outil de développement (ni Java, ni Maven, ni Flutter) :
```bash
docker compose up --build
```
- **Application Web :** [http://localhost:8090](http://localhost:8090)
- **API Backend :** [http://localhost:8081](http://localhost:8081)
- **Pour arrêter :** `docker compose down`

---

## 10. Dépannage & Bonnes Pratiques

| Problème rencontré | Cause | Solution |
| :--- | :--- | :--- |
| `SocketException: Port 8090 already in use` | Une ancienne instance Flutter n'a pas été fermée | Le script `start.sh` libère automatiquement le port. Vous pouvez aussi taper `taskkill //F //IM dart.exe`. |
| `Communications link failure (Port 3306)` | MySQL n'est pas démarré | Démarrez le service MySQL dans le panneau de contrôle XAMPP. |
| `Class not found: CardThemeData` | Version récente de Flutter 3.31+ | Le thème utilise déjà la syntaxe moderne compatible `CardThemeData`. |
| Images lentes ou bloquées | Connexion internet limitée | L'application utilise un helper d'assets avec fallback local instantané. |

---

*Développé avec passion pour la valorisation du patrimoine de la Casamance — Février 2026.*
