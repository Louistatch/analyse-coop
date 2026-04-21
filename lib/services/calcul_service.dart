import 'dart:math';
import '../models/cooperative.dart';
import '../models/enquete_membre.dart';

class CalculService {
  // Classification basée sur le score global et la santé financière
  static String getClassification(Cooperative coop, double scoreGlobal) {
    final capaciteAuto = coop.capaciteAutofinancement;
    final ratioAP = coop.ratioAP;
    
    if (scoreGlobal >= 80 && capaciteAuto >= 0.5 && ratioAP >= 2.0) {
      return 'Actif financier fort';
    } else if (scoreGlobal >= 70 && capaciteAuto >= 0.4 && ratioAP >= 1.5) {
      return 'Actif financier fragile';
    } else if (scoreGlobal >= 50 && capaciteAuto >= 0.2 && ratioAP >= 1.2) {
      return 'Neutre';
    } else if (scoreGlobal >= 30) {
      return 'Passif financier';
    } else {
      return 'Critique';
    }
  }

  // Niveau de risque (1=Fort, 2=Fragile, 3=Neutre, 4=Passif, 5=Critique)
  static int getNiveauRisque(String classification) {
    switch (classification) {
      case 'Actif financier fort':
        return 1;
      case 'Actif financier fragile':
        return 2;
      case 'Neutre':
        return 3;
      case 'Passif financier':
        return 4;
      case 'Critique':
        return 5;
      default:
        return 3;
    }
  }

  // Couleur associée au niveau de risque
  static String getCouleurRisque(int niveauRisque) {
    switch (niveauRisque) {
      case 1:
        return '#00B050'; // Vert
      case 2:
        return '#FFC000'; // Orange
      case 3:
        return '#ED7D31'; // Orange foncé
      case 4:
        return '#FF0000'; // Rouge
      case 5:
        return '#C00000'; // Rouge foncé
      default:
        return '#ED7D31';
    }
  }

  // Agrégation des scores par coopérative
  static Map<String, dynamic> aggregerScoresCooperative(
    String codeCooperative,
    List<EnqueteMembre> enquetes,
  ) {
    if (enquetes.isEmpty) {
      return {
        'score_governance': 0.0,
        'score_performance': 0.0,
        'score_finance': 0.0,
        'score_actifs': 0.0,
        'score_resilience': 0.0,
        'score_global': 0.0,
        'nb_enquetes': 0,
      };
    }

    double sumGov = 0, sumPerf = 0, sumFin = 0, sumAct = 0, sumRes = 0;
    
    for (var enquete in enquetes) {
      sumGov += enquete.scoreGovernance ?? 0;
      sumPerf += enquete.scorePerformance ?? 0;
      sumFin += enquete.scoreFinance ?? 0;
      sumAct += enquete.scoreActifs ?? 0;
      sumRes += enquete.scoreResilience ?? 0;
    }

    final n = enquetes.length;
    final avgGov = sumGov / n;
    final avgPerf = sumPerf / n;
    final avgFin = sumFin / n;
    final avgAct = sumAct / n;
    final avgRes = sumRes / n;

    // Score global pondéré
    final scoreGlobal = (avgGov * 0.20) + 
                       (avgPerf * 0.25) + 
                       (avgFin * 0.25) + 
                       (avgAct * 0.15) + 
                       (avgRes * 0.15);

    return {
      'score_governance': avgGov,
      'score_performance': avgPerf,
      'score_finance': avgFin,
      'score_actifs': avgAct,
      'score_resilience': avgRes,
      'score_global': scoreGlobal,
      'nb_enquetes': n,
    };
  }

  // Génération de recommandations automatiques
  static Map<String, String> genererRecommandations(
    double scoreGov,
    double scorePerf,
    double scoreFin,
    double scoreAct,
    double scoreRes,
    String classification,
  ) {
    String recGov = scoreGov < 60
        ? 'Renforcement institutionnel: formation comité, procédures AG'
        : 'Gouvernance satisfaisante';

    String recPerf = scorePerf < 60
        ? 'Plan développement: diversification produits, accès marchés'
        : 'Performance économique OK';

    String recFin = scoreFin < 60
        ? 'Assainissement comptable: audit, plan remboursement dettes'
        : 'Gestion financière saine';

    String recAct = scoreAct < 60
        ? 'Investissement productif: renouvellement équipements, formation technique'
        : 'Actifs productifs suffisants';

    String recRes = scoreRes < 60
        ? 'Renforcement résilience: assurance, diversification, épargne'
        : 'Résilience satisfaisante';

    String priorite = 'FAIBLE';
    if (classification.contains('Critique') || classification.contains('Passif')) {
      priorite = 'ÉLEVÉE';
    } else if (classification.contains('Neutre')) {
      priorite = 'MOYENNE';
    }

    return {
      'rec_gouvernance': recGov,
      'rec_performance': recPerf,
      'rec_finance': recFin,
      'rec_actifs': recAct,
      'rec_resilience': recRes,
      'priorite_action': priorite,
    };
  }

  // Calcul de l'écart-type
  static double calculerEcartType(List<double> values) {
    if (values.isEmpty) return 0.0;
    
    final moyenne = values.reduce((a, b) => a + b) / values.length;
    final sommeCarresEcarts = values
        .map((v) => pow(v - moyenne, 2))
        .reduce((a, b) => a + b);
    
    return sqrt(sommeCarresEcarts / values.length);
  }

  // Calcul de l'échantillonnage requis
  static int calculerEchantillonRequis(
    int nbMembresTotaux,
    double tauxEchantillonnage,
    int tailleMin,
    int tailleMax,
  ) {
    int echantillon = (nbMembresTotaux * tauxEchantillonnage).round();
    
    if (echantillon < tailleMin) echantillon = tailleMin;
    if (echantillon > tailleMax) echantillon = tailleMax;
    
    return echantillon;
  }

  // Répartition hommes/femmes
  static Map<String, int> repartirGenre(int echantillonTotal, double quotaHommes) {
    final nbHommes = (echantillonTotal * quotaHommes).round();
    final nbFemmes = echantillonTotal - nbHommes;
    
    return {
      'hommes': nbHommes,
      'femmes': nbFemmes,
    };
  }
}
