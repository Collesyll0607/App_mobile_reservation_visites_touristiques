# 📱 NOUVEAU PROJET DE MÉMOIRE (L3-2I) — ÉDITION FLUTTER / DART

**Sujet Officiel :**  
> **SUJET 2 : Développement d'une application mobile de réservation de visites touristiques**

- **Institution :** Université Assane Seck de Ziguinchor (UASZ) — UFR Sciences & Technologies / Dpt Informatique
- **Parcours :** Licence 3 Ingénierie Informatique (L3-2I) — Option Génie Logiciel
- **Encadreur :** Dr. Lamine FATY
- **Binôme d'étudiantes :** Collé SYLL & Ndeye Thiamba FAYE
- **Technologie Mobile retenue :** **Flutter & Dart** (Cross-platform Android / iOS)

---

## 🎯 1. RECADRAGE DU SUJET : LA RÉSERVATION AU CŒUR DE L'APPLICATION

Le sujet évolue d'une simple découverte vers une plateforme interactive complète de **RÉSERVATION DE VISITES TOURISTIQUES**.

### Fonctionnalités Clés du Système :
1. **Catalogue des Sites & Circuits :** Découverte des patrimoines (photos, descriptions, tarifs, guides attitrés).
2. **Système de Réservation de Visites :**
   - Choix de la date et du créneau horaire.
   - Sélection du nombre de personnes (adultes, enfants).
   - Choix avec ou sans guide touristique.
   - Suivi du statut de la réservation (*EN_ATTENTE, CONFIRMEE, ANNULEE, EFFECTUEE*).
3. **Espace Guides Touristiques :** Consultation des visites assignées, validation des disponibilités.
4. **Géolocalisation & Itinéraires :** Cartographie interactive (Google Maps / OpenStreetMap), repérage des points de départ de visite.
5. **Paiement / Acompte :** Simulation ou intégration de paiement mobile local (Wave / Orange Money).
6. **Historique & Billets :** Génération de pass/tickets de réservation numériques avec QR code.

---

## 🏗️ 2. NOUVELLE ARCHITECTURE LOGICIELLE GLOBALE

```
       [ BASE DE DONNÉES MYSQL (db_patrimoine) ]
                           ▲
                           │
      [ BACKEND SPRING BOOT (ms-patrimoine : 8081) ]
         │ (Données JSON via API REST)
         ├────────────────────────────────────────┐
         ▼                                        ▼
[ APPLICATION MOBILE FLUTTER (DART) ]     [ PORTAIL WEB GESTION ]
 (Pour les touristes & guides)             (Pour les conservateurs / admin)
 - Catalogue des sites & photos            - Ajout / Modif de sites
 - Module de réservation interactif        - Validation des réservations
 - Billetterie numérique / QR Code         - Modération des avis & guides
 - Géolocalisation & Carte
```

---

## 💡 3. POURQUOI LE CHOIX DE FLUTTER & DART EST EXCELLENT POUR LE MÉMOIRE

Dans le chapitre **Conception & Justification des Choix Techniques** de votre rapport, ce choix apportera une immense valeur ajoutée :

1. **Multiplateforme réel (Single Codebase) :** Un seul code Dart permet de déployer sur Android, iOS et même le Web.
2. **Performances natives :** Flutter compile directement en code machine ARM/x86 (pas de bridge JavaScript lent).
3. **UI moderne et réactive :** Système de widgets déclaratifs puissants adaptés aux fiches touristiques immersives.
4. **Communauté & Packages riches :** Intégration aisée de Google Maps, de QR Codes, d'animations et de requêtes HTTP.

---

## 📋 4. PLAN DE DÉMARRAGE ÉTAPE PAR ÉTAPE (REPRISE DE A À Z)

1. **Étape 1 — Environnement :**
   - Téléchargement et installation du **SDK Flutter**.
   - Configuration dans VS Code ou Android Studio (extensions Flutter & Dart).
   - Exécution de `flutter doctor` pour vérifier l'environnement.

2. **Étape 2 — Structuration du code Dart :**
   - Architecture en couches propres (`lib/models`, `lib/services`, `lib/screens`, `lib/widgets`).
   - Définition des modèles Dart : `Patrimoine`, `Circuit`, `Reservation`, `Visite`, `Utilisateur`.

3. **Étape 3 — Conception des Écrans (UI) :**
   - Écran de connexion & inscription touriste.
   - Page d'accueil : Liste des sites patrimoniaux avec barre de recherche et filtres par catégorie.
   - Page détail du site avec bouton **« Réserver une visite »**.
   - Formulaire de réservation interactif (calendrier, sélection d'horaire, choix du guide).
   - Écran « Mes Réservations » (historique et tickets).

4. **Étape 4 — Interconnexion avec l'API REST existante :**
   - Votre backend Spring Boot possède déjà les entités `Reservation` et `Patrimoine`.
   - On ajoutera les endpoints REST JSON dédiés à la création et au suivi des réservations pour Flutter.
