# 📱 Application Mobile de Réservation de Visites Touristiques (Ziguinchor / Casamance)

> **Projet de Mémoire de Fin de Cycle — Licence 3 Ingénierie Informatique (L3-2I)**  
> **Option :** Génie Logiciel (GL)  
> **Institution :** Université Assane Seck de Ziguinchor (UASZ) — UFR Sciences et Technologies  
> **Encadreur :** **Dr. Lamine FATY**  
> **Binôme :** **Collé SYLL** & **Ndeye Thiamba FAYE**

---

## 🎯 Présentation du Projet (Sujet 2)

Ce projet consiste à concevoir et développer une **application mobile multiplateforme (Flutter / Dart)** connectée à une **API REST (Spring Boot / MySQL)** permettant aux touristes de :
1. Découvrir les sites patrimoniaux et circuits touristiques de Ziguinchor et de la Casamance.
2. Géolocaliser les sites sur une carte interactive et calculer l'itinéraire.
3. **Réserver des visites touristiques** (choix de la date, du créneau horaire, du nombre de visiteurs et d'un guide touristique).
4. Obtenir un **billet numérique avec QR Code** après validation/paiement Mobile Money (Wave / Orange Money).
5. Sauvegarder ses favoris et ses billets en **mode hors-ligne**.

---

## 🤝 Répartition du Travail en Binôme (50% / 50%)

Pour garantir un travail collaboratif fluide sur GitHub **sans aucun conflit de fichiers**, l'architecture du code source (`lib/`) est divisée en deux pôles indépendants reliés par un socle commun (`lib/core/`) :

| Pôle & Étudiante | Dossier de Travail | Modules & Fonctionnalités Responsables |
| :--- | :--- | :--- |
| **👩‍💻 PÔLE 1 : Collé SYLL** | `lib/features_colle/` | • **Authentification & Profil** (`login_screen.dart`, `register_screen.dart`, `profile_screen.dart`)<br>• **Catalogue & Découverte** (`home_screen.dart`, `site_detail_screen.dart`, recherche & filtres)<br>• **Cartographie & GPS** (`map_explore_screen.dart` : carte des sites & itinéraires)<br>• **Avis & Notes** (`reviews_section.dart` : notation et commentaires) |
| **👩‍💻 PÔLE 2 : Ndeye Thiamba FAYE** | `lib/features_thiamba/` | • **Tunnel de Réservation** (`booking_form_screen.dart`, `guide_select_screen.dart`, calcul des tarifs)<br>• **Paiement & Billet QR Code** (`payment_screen.dart`, `ticket_qr_screen.dart`)<br>• **Mes Réservations & Espace Guide** (`my_bookings_screen.dart`, `guide_dashboard_screen.dart`)<br>• **Favoris Hors-Ligne** (`favorites_screen.dart` : sauvegarde locale) |

---

## 📁 Architecture des Dossiers (`lib/`)

```text
lib/
├── main.dart                          # Point d'entrée de l'application Flutter
├── core/                              # 🧱 SOCLE COMMUN (Partagé par le binôme)
│   ├── theme/app_theme.dart           # Thème visuel Casamance (Vert forêt & Ocre)
│   ├── config/api_config.dart         # Configuration de l'API REST & Données initiales
│   └── models/                        # Modèles de données Dart
│       ├── patrimoine.dart            # Modèle Site Touristique
│       ├── circuit.dart               # Modèle Circuit Touristique
│       ├── reservation.dart           # Modèle Réservation de Visite
│       ├── utilisateur.dart           # Modèle Utilisateur (Touriste / Guide)
│       └── avis.dart                  # Modèle Avis & Évaluation
│
├── features_colle/                    # 👩‍💻 ESPACE EXCLUSIF DE COLLÉ SYLL
│   ├── README_COLLE.md                # Feuille de route détaillée de Collé
│   ├── auth/                          # Connexion, Inscription, Profil
│   ├── catalogue/                     # Accueil, Détail site, Filtres, Service API
│   ├── map/                           # Carte interactive & Géolocalisation GPS
│   └── reviews/                       # Section Avis & Notes des visiteurs
│
└── features_thiamba/                  # 👩‍💻 ESPACE EXCLUSIF DE NDEYE THIAMBA FAYE
    ├── README_THIAMBA.md              # Feuille de route détaillée de Ndeye Thiamba
    ├── reservation/                   # Formulaire de réservation, Choix Guide, Service API
    ├── ticketing/                     # Paiement Wave/OM & Billet numérique QR Code
    ├── my_bookings/                   # Historique réservations & Tableau de bord Guide
    └── favorites/                     # Favoris sauvegardés en local (Mode Offline)
```

---

## 🐙 Guide GitHub pour le Binôme

### Branches du dépôt :
- `main` : Branche stable officielle (pour les démonstrations avec Dr. Lamine FATY).
- `develop` : Branche de mise en commun du binôme.
- `colle-dev` : Branche de travail de **Collé SYLL**.
- `thiamba-dev` : Branche de travail de **Ndeye Thiamba FAYE**.

### Commandes pour récupérer et travailler sur sa branche :

**Pour Collé SYLL :**
```bash
git checkout colle-dev
git pull origin develop
# Après avoir modifié des fichiers dans lib/features_colle/ :
git add .
git commit -m "Avancement module catalogue / carte"
git push origin colle-dev
```

**Pour Ndeye Thiamba FAYE :**
```bash
git clone https://github.com/Collesyll0607/App_mobile_reservation_visites_touristiques.git
cd App_mobile_reservation_visites_touristiques
git checkout thiamba-dev
# Après avoir modifié des fichiers dans lib/features_thiamba/ :
git add .
git commit -m "Avancement module reservation / billet QR"
git push origin thiamba-dev
```
