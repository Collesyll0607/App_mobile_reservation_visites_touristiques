import '../models/patrimoine.dart';

/// Associe chaque site touristique de Ziguinchor & Casamance à ses photographies
/// locales authentiques et à ses informations pratiques d'affichage.
class SiteMediaHelper {
  static const String heroBannerAsset =
      'assets/images/casamance/carabane_bolong.jpg';
  static const String splashRiverAsset =
      'assets/images/casamance/pirogue_fleuve.jpg';
  static const String heritageFooterAsset =
      'assets/images/casamance/bras_de_mer.jpg';

  /// Retourne le chemin d'asset local authentique pour un site donné
  static String primaryAssetForSite(Patrimoine site) {
    final nom = site.nom.toLowerCase();
    if (nom.contains('carabane')) {
      return 'assets/images/casamance/carabane_bolong.jpg';
    }
    if (nom.contains('impluvium') ||
        nom.contains('mlomp') ||
        nom.contains('enampore') ||
        nom.contains('case')) {
      return 'assets/images/casamance/cases_mlomp.jpg';
    }
    if (nom.contains('alliance')) {
      return 'assets/images/casamance/alliance_francaise.jpg';
    }
    if (nom.contains('boudody') || nom.contains('port')) {
      return 'assets/images/casamance/port_ziguinchor.jpg';
    }
    if (nom.contains('joola') || nom.contains('mémorial')) {
      return 'assets/images/casamance/memorial_joola.jpg';
    }
    if (nom.contains('cathédrale') || nom.contains('padoue')) {
      return 'assets/images/casamance/cathedrale_ziguinchor.jpg';
    }
    if (nom.contains('bolong') ||
        nom.contains('djilapao') ||
        nom.contains('mangrove') ||
        nom.contains('réserve')) {
      return 'assets/images/casamance/bolong_mangrove.jpg';
    }

    switch (site.categorie.toUpperCase()) {
      case 'NATURE':
        return 'assets/images/casamance/foret_casamance.jpg';
      case 'ARCHITECTURE':
        return 'assets/images/casamance/cases_mlomp.jpg';
      case 'MUSEE':
        return 'assets/images/casamance/memorial_joola.jpg';
      default:
        return 'assets/images/casamance/bras_de_mer.jpg';
    }
  }

  /// Retourne la galerie de photos locales associées au site
  static List<String> galleryAssetsForSite(Patrimoine site) {
    final primary = primaryAssetForSite(site);
    final nom = site.nom.toLowerCase();

    if (nom.contains('carabane')) {
      return [
        primary,
        'assets/images/casamance/pirogue_fleuve.jpg',
        'assets/images/casamance/bras_de_mer.jpg',
      ];
    }
    if (nom.contains('impluvium') || nom.contains('mlomp')) {
      return [
        primary,
        'assets/images/casamance/foret_casamance.jpg',
        'assets/images/casamance/alliance_francaise.jpg',
      ];
    }
    if (nom.contains('boudody') || nom.contains('port')) {
      return [
        primary,
        'assets/images/casamance/pirogue_fleuve.jpg',
        'assets/images/casamance/bolong_mangrove.jpg',
      ];
    }
    if (nom.contains('joola')) {
      return [
        primary,
        'assets/images/casamance/port_ziguinchor.jpg',
        'assets/images/casamance/bras_de_mer.jpg',
      ];
    }
    if (nom.contains('alliance')) {
      return [
        primary,
        'assets/images/casamance/cathedrale_ziguinchor.jpg',
        'assets/images/casamance/port_ziguinchor.jpg',
      ];
    }
    return [
      primary,
      'assets/images/casamance/bolong_mangrove.jpg',
      'assets/images/casamance/pirogue_fleuve.jpg',
    ];
  }

  /// Durée conseillée de visite selon le type de site
  static String dureeEstimee(Patrimoine site) {
    final nom = site.nom.toLowerCase();
    if (nom.contains('carabane') || nom.contains('bolong')) {
      return '2h 30 de visite';
    }
    if (nom.contains('impluvium') || nom.contains('mlomp')) {
      return '1h 30 de visite';
    }
    return '1h 00 de visite';
  }

  /// Mode d'accès conseillé selon la destination
  static String accesVisite(Patrimoine site) {
    final nom = site.nom.toLowerCase();
    if (nom.contains('carabane') || nom.contains('bolong')) {
      return 'Accessible en pirogue';
    }
    return 'Accès route & ville';
  }

  /// Libellé lisible des catégories
  static String labelCategorie(String categorie) {
    switch (categorie.toUpperCase()) {
      case 'MONUMENT':
        return 'Culture & Monuments';
      case 'NATURE':
        return 'Nature & Bolongs';
      case 'MUSEE':
        return 'Mémoire & Musées';
      case 'ARCHITECTURE':
        return 'Traditions & Cases';
      default:
        return 'Découverte';
    }
  }
}
