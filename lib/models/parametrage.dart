class Parametrage {
  final String nomProjet;
  final String pays;
  final String region;
  final int anneeAnalyse;
  final String organisationResponsable;
  
  // Pondération des dimensions
  final double poidsGovernance;
  final double poidsPerformance;
  final double poidsFinance;
  final double poidsActifs;
  final double poidsResilience;
  
  // Paramètres d'échantillonnage
  final double tauxEchantillonnage;
  final int tailleMinimale;
  final int tailleMaximale;
  final double quotaHommes;
  final double quotaFemmes;

  Parametrage({
    required this.nomProjet,
    required this.pays,
    required this.region,
    required this.anneeAnalyse,
    required this.organisationResponsable,
    this.poidsGovernance = 0.20,
    this.poidsPerformance = 0.25,
    this.poidsFinance = 0.25,
    this.poidsActifs = 0.15,
    this.poidsResilience = 0.15,
    this.tauxEchantillonnage = 0.20,
    this.tailleMinimale = 5,
    this.tailleMaximale = 50,
    this.quotaHommes = 0.50,
    this.quotaFemmes = 0.50,
  });

  Map<String, dynamic> toJson() => {
        'nom_projet': nomProjet,
        'pays': pays,
        'region': region,
        'annee_analyse': anneeAnalyse,
        'organisation_responsable': organisationResponsable,
        'poids_governance': poidsGovernance,
        'poids_performance': poidsPerformance,
        'poids_finance': poidsFinance,
        'poids_actifs': poidsActifs,
        'poids_resilience': poidsResilience,
        'taux_echantillonnage': tauxEchantillonnage,
        'taille_minimale': tailleMinimale,
        'taille_maximale': tailleMaximale,
        'quota_hommes': quotaHommes,
        'quota_femmes': quotaFemmes,
      };

  factory Parametrage.fromJson(Map<String, dynamic> json) => Parametrage(
        nomProjet: json['nom_projet'] as String,
        pays: json['pays'] as String,
        region: json['region'] as String,
        anneeAnalyse: json['annee_analyse'] as int,
        organisationResponsable: json['organisation_responsable'] as String,
        poidsGovernance: (json['poids_governance'] as num?)?.toDouble() ?? 0.20,
        poidsPerformance: (json['poids_performance'] as num?)?.toDouble() ?? 0.25,
        poidsFinance: (json['poids_finance'] as num?)?.toDouble() ?? 0.25,
        poidsActifs: (json['poids_actifs'] as num?)?.toDouble() ?? 0.15,
        poidsResilience: (json['poids_resilience'] as num?)?.toDouble() ?? 0.15,
        tauxEchantillonnage: (json['taux_echantillonnage'] as num?)?.toDouble() ?? 0.20,
        tailleMinimale: json['taille_minimale'] as int? ?? 5,
        tailleMaximale: json['taille_maximale'] as int? ?? 50,
        quotaHommes: (json['quota_hommes'] as num?)?.toDouble() ?? 0.50,
        quotaFemmes: (json['quota_femmes'] as num?)?.toDouble() ?? 0.50,
      );

  static Parametrage parDefaut() => Parametrage(
        nomProjet: 'Diagnostic Coopératives 2026',
        pays: 'République Démocratique du Congo',
        region: 'Kivu',
        anneeAnalyse: 2026,
        organisationResponsable: 'ONG Partenaire',
      );
}
