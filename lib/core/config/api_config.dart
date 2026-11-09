import '../models/patrimoine.dart';
import '../models/utilisateur.dart';

class ApiConfig {
  /// URL de base du microservice Spring Boot (ms-patrimoine)
  /// Sur émulateur Android : 10.0.2.2 pointe vers le localhost du PC
  static const String baseUrl = 'http://10.0.2.2:8081/api';

  /// Sites touristiques de Ziguinchor & Casamance (Données de démonstration / Fallback)
  static const List<Patrimoine> sitesCasamance = [
    Patrimoine(
      id: 1,
      nom: 'Île Historique de Carabane',
      description: 'Ancien comptoir colonial situé à l\'embouchure du fleuve Casamance, célèbre pour son église bretonne et ses plages de cocotiers.',
      historique: 'Premier comptoir français en Casamance fondé en 1836, témoin majeur de l\'histoire maritime et coloniale du sud du Sénégal.',
      categorie: 'MONUMENT',
      localisation: 'Embouchure du Fleuve Casamance, Oussouye',
      latitude: 12.5567,
      longitude: -16.7025,
      tarifEntree: 3000,
      horairesOuverture: '08h00 - 18h00',
      imageUrl: 'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800',
      noteMoyenne: 4.9,
    ),
    Patrimoine(
      id: 2,
      nom: 'Cases à Impluvium d\'Enampore & Mlomp',
      description: 'Chefs-d\'œuvre de l\'architecture traditionnelle Diola en banco avec toit en entonnoir recueillant l\'eau de pluie.',
      historique: 'Classées au patrimoine national et inscrites sur la liste indicative de l\'UNESCO, ces habitations communautaires témoignent du génie écologique Diola.',
      categorie: 'ARCHITECTURE',
      localisation: 'Enampore / Mlomp (30 km de Ziguinchor)',
      latitude: 12.5614,
      longitude: -16.5831,
      tarifEntree: 2000,
      horairesOuverture: '08h30 - 17h30',
      imageUrl: 'https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?w=800',
      noteMoyenne: 4.8,
    ),
    Patrimoine(
      id: 3,
      nom: 'Mémorial Le Joola de Ziguinchor',
      description: 'Monument solennel et musée érigé au bord du fleuve Casamance en mémoire des victimes du naufrage du 26 septembre 2002.',
      historique: 'Inauguré à Ziguinchor, ce lieu de mémoire et d\'histoire retrace la tragédie maritime et rend hommage aux familles casamançaises.',
      categorie: 'MUSEE',
      localisation: 'Quai du Port de Ziguinchor, Escale',
      latitude: 12.5872,
      longitude: -16.2735,
      tarifEntree: 1500,
      horairesOuverture: '09h00 - 17h00',
      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
      noteMoyenne: 4.9,
    ),
    Patrimoine(
      id: 4,
      nom: 'Cathédrale Saint-Antoine de Padoue',
      description: 'Édifice religieux emblématique au cœur du quartier Escale de Ziguinchor, mêlant architecture coloniale et art sacré local.',
      historique: 'Construite au milieu du XXe siècle, elle constitue l\'un des repères architecturaux majeurs du centre historique de Ziguinchor.',
      categorie: 'MONUMENT',
      localisation: 'Quartier Escale, Ziguinchor',
      latitude: 12.5839,
      longitude: -16.2712,
      tarifEntree: 1000,
      horairesOuverture: '08h00 - 19h00',
      imageUrl: 'https://images.unsplash.com/photo-1548625361-16800b328a79?w=800',
      noteMoyenne: 4.6,
    ),
    Patrimoine(
      id: 5,
      nom: 'Réserve Naturelle & Bolongs de Djilapao',
      description: 'Excursion en pirogue à travers la mangrove, observation des oiseaux (pélicans, flamants, hérons) et découverte de l\'île aux oiseaux.',
      historique: 'Écosystème fluvial préservé au cœur de la Basse-Casamance.',
      categorie: 'NATURE',
      localisation: 'Bolongs d\'Affiniam / Djilapao',
      latitude: 12.6345,
      longitude: -16.3412,
      tarifEntree: 5000,
      horairesOuverture: '07h30 - 17h30',
      imageUrl: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=800',
      noteMoyenne: 4.8,
    ),
  ];

  /// Guides touristiques disponibles pour les réservations
  static const List<Utilisateur> guidesDisponibles = [
    Utilisateur(
      id: 101,
      nomComplet: 'Mamadou Lamine Diedhiou',
      email: 'mamadou.guide@zigtourisme.sn',
      telephone: '+221 77 412 34 56',
      role: 'GUIDE',
      languesParlees: 'Français, Diola, Wolof, Anglais',
      tarifGuideJournalier: 10000,
    ),
    Utilisateur(
      id: 102,
      nomComplet: 'Aïssatou Badiane',
      email: 'aissatou.guide@zigtourisme.sn',
      telephone: '+221 78 523 89 10',
      role: 'GUIDE',
      languesParlees: 'Français, Anglais, Espagnol, Wolof',
      tarifGuideJournalier: 12000,
    ),
    Utilisateur(
      id: 103,
      nomComplet: 'Ousmane Sadio',
      email: 'ousmane.guide@zigtourisme.sn',
      telephone: '+221 76 310 45 99',
      role: 'GUIDE',
      languesParlees: 'Français, Diola, Créole Portugais',
      tarifGuideJournalier: 8000,
    ),
  ];
}
