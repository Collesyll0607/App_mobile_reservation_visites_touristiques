# 🤝 RÉPARTITION DU PROJET EN BINÔME & WORKFLOW GITHUB

**Projet :** Développement d'une application mobile de réservation de visites touristiques (Flutter / Dart & Spring Boot)  
**Encadreur :** Dr. Lamine FATY  
**Binôme :** **Collé SYLL** & **Ndeye Thiamba FAYE**

---

## 🎯 Objectif de cette répartition

1. **Équilibre parfait (50% / 50%) :** Chacune développe des fonctionnalités complètes de bout en bout (Interfaces Flutter + Logique Dart + Connexion API) pour maîtriser sa partie lors des questions du jury.
2. **Zéro conflit sur GitHub :** Le code est découpé en **modules indépendants (Feature Folders)**. Vous ne modifiez jamais les mêmes fichiers en même temps.
3. **Conformité avec le Template UASZ :** Cette répartition s'intègre directement dans la section *"2.5 Répartition des rôles entre étudiants du groupe"* et le *Backlog Agile Scrum* du mémoire.

---

## 🧩 1. DIVISION TECHNIQUE DES FONCTIONNALITÉS (50 / 50)

### 👩‍💻 PÔLE 1 — **Collé SYLL**
*Responsable : Acquisition utilisateur, Catalogue patrimonial, Recherche & Géolocalisation GPS*

| Fonctionnalité | Écrans Flutter (`Screens`) | Logique & API |
| :--- | :--- | :--- |
| **1. Authentification & Profil** | `login_screen.dart`<br>`register_screen.dart`<br>`profile_screen.dart` | Connexion Touriste/Guide, gestion de session, modification du profil. |
| **2. Accueil & Catalogue** | `home_screen.dart`<br>`site_list_screen.dart`<br>`site_detail_screen.dart` | Récupération HTTP des sites et circuits, recherche par mot-clé, filtrage par catégorie (Monuments, Nature, Musées). |
| **3. Carte Interactive & GPS** | `map_explore_screen.dart` | Affichage des marqueurs sur la carte de Ziguinchor, calcul de la position GPS du touriste et distance jusqu'au site. |
| **4. Avis & Évaluations** | `reviews_widget.dart` | Affichage et soumission d'une note (étoiles) et d'un commentaire sur un site. |

---

### 👩‍💻 PÔLE 2 — **Ndeye Thiamba FAYE**
*Responsable : Moteur de réservation, Billetterie numérique QR Code, Espace Guide & Mode Offline*

| Fonctionnalité | Écrans Flutter (`Screens`) | Logique & API |
| :--- | :--- | :--- |
| **1. Tunnel de Réservation** | `booking_form_screen.dart`<br>`guide_select_screen.dart` | Sélection de la date (`DatePicker`), choix du créneau horaire, nombre de participants, sélection d'un guide disponible et calcul automatique du prix total. |
| **2. Paiement & Billet QR Code**| `payment_screen.dart`<br>`ticket_qr_screen.dart` | Simulation de paiement Mobile Money (Wave / Orange Money), génération du billet de visite numérique avec **QR Code unique**. |
| **3. Gestion des Réservations & Espace Guide** | `my_bookings_screen.dart`<br>`guide_dashboard_screen.dart` | Historique des réservations du touriste (*En attente, Confirmée, Annulée*), annulation, et écran Guide pour accepter/valider une visite. |
| **4. Favoris & Hors-Ligne** | `favorites_screen.dart` | Sauvegarde locale sur le téléphone des sites coup de cœur et des billets réservés pour les consulter sans connexion Internet. |

---

## 📁 2. STRUCTURE DES DOSSIERS FLUTTER (ANTI-CONFLITS GITHUB)

```text
lib/
├── main.dart                          # Point d'entrée (Socle commun)
├── core/                              # 🧱 SOCLE COMMUN (Initialisé au départ)
│   ├── theme/app_theme.dart           # Couleurs et styles de l'application
│   ├── config/api_config.dart         # URL du serveur Spring Boot
│   ├── models/                        # Modèles de données partagés
│   │   ├── patrimoine.dart
│   │   ├── circuit.dart
│   │   ├── reservation.dart
│   │   ├── utilisateur.dart
│   │   └── avis.dart
│   └── services/api_client.dart       # Configuration HTTP de base
│
├── features_colle/                    # 👩‍💻 DOSSIER EXCLUSIF DE COLLÉ SYLL
│   ├── auth/
│   ├── catalogue/
│   ├── map/
│   └── reviews/
│
└── features_thiamba/                  # 👩‍💻 DOSSIER EXCLUSIF DE NDEYE THIAMBA FAYE
    ├── reservation/
    ├── ticketing/
    ├── my_bookings/
    └── favorites/
```

---

## 🐙 3. ORGANISATION GITHUB (BRANCHES & WORKFLOW)

- `main` : Branche stable finale.
- `develop` : Branche de mise en commun hebdomadaire.
- `colle-dev` : Branche de travail de **Collé SYLL**.
- `thiamba-dev` : Branche de travail de **Ndeye Thiamba FAYE**.
