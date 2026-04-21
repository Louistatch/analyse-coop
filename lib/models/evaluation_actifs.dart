class EvaluationActifs {
  String id;
  String cooperativeId;
  DateTime dateEvaluation;

  // Actifs immobilisés
  double terrains;
  double batiments;
  double equipements;
  double materielRoulant;
  double mobilier;

  // Actifs circulants
  double stocksMatieresPremiere;
  double stocksProduitsFinis;
  double creancesClients;
  double disponibilites;
  double autresActifsCirculants;

  // Notes et observations
  String? notes;

  EvaluationActifs({
    required this.id,
    required this.cooperativeId,
    required this.dateEvaluation,
    this.terrains = 0,
    this.batiments = 0,
    this.equipements = 0,
    this.materielRoulant = 0,
    this.mobilier = 0,
    this.stocksMatieresPremiere = 0,
    this.stocksProduitsFinis = 0,
    this.creancesClients = 0,
    this.disponibilites = 0,
    this.autresActifsCirculants = 0,
    this.notes,
  });

  // Calculs automatiques
  double get totalActifsImmobilises {
    return terrains + batiments + equipements + materielRoulant + mobilier;
  }

  double get totalActifsCirculants {
    return stocksMatieresPremiere +
        stocksProduitsFinis +
        creancesClients +
        disponibilites +
        autresActifsCirculants;
  }

  double get totalActifs {
    return totalActifsImmobilises + totalActifsCirculants;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cooperativeId': cooperativeId,
      'dateEvaluation': dateEvaluation.toIso8601String(),
      'terrains': terrains,
      'batiments': batiments,
      'equipements': equipements,
      'materielRoulant': materielRoulant,
      'mobilier': mobilier,
      'stocksMatieresPremiere': stocksMatieresPremiere,
      'stocksProduitsFinis': stocksProduitsFinis,
      'creancesClients': creancesClients,
      'disponibilites': disponibilites,
      'autresActifsCirculants': autresActifsCirculants,
      'totalActifsImmobilises': totalActifsImmobilises,
      'totalActifsCirculants': totalActifsCirculants,
      'totalActifs': totalActifs,
      'notes': notes,
    };
  }

  factory EvaluationActifs.fromMap(Map<String, dynamic> map) {
    return EvaluationActifs(
      id: map['id'] ?? '',
      cooperativeId: map['cooperativeId'] ?? '',
      dateEvaluation: map['dateEvaluation'] is DateTime
          ? map['dateEvaluation']
          : DateTime.parse(map['dateEvaluation']),
      terrains: (map['terrains'] ?? 0).toDouble(),
      batiments: (map['batiments'] ?? 0).toDouble(),
      equipements: (map['equipements'] ?? 0).toDouble(),
      materielRoulant: (map['materielRoulant'] ?? 0).toDouble(),
      mobilier: (map['mobilier'] ?? 0).toDouble(),
      stocksMatieresPremiere: (map['stocksMatieresPremiere'] ?? 0).toDouble(),
      stocksProduitsFinis: (map['stocksProduitsFinis'] ?? 0).toDouble(),
      creancesClients: (map['creancesClients'] ?? 0).toDouble(),
      disponibilites: (map['disponibilites'] ?? 0).toDouble(),
      autresActifsCirculants: (map['autresActifsCirculants'] ?? 0).toDouble(),
      notes: map['notes'],
    );
  }
}
