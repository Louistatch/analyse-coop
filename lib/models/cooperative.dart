class Cooperative {
  final String code;
  final String nom;
  final String localisation;
  final String filiere;
  final int nbMembres;
  final int anneeCreation;
  final String statutJuridique;
  double actifTotal;  // Mutable pour mise à jour depuis évaluations
  double passifTotal; // Mutable pour mise à jour depuis évaluations
  double? scoreGlobal;
  String? classification;
  String? niveauRisque;

  // Setters pour actifs et passifs
  set actifs(double value) => actifTotal = value;
  set passifs(double value) => passifTotal = value;

  Cooperative({
    required this.code,
    required this.nom,
    required this.localisation,
    required this.filiere,
    required this.nbMembres,
    required this.anneeCreation,
    required this.statutJuridique,
    required this.actifTotal,
    required this.passifTotal,
    this.scoreGlobal,
    this.classification,
    this.niveauRisque,
  });

  double get ratioAP => passifTotal > 0 ? actifTotal / passifTotal : 0;
  double get actifNet => actifTotal - passifTotal;
  double get capaciteAutofinancement => actifTotal > 0 ? actifNet / actifTotal : 0;
  double get dependanceExterne => actifTotal > 0 ? passifTotal / actifTotal : 0;

  Map<String, dynamic> toJson() => {
        'code': code,
        'nom': nom,
        'localisation': localisation,
        'filiere': filiere,
        'nb_membres': nbMembres,
        'annee_creation': anneeCreation,
        'statut_juridique': statutJuridique,
        'actif_total': actifTotal,
        'passif_total': passifTotal,
        'score_global': scoreGlobal,
        'classification': classification,
        'niveau_risque': niveauRisque,
      };

  factory Cooperative.fromJson(Map<String, dynamic> json) => Cooperative(
        code: json['code'] as String,
        nom: json['nom'] as String,
        localisation: json['localisation'] as String,
        filiere: json['filiere'] as String,
        nbMembres: json['nb_membres'] as int,
        anneeCreation: json['annee_creation'] as int,
        statutJuridique: json['statut_juridique'] as String,
        actifTotal: (json['actif_total'] as num).toDouble(),
        passifTotal: (json['passif_total'] as num).toDouble(),
        scoreGlobal: json['score_global'] != null ? (json['score_global'] as num).toDouble() : null,
        classification: json['classification'] as String?,
        niveauRisque: json['niveau_risque'] as String?,
      );
}
