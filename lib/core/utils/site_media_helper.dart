import '../models/patrimoine.dart';

/// Associe chaque site touristique de Ziguinchor & Casamance à ses photographies
/// locales authentiques (zero doublon visuel, zero espace vide) et ses métadonnées.
class SiteMediaHelper {
  static const String heroBannerAsset =
      'assets/images/casamance/carabane_bolong.jpg';
  static const String splashRiverAsset =
      'assets/images/casamance/pirogue_fleuve.jpg';
  static const String heritageFooterAsset =
      'assets/images/casamance/bras_de_mer.jpg';
  static const String artisanatAsset =
      'assets/images/casamance/artisanat_senegal_real.jpg';
  static const String beachCapSkirringAsset =
      'assets/images/casamance/plage_cap_skirring.jpg';
  static const String beachCarabaneAsset =
      'assets/images/casamance/plage_carabane.jpg';
  static const String gastronomieAsset =
      'assets/images/casamance/gastronomie_casamance.jpg';
  static const String cultureAsset =
      'assets/images/casamance/culture_casamance.jpg';

  /// Retourne le chemin d'asset local authentique principal pour un site donné
  static String primaryAssetForSite(Patrimoine site) {
    final nom = site.nom.toLowerCase();
    if (nom.contains('carabane')) {
      return beachCarabaneAsset;
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
    if (nom.contains('artisan')) {
      return artisanatAsset;
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
    if (nom.contains('plage') || nom.contains('cap skirring')) {
      return beachCapSkirringAsset;
    }

    switch (site.categorie.toUpperCase()) {
      case 'NATURE':
        return 'assets/images/casamance/foret_casamance.jpg';
      case 'ARCHITECTURE':
        return 'assets/images/casamance/cases_mlomp.jpg';
      case 'MUSEE':
        return 'assets/images/casamance/memorial_joola.jpg';
      case 'CULTURE':
        return cultureAsset;
      case 'ARTISANAT':
        return artisanatAsset;
      case 'PLAGES':
        return beachCapSkirringAsset;
      default:
        return 'assets/images/casamance/bras_de_mer.jpg';
    }
  }

  /// Retourne une galerie riche de photos authentiques propres à chaque site
  static List<String> galleryAssetsForSite(Patrimoine site) {
    final primary = primaryAssetForSite(site);
    final nom = site.nom.toLowerCase();

    if (nom.contains('carabane')) {
      return [
        primary,
        'assets/images/casamance/carabane_bolong.jpg',
        beachCapSkirringAsset,
        'assets/images/casamance/pirogue_fleuve.jpg',
      ];
    }
    if (nom.contains('artisan')) {
      return [
        primary,
        cultureAsset,
        'assets/images/casamance/alliance_francaise.jpg',
      ];
    }
    if (nom.contains('impluvium') || nom.contains('mlomp')) {
      return [
        primary,
        cultureAsset,
        'assets/images/casamance/foret_casamance.jpg',
      ];
    }
    if (nom.contains('boudody') || nom.contains('port')) {
      return [
        primary,
        gastronomieAsset,
        'assets/images/casamance/pirogue_fleuve.jpg',
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
        cultureAsset,
        'assets/images/casamance/cathedrale_ziguinchor.jpg',
      ];
    }
    return [
      primary,
      'assets/images/casamance/bolong_mangrove.jpg',
      'assets/images/casamance/pirogue_fleuve.jpg',
    ];
  }

  /// Indique si un site correspond à l'une des catégories éditoriales de la page Explorer
  static bool matchesExplorerTheme(Patrimoine site, String themeCode) {
    final nom = site.nom.toLowerCase();
    final desc = site.description.toLowerCase();
    final cat = site.categorie.toUpperCase();

    switch (themeCode.toUpperCase()) {
      case 'TOUS':
        return true;
      case 'NATURE':
        return cat == 'NATURE' ||
            nom.contains('bolong') ||
            nom.contains('carabane') ||
            nom.contains('port');
      case 'CULTURE':
        return cat == 'CULTURE' ||
            cat == 'ARTISANAT' ||
            nom.contains('alliance') ||
            nom.contains('mlomp');
      case 'PLAGES':
        return cat == 'PLAGES' ||
            nom.contains('carabane') ||
            nom.contains('bolong') ||
            desc.contains('plage');
      case 'ARTISANAT':
        return cat == 'ARTISANAT' ||
            cat == 'ARCHITECTURE' ||
            nom.contains('artisan') ||
            nom.contains('mlomp');
      case 'PATRIMOINE':
        return cat == 'MONUMENT' ||
            cat == 'MUSEE' ||
            cat == 'ARCHITECTURE' ||
            nom.contains('cathédrale') ||
            nom.contains('joola') ||
            nom.contains('carabane');
      case 'GASTRONOMIE':
        return nom.contains('port') ||
            nom.contains('boudody') ||
            nom.contains('carabane') ||
            nom.contains('bolong');
      default:
        return cat == themeCode.toUpperCase();
    }
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

  /// Libellé éditorial des catégories
  static String labelCategorie(String categorie) {
    switch (categorie.toUpperCase()) {
      case 'MONUMENT':
        return 'Patrimoine';
      case 'NATURE':
        return 'Nature';
      case 'MUSEE':
        return 'Mémoire & Musée';
      case 'ARCHITECTURE':
        return 'Architecture';
      case 'CULTURE':
        return 'Culture';
      case 'ARTISANAT':
        return 'Artisanat';
      case 'PLAGES':
        return 'Plages';
      case 'GASTRONOMIE':
        return 'Gastronomie';
      default:
        return 'Découverte';
    }
  }
}
