import 'package:flutter/foundation.dart';
import '../models/cooperative.dart';
import '../models/enquete_membre.dart';
import '../models/parametrage.dart';
import '../models/evaluation_actifs.dart';
import '../models/evaluation_passifs.dart';
import '../services/local_storage_service.dart';
import '../services/calcul_service.dart';

class AppProvider with ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  
  List<Cooperative> _cooperatives = [];
  List<EnqueteMembre> _enquetes = [];
  List<EvaluationActifs> _evaluationsActifs = [];
  List<EvaluationPassifs> _evaluationsPassifs = [];
  Parametrage? _parametrage;
  bool _isLoading = false;
  String? _error;

  List<Cooperative> get cooperatives => _cooperatives;
  List<EnqueteMembre> get enquetes => _enquetes;
  List<EvaluationActifs> get evaluationsActifs => _evaluationsActifs;
  List<EvaluationPassifs> get evaluationsPassifs => _evaluationsPassifs;
  Parametrage? get parametrage => _parametrage;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialisation
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storage.initializeDemoData();
      await loadData();
      _error = null;
    } catch (e) {
      _error = 'Erreur d\'initialisation: $e';
      if (kDebugMode) {
        debugPrint('Erreur initialisation: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger toutes les données
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _cooperatives = await _storage.getAllCooperatives();
      _enquetes = await _storage.getAllEnquetes();
      _evaluationsActifs = await _storage.getAllEvaluationsActifs();
      _evaluationsPassifs = await _storage.getAllEvaluationsPassifs();
      _parametrage = await _storage.getParametrage();
      
      // Calculer les scores pour les enquêtes
      for (var enquete in _enquetes) {
        if (enquete.scoreGlobal == null) {
          enquete.calculerScores();
        }
      }
      
      // Mettre à jour les actifs/passifs des coopératives depuis les évaluations
      await _mettreAJourActifsPassifsDesCooperatives();
      
      _error = null;
    } catch (e) {
      _error = 'Erreur de chargement: $e';
      if (kDebugMode) {
        debugPrint('Erreur chargement: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // === COOPERATIVES ===
  
  Future<void> ajouterCooperative(Cooperative coop) async {
    try {
      await _storage.saveCooperative(coop);
      _cooperatives.add(coop);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur ajout coopérative: $e';
      if (kDebugMode) {
        debugPrint('Erreur ajout coop: $e');
      }
    }
  }

  Future<void> modifierCooperative(Cooperative coop) async {
    try {
      await _storage.saveCooperative(coop);
      final index = _cooperatives.indexWhere((c) => c.code == coop.code);
      if (index != -1) {
        _cooperatives[index] = coop;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erreur modification coopérative: $e';
      if (kDebugMode) {
        debugPrint('Erreur modification coop: $e');
      }
    }
  }

  Future<void> supprimerCooperative(String code) async {
    try {
      await _storage.deleteCooperative(code);
      _cooperatives.removeWhere((c) => c.code == code);
      // Supprimer aussi les enquêtes associées
      _enquetes.removeWhere((e) => e.codeCooperative == code);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur suppression coopérative: $e';
      if (kDebugMode) {
        debugPrint('Erreur suppression coop: $e');
      }
    }
  }

  // === ENQUETES ===
  
  Future<void> ajouterEnquete(EnqueteMembre enquete) async {
    try {
      // Calculer les scores
      enquete.calculerScores();
      
      await _storage.saveEnquete(enquete);
      _enquetes.add(enquete);
      
      // Mettre à jour le score de la coopérative
      await _mettreAJourScoresCooperative(enquete.codeCooperative);
      
      notifyListeners();
    } catch (e) {
      _error = 'Erreur ajout enquête: $e';
      if (kDebugMode) {
        debugPrint('Erreur ajout enquête: $e');
      }
    }
  }

  Future<void> modifierEnquete(EnqueteMembre enquete) async {
    try {
      enquete.calculerScores();
      
      await _storage.saveEnquete(enquete);
      final index = _enquetes.indexWhere((e) => e.id == enquete.id);
      if (index != -1) {
        _enquetes[index] = enquete;
        await _mettreAJourScoresCooperative(enquete.codeCooperative);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erreur modification enquête: $e';
      if (kDebugMode) {
        debugPrint('Erreur modification enquête: $e');
      }
    }
  }

  Future<void> supprimerEnquete(String id) async {
    try {
      final enquete = _enquetes.firstWhere((e) => e.id == id);
      final codeCooperative = enquete.codeCooperative;
      
      await _storage.deleteEnquete(id);
      _enquetes.removeWhere((e) => e.id == id);
      
      await _mettreAJourScoresCooperative(codeCooperative);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur suppression enquête: $e';
      if (kDebugMode) {
        debugPrint('Erreur suppression enquête: $e');
      }
    }
  }

  List<EnqueteMembre> getEnquetesByCooperative(String codeCooperative) {
    return _enquetes.where((e) => e.codeCooperative == codeCooperative).toList();
  }

  // Mettre à jour les scores et classification d'une coopérative
  Future<void> _mettreAJourScoresCooperative(String codeCooperative) async {
    final enquetesCooperative = getEnquetesByCooperative(codeCooperative);
    final cooperative = _cooperatives.firstWhere((c) => c.code == codeCooperative);
    
    if (enquetesCooperative.isNotEmpty) {
      final scores = CalculService.aggregerScoresCooperative(
        codeCooperative,
        enquetesCooperative,
      );
      
      cooperative.scoreGlobal = scores['score_global'] as double;
      cooperative.classification = CalculService.getClassification(
        cooperative,
        cooperative.scoreGlobal!,
      );
      cooperative.niveauRisque = CalculService.getNiveauRisque(
        cooperative.classification!,
      ).toString();
      
      await _storage.saveCooperative(cooperative);
    }
  }

  // === PARAMETRAGE ===
  
  Future<void> sauvegarderParametrage(Parametrage parametrage) async {
    try {
      await _storage.saveParametrage(parametrage);
      _parametrage = parametrage;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur sauvegarde paramétrage: $e';
      if (kDebugMode) {
        debugPrint('Erreur sauvegarde paramétrage: $e');
      }
    }
  }

  // === STATISTIQUES ===
  
  Future<Map<String, dynamic>> getStatistiques() async {
    return await _storage.getStatistics();
  }

  // Obtenir les diagnostics complets
  List<Map<String, dynamic>> getDiagnosticsComplets() {
    return _cooperatives.map((coop) {
      final enquetesCooperative = getEnquetesByCooperative(coop.code);
      final scores = CalculService.aggregerScoresCooperative(
        coop.code,
        enquetesCooperative,
      );
      
      final classification = coop.classification ?? 
          CalculService.getClassification(coop, scores['score_global'] as double);
      
      final recommendations = CalculService.genererRecommandations(
        scores['score_governance'] as double,
        scores['score_performance'] as double,
        scores['score_finance'] as double,
        scores['score_actifs'] as double,
        scores['score_resilience'] as double,
        classification,
      );
      
      return {
        'cooperative': coop,
        'scores': scores,
        'classification': classification,
        'recommandations': recommendations,
      };
    }).toList();
  }

  // Classement des coopératives
  List<Map<String, dynamic>> getClassement() {
    final diagnostics = getDiagnosticsComplets();
    
    // Trier par score global décroissant
    diagnostics.sort((a, b) {
      final scoreA = (a['scores'] as Map<String, dynamic>)['score_global'] as double;
      final scoreB = (b['scores'] as Map<String, dynamic>)['score_global'] as double;
      return scoreB.compareTo(scoreA);
    });
    
    // Ajouter le rang
    for (int i = 0; i < diagnostics.length; i++) {
      diagnostics[i]['rang'] = i + 1;
    }
    
    return diagnostics;
  }

  // === EVALUATIONS ACTIFS ===
  
  Future<void> ajouterEvaluationActifs(EvaluationActifs evaluation) async {
    try {
      await _storage.saveEvaluationActifs(evaluation);
      _evaluationsActifs.add(evaluation);
      
      // Mettre à jour la coopérative
      await _mettreAJourActifsCooperative(evaluation.cooperativeId);
      
      notifyListeners();
    } catch (e) {
      _error = 'Erreur ajout évaluation actifs: $e';
      if (kDebugMode) {
        debugPrint('Erreur ajout évaluation actifs: $e');
      }
    }
  }

  Future<void> modifierEvaluationActifs(EvaluationActifs evaluation) async {
    try {
      await _storage.saveEvaluationActifs(evaluation);
      final index = _evaluationsActifs.indexWhere((e) => e.id == evaluation.id);
      if (index != -1) {
        _evaluationsActifs[index] = evaluation;
        await _mettreAJourActifsCooperative(evaluation.cooperativeId);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erreur modification évaluation actifs: $e';
      if (kDebugMode) {
        debugPrint('Erreur modification évaluation actifs: $e');
      }
    }
  }

  Future<void> supprimerEvaluationActifs(String id) async {
    try {
      final evaluation = _evaluationsActifs.firstWhere((e) => e.id == id);
      final cooperativeId = evaluation.cooperativeId;
      
      await _storage.deleteEvaluationActifs(id);
      _evaluationsActifs.removeWhere((e) => e.id == id);
      
      await _mettreAJourActifsCooperative(cooperativeId);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur suppression évaluation actifs: $e';
      if (kDebugMode) {
        debugPrint('Erreur suppression évaluation actifs: $e');
      }
    }
  }

  List<EvaluationActifs> getEvaluationsActifsByCooperative(String cooperativeId) {
    return _evaluationsActifs.where((e) => e.cooperativeId == cooperativeId).toList();
  }

  // === EVALUATIONS PASSIFS ===
  
  Future<void> ajouterEvaluationPassifs(EvaluationPassifs evaluation) async {
    try {
      await _storage.saveEvaluationPassifs(evaluation);
      _evaluationsPassifs.add(evaluation);
      
      // Mettre à jour la coopérative
      await _mettreAJourPassifsCooperative(evaluation.cooperativeId);
      
      notifyListeners();
    } catch (e) {
      _error = 'Erreur ajout évaluation passifs: $e';
      if (kDebugMode) {
        debugPrint('Erreur ajout évaluation passifs: $e');
      }
    }
  }

  Future<void> modifierEvaluationPassifs(EvaluationPassifs evaluation) async {
    try {
      await _storage.saveEvaluationPassifs(evaluation);
      final index = _evaluationsPassifs.indexWhere((e) => e.id == evaluation.id);
      if (index != -1) {
        _evaluationsPassifs[index] = evaluation;
        await _mettreAJourPassifsCooperative(evaluation.cooperativeId);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erreur modification évaluation passifs: $e';
      if (kDebugMode) {
        debugPrint('Erreur modification évaluation passifs: $e');
      }
    }
  }

  Future<void> supprimerEvaluationPassifs(String id) async {
    try {
      final evaluation = _evaluationsPassifs.firstWhere((e) => e.id == id);
      final cooperativeId = evaluation.cooperativeId;
      
      await _storage.deleteEvaluationPassifs(id);
      _evaluationsPassifs.removeWhere((e) => e.id == id);
      
      await _mettreAJourPassifsCooperative(cooperativeId);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur suppression évaluation passifs: $e';
      if (kDebugMode) {
        debugPrint('Erreur suppression évaluation passifs: $e');
      }
    }
  }

  List<EvaluationPassifs> getEvaluationsPassifsByCooperative(String cooperativeId) {
    return _evaluationsPassifs.where((e) => e.cooperativeId == cooperativeId).toList();
  }

  // Mettre à jour les actifs d'une coopérative
  Future<void> _mettreAJourActifsCooperative(String cooperativeId) async {
    final evaluations = getEvaluationsActifsByCooperative(cooperativeId);
    final cooperative = _cooperatives.firstWhere((c) => c.code == cooperativeId);
    
    if (evaluations.isNotEmpty) {
      // Prendre la dernière évaluation
      evaluations.sort((a, b) => b.dateEvaluation.compareTo(a.dateEvaluation));
      final derniere = evaluations.first;
      
      cooperative.actifs = derniere.totalActifs;
      await _storage.saveCooperative(cooperative);
    } else {
      cooperative.actifs = 0;
      await _storage.saveCooperative(cooperative);
    }
  }

  // Mettre à jour les passifs d'une coopérative
  Future<void> _mettreAJourPassifsCooperative(String cooperativeId) async {
    final evaluations = getEvaluationsPassifsByCooperative(cooperativeId);
    final cooperative = _cooperatives.firstWhere((c) => c.code == cooperativeId);
    
    if (evaluations.isNotEmpty) {
      // Prendre la dernière évaluation
      evaluations.sort((a, b) => b.dateEvaluation.compareTo(a.dateEvaluation));
      final derniere = evaluations.first;
      
      cooperative.passifs = derniere.totalPassifs;
      await _storage.saveCooperative(cooperative);
    } else {
      cooperative.passifs = 0;
      await _storage.saveCooperative(cooperative);
    }
  }

  // Mettre à jour tous les actifs/passifs depuis les évaluations
  Future<void> _mettreAJourActifsPassifsDesCooperatives() async {
    for (var coop in _cooperatives) {
      await _mettreAJourActifsCooperative(coop.code);
      await _mettreAJourPassifsCooperative(coop.code);
    }
  }
}
