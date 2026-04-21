class EnqueteMembre {
  final String id;
  final String codeCooperative;
  final String idMembre;
  final String genre;
  
  // Gouvernance (20%)
  final int decisionsDemo;
  final int agRegulieres;
  final int transparenceFinanciere;
  final int statutsAppliques;
  final int mandatsRespectes;
  
  // Performance économique (25%)
  final int productionAugmentee;
  final int revenusAmeliores;
  final int accesMarche;
  final int qualiteNormes;
  final int coutsMaitrises;
  
  // Gestion financière (25%)
  final int comptaAJour;
  final int cotisationsCollectees;
  final int accesCredit;
  final int excedentsEquitables;
  final int budgetRespecte;
  
  // Actifs productifs (15%)
  final int equipementsOK;
  final int infrastructuresAdaptees;
  final int renouvellementPlanifie;
  final int accesIntrants;
  final int maintenanceReguliere;
  
  // Résilience (15%)
  final int risquesClimatiques;
  final int formationReguliere;
  final int diversification;
  final int epargneCollective;
  final int releveJeunes;
  
  double? scoreGovernance;
  double? scorePerformance;
  double? scoreFinance;
  double? scoreActifs;
  double? scoreResilience;
  double? scoreGlobal;

  EnqueteMembre({
    required this.id,
    required this.codeCooperative,
    required this.idMembre,
    required this.genre,
    required this.decisionsDemo,
    required this.agRegulieres,
    required this.transparenceFinanciere,
    required this.statutsAppliques,
    required this.mandatsRespectes,
    required this.productionAugmentee,
    required this.revenusAmeliores,
    required this.accesMarche,
    required this.qualiteNormes,
    required this.coutsMaitrises,
    required this.comptaAJour,
    required this.cotisationsCollectees,
    required this.accesCredit,
    required this.excedentsEquitables,
    required this.budgetRespecte,
    required this.equipementsOK,
    required this.infrastructuresAdaptees,
    required this.renouvellementPlanifie,
    required this.accesIntrants,
    required this.maintenanceReguliere,
    required this.risquesClimatiques,
    required this.formationReguliere,
    required this.diversification,
    required this.epargneCollective,
    required this.releveJeunes,
    this.scoreGovernance,
    this.scorePerformance,
    this.scoreFinance,
    this.scoreActifs,
    this.scoreResilience,
    this.scoreGlobal,
  });

  void calculerScores() {
    // Calcul des scores normalisés (0-100)
    scoreGovernance = ((decisionsDemo + agRegulieres + transparenceFinanciere + statutsAppliques + mandatsRespectes) / 25.0) * 100;
    scorePerformance = ((productionAugmentee + revenusAmeliores + accesMarche + qualiteNormes + coutsMaitrises) / 25.0) * 100;
    scoreFinance = ((comptaAJour + cotisationsCollectees + accesCredit + excedentsEquitables + budgetRespecte) / 25.0) * 100;
    scoreActifs = ((equipementsOK + infrastructuresAdaptees + renouvellementPlanifie + accesIntrants + maintenanceReguliere) / 25.0) * 100;
    scoreResilience = ((risquesClimatiques + formationReguliere + diversification + epargneCollective + releveJeunes) / 25.0) * 100;
    
    // Score global pondéré
    scoreGlobal = (scoreGovernance! * 0.20) + 
                  (scorePerformance! * 0.25) + 
                  (scoreFinance! * 0.25) + 
                  (scoreActifs! * 0.15) + 
                  (scoreResilience! * 0.15);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code_cooperative': codeCooperative,
      'id_membre': idMembre,
      'genre': genre,
      'decisions_demo': decisionsDemo,
      'ag_regulieres': agRegulieres,
      'transparence_financiere': transparenceFinanciere,
      'statuts_appliques': statutsAppliques,
      'mandats_respectes': mandatsRespectes,
      'production_augmentee': productionAugmentee,
      'revenus_ameliores': revenusAmeliores,
      'acces_marche': accesMarche,
      'qualite_normes': qualiteNormes,
      'couts_maitrises': coutsMaitrises,
      'compta_a_jour': comptaAJour,
      'cotisations_collectees': cotisationsCollectees,
      'acces_credit': accesCredit,
      'excedents_equitables': excedentsEquitables,
      'budget_respecte': budgetRespecte,
      'equipements_ok': equipementsOK,
      'infrastructures_adaptees': infrastructuresAdaptees,
      'renouvellement_planifie': renouvellementPlanifie,
      'acces_intrants': accesIntrants,
      'maintenance_reguliere': maintenanceReguliere,
      'risques_climatiques': risquesClimatiques,
      'formation_reguliere': formationReguliere,
      'diversification': diversification,
      'epargne_collective': epargneCollective,
      'releve_jeunes': releveJeunes,
      'score_governance': scoreGovernance,
      'score_performance': scorePerformance,
      'score_finance': scoreFinance,
      'score_actifs': scoreActifs,
      'score_resilience': scoreResilience,
      'score_global': scoreGlobal,
    };
  }

  factory EnqueteMembre.fromJson(Map<String, dynamic> json) {
    return EnqueteMembre(
      id: json['id'] as String,
      codeCooperative: json['code_cooperative'] as String,
      idMembre: json['id_membre'] as String,
      genre: json['genre'] as String,
      decisionsDemo: json['decisions_demo'] as int,
      agRegulieres: json['ag_regulieres'] as int,
      transparenceFinanciere: json['transparence_financiere'] as int,
      statutsAppliques: json['statuts_appliques'] as int,
      mandatsRespectes: json['mandats_respectes'] as int,
      productionAugmentee: json['production_augmentee'] as int,
      revenusAmeliores: json['revenus_ameliores'] as int,
      accesMarche: json['acces_marche'] as int,
      qualiteNormes: json['qualite_normes'] as int,
      coutsMaitrises: json['couts_maitrises'] as int,
      comptaAJour: json['compta_a_jour'] as int,
      cotisationsCollectees: json['cotisations_collectees'] as int,
      accesCredit: json['acces_credit'] as int,
      excedentsEquitables: json['excedents_equitables'] as int,
      budgetRespecte: json['budget_respecte'] as int,
      equipementsOK: json['equipements_ok'] as int,
      infrastructuresAdaptees: json['infrastructures_adaptees'] as int,
      renouvellementPlanifie: json['renouvellement_planifie'] as int,
      accesIntrants: json['acces_intrants'] as int,
      maintenanceReguliere: json['maintenance_reguliere'] as int,
      risquesClimatiques: json['risques_climatiques'] as int,
      formationReguliere: json['formation_reguliere'] as int,
      diversification: json['diversification'] as int,
      epargneCollective: json['epargne_collective'] as int,
      releveJeunes: json['releve_jeunes'] as int,
      scoreGovernance: json['score_governance'] != null ? (json['score_governance'] as num).toDouble() : null,
      scorePerformance: json['score_performance'] != null ? (json['score_performance'] as num).toDouble() : null,
      scoreFinance: json['score_finance'] != null ? (json['score_finance'] as num).toDouble() : null,
      scoreActifs: json['score_actifs'] != null ? (json['score_actifs'] as num).toDouble() : null,
      scoreResilience: json['score_resilience'] != null ? (json['score_resilience'] as num).toDouble() : null,
      scoreGlobal: json['score_global'] != null ? (json['score_global'] as num).toDouble() : null,
    );
  }
}
