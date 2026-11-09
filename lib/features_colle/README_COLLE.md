# 👩‍💻 ESPACE DE TRAVAIL — COLLÉ SYLL (`lib/features_colle/`)

Ce dossier contient l'ensemble des modules sous la responsabilité de **Collé SYLL** pour le mémoire de Licence 3 (UASZ).

## Modules pris en charge :
1. **`auth/`** : Authentification (Connexion, Inscription Touriste/Guide, Profil).
2. **`catalogue/`** : Écran d'accueil, recherche par mot-clé, filtrage par catégorie (`MONUMENT`, `NATURE`, `MUSEE`, `ARCHITECTURE`), et écran de détail d'un site patrimonial.
3. **`map/`** : Carte interactive de Ziguinchor & Casamance, géolocalisation GPS et calcul d'itinéraire.
4. **`reviews/`** : Affichage et ajout d'avis/notes (1 à 5 étoiles) sur les sites visités.

## Point de connexion avec Ndeye Thiamba FAYE :
Dans `catalogue/site_detail_screen.dart`, le bouton **« Réserver une visite »** redirige vers `BookingFormScreen(site: patrimoine)` situé dans `lib/features_thiamba/reservation/booking_form_screen.dart`.
