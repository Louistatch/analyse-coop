class EvaluationPassifs {
  String id;
  String cooperativeId;
  DateTime dateEvaluation;

  // Capitaux propres
  double capitalSocial;
  double reservesStatutaires;
  double reservesFacultatives;
  double resultatExercice;

  // Dettes à long terme
  double empruntsLongTerme;
  double autresDettesLongTerme;

  // Dettes à court terme
  double empruntsCourtTerme;
  double dettesFournisseurs;
  double dettesFiscales;
  double dettesSociales;
  double autresPassifsCirculants;

  // Notes et observations
  String? notes;

  EvaluationPassifs({
    required this.id,
    required this.cooperativeId,
    required this.dateEvaluation,
    this.capitalSocial = 0,
    this.reservesStatutaires = 0,
    this.reservesFacultatives = 0,
    this.resultatExercice = 0,
    this.empruntsLongTerme = 0,
    this.autresDettesLongTerme = 0,
    this.empruntsCourtTerme = 0,
    this.dettesFournisseurs = 0,
    this.dettesFiscales = 0,
    this.dettesSociales = 0,
    this.autresPassifsCirculants = 0,
    this.notes,
  });

  // Calculs automatiques
  double get totalCapitauxPropres {
    return capitalSocial + reservesStatutaires + reservesFacultatives + resultatExercice;
  }

  double get totalDettesLongTerme {
    return empruntsLongTerme + autresDettesLongTerme;
  }

  double get totalDettesCourtTerme {
    return empruntsCourtTerme +
        dettesFournisseurs +
        dettesFiscales +
        dettesSociales +
        autresPassifsCirculants;
  }

  double get totalPassifs {
    return totalCapitauxPropres + totalDettesLongTerme + totalDettesCourtTerme;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cooperativeId': cooperativeId,
      'dateEvaluation': dateEvaluation.toIso8601String(),
      'capitalSocial': capitalSocial,
      'reservesStatutaires': reservesStatutaires,
      'reservesFacultatives': reservesFacultatives,
      'resultatExercice': resultatExercice,
      'empruntsLongTerme': empruntsLongTerme,
      'autresDettesLongTerme': autresDettesLongTerme,
      'empruntsCourtTerme': empruntsCourtTerme,
      'dettesFournisseurs': dettesFournisseurs,
      'dettesFiscales': dettesFiscales,
      'dettesSociales': dettesSociales,
      'autresPassifsCirculants': autresPassifsCirculants,
      'totalCapitauxPropres': totalCapitauxPropres,
      'totalDettesLongTerme': totalDettesLongTerme,
      'totalDettesCourtTerme': totalDettesCourtTerme,
      'totalPassifs': totalPassifs,
      'notes': notes,
    };
  }

  factory EvaluationPassifs.fromMap(Map<String, dynamic> map) {
    return EvaluationPassifs(
      id: map['id'] ?? '',
      cooperativeId: map['cooperativeId'] ?? '',
      dateEvaluation: map['dateEvaluation'] is DateTime
          ? map['dateEvaluation']
          : DateTime.parse(map['dateEvaluation']),
      capitalSocial: (map['capitalSocial'] ?? 0).toDouble(),
      reservesStatutaires: (map['reservesStatutaires'] ?? 0).toDouble(),
      reservesFacultatives: (map['reservesFacultatives'] ?? 0).toDouble(),
      resultatExercice: (map['resultatExercice'] ?? 0).toDouble(),
      empruntsLongTerme: (map['empruntsLongTerme'] ?? 0).toDouble(),
      autresDettesLongTerme: (map['autresDettesLongTerme'] ?? 0).toDouble(),
      empruntsCourtTerme: (map['empruntsCourtTerme'] ?? 0).toDouble(),
      dettesFournisseurs: (map['dettesFournisseurs'] ?? 0).toDouble(),
      dettesFiscales: (map['dettesFiscales'] ?? 0).toDouble(),
      dettesSociales: (map['dettesSociales'] ?? 0).toDouble(),
      autresPassifsCirculants: (map['autresPassifsCirculants'] ?? 0).toDouble(),
      notes: map['notes'],
    );
  }
}
