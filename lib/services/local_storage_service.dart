import 'package:hive_flutter/hive_flutter.dart';
import '../models/cooperative.dart';
import '../models/enquete_membre.dart';
import '../models/parametrage.dart';
import '../models/evaluation_actifs.dart';
import '../models/evaluation_passifs.dart';

class LocalStorageService {
  static const String _cooperativesBox = 'cooperatives';
  static const String _enquetesBox = 'enquetes';
  static const String _parametrageBox = 'parametrage';
  static const String _evaluationsActifsBox = 'evaluations_actifs';
  static const String _evaluationsPassifsBox = 'evaluations_passifs';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_cooperativesBox);
    await Hive.openBox(_enquetesBox);
    await Hive.openBox(_parametrageBox);
    await Hive.openBox(_evaluationsActifsBox);
    await Hive.openBox(_evaluationsPassifsBox);
  }

  // === COOPERATIVES ===
  
  Future<void> saveCooperative(Cooperative coop) async {
    final box = Hive.box(_cooperativesBox);
    await box.put(coop.code, coop.toJson());
  }

  Future<void> saveCooperatives(List<Cooperative> coops) async {
    final box = Hive.box(_cooperativesBox);
    for (var coop in coops) {
      await box.put(coop.code, coop.toJson());
    }
  }

  Future<List<Cooperative>> getAllCooperatives() async {
    final box = Hive.box(_cooperativesBox);
    return box.values
        .map((json) => Cooperative.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  Future<Cooperative?> getCooperative(String code) async {
    final box = Hive.box(_cooperativesBox);
    final json = box.get(code);
    if (json == null) return null;
    return Cooperative.fromJson(Map<String, dynamic>.from(json as Map));
  }

  Future<void> deleteCooperative(String code) async {
    final box = Hive.box(_cooperativesBox);
    await box.delete(code);
  }

  Future<void> clearCooperatives() async {
    final box = Hive.box(_cooperativesBox);
    await box.clear();
  }

  // === ENQUETES ===
  
  Future<void> saveEnquete(EnqueteMembre enquete) async {
    final box = Hive.box(_enquetesBox);
    await box.put(enquete.id, enquete.toJson());
  }

  Future<void> saveEnquetes(List<EnqueteMembre> enquetes) async {
    final box = Hive.box(_enquetesBox);
    for (var enquete in enquetes) {
      await box.put(enquete.id, enquete.toJson());
    }
  }

  Future<List<EnqueteMembre>> getAllEnquetes() async {
    final box = Hive.box(_enquetesBox);
    return box.values
        .map((json) => EnqueteMembre.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  Future<List<EnqueteMembre>> getEnquetesByCooperative(String codeCooperative) async {
    final box = Hive.box(_enquetesBox);
    return box.values
        .map((json) => EnqueteMembre.fromJson(Map<String, dynamic>.from(json as Map)))
        .where((enquete) => enquete.codeCooperative == codeCooperative)
        .toList();
  }

  Future<void> deleteEnquete(String id) async {
    final box = Hive.box(_enquetesBox);
    await box.delete(id);
  }

  Future<void> clearEnquetes() async {
    final box = Hive.box(_enquetesBox);
    await box.clear();
  }

  // === PARAMETRAGE ===
  
  Future<void> saveParametrage(Parametrage parametrage) async {
    final box = Hive.box(_parametrageBox);
    await box.put('config', parametrage.toJson());
  }

  Future<Parametrage> getParametrage() async {
    final box = Hive.box(_parametrageBox);
    final json = box.get('config');
    if (json == null) {
      return Parametrage.parDefaut();
    }
    return Parametrage.fromJson(Map<String, dynamic>.from(json as Map));
  }

  // === STATISTIQUES ===
  
  Future<Map<String, dynamic>> getStatistics() async {
    final coops = await getAllCooperatives();
    final enquetes = await getAllEnquetes();
    
    final totalMembres = coops.fold<int>(0, (sum, coop) => sum + coop.nbMembres);
    final enquetesRealisees = enquetes.length;
    final scoresMoyens = enquetes.isNotEmpty
        ? enquetes.fold<double>(0, (sum, e) => sum + (e.scoreGlobal ?? 0)) / enquetes.length
        : 0.0;
    
    return {
      'cooperatives_enregistrees': coops.length,
      'membres_totaux': totalMembres,
      'enquetes_realisees': enquetesRealisees,
      'taux_completion': totalMembres > 0 ? enquetesRealisees / totalMembres : 0.0,
      'score_moyen_global': scoresMoyens,
    };
  }

  // === INITIALISATION AVEC DONNÉES DE DEMO ===
  
  Future<void> initializeDemoData() async {
    // Vérifier si des données existent déjà
    final coops = await getAllCooperatives();
    if (coops.isNotEmpty) return;

    // Créer des coopératives de démo
    final demoCoops = [
      Cooperative(
        code: 'COOP001',
        nom: 'Coopérative Agricole du Kivu',
        localisation: 'Goma',
        filiere: 'Café',
        nbMembres: 150,
        anneeCreation: 2015,
        statutJuridique: 'SCOOPS',
        actifTotal: 75000000,
        passifTotal: 27000000,
      ),
      Cooperative(
        code: 'COOP002',
        nom: 'Union des Producteurs de Cacao',
        localisation: 'Bukavu',
        filiere: 'Cacao',
        nbMembres: 230,
        anneeCreation: 2012,
        statutJuridique: 'SCOOPS',
        actifTotal: 108000000,
        passifTotal: 57000000,
      ),
      Cooperative(
        code: 'COOP003',
        nom: 'Coopérative Maraîchère Espoir',
        localisation: 'Uvira',
        filiere: 'Maraîchage',
        nbMembres: 85,
        anneeCreation: 2018,
        statutJuridique: 'GIE',
        actifTotal: 27000000,
        passifTotal: 13200000,
      ),
    ];

    await saveCooperatives(demoCoops);

    // Initialiser le paramétrage par défaut
    await saveParametrage(Parametrage.parDefaut());
  }

  // === EVALUATIONS ACTIFS ===
  
  Future<void> saveEvaluationActifs(EvaluationActifs evaluation) async {
    final box = Hive.box(_evaluationsActifsBox);
    await box.put(evaluation.id, evaluation.toMap());
  }

  Future<List<EvaluationActifs>> getAllEvaluationsActifs() async {
    final box = Hive.box(_evaluationsActifsBox);
    return box.values
        .map((json) => EvaluationActifs.fromMap(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  Future<List<EvaluationActifs>> getEvaluationsActifsByCooperative(String cooperativeId) async {
    final box = Hive.box(_evaluationsActifsBox);
    return box.values
        .map((json) => EvaluationActifs.fromMap(Map<String, dynamic>.from(json as Map)))
        .where((eval) => eval.cooperativeId == cooperativeId)
        .toList();
  }

  Future<void> deleteEvaluationActifs(String id) async {
    final box = Hive.box(_evaluationsActifsBox);
    await box.delete(id);
  }

  // === EVALUATIONS PASSIFS ===
  
  Future<void> saveEvaluationPassifs(EvaluationPassifs evaluation) async {
    final box = Hive.box(_evaluationsPassifsBox);
    await box.put(evaluation.id, evaluation.toMap());
  }

  Future<List<EvaluationPassifs>> getAllEvaluationsPassifs() async {
    final box = Hive.box(_evaluationsPassifsBox);
    return box.values
        .map((json) => EvaluationPassifs.fromMap(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  Future<List<EvaluationPassifs>> getEvaluationsPassifsByCooperative(String cooperativeId) async {
    final box = Hive.box(_evaluationsPassifsBox);
    return box.values
        .map((json) => EvaluationPassifs.fromMap(Map<String, dynamic>.from(json as Map)))
        .where((eval) => eval.cooperativeId == cooperativeId)
        .toList();
  }

  Future<void> deleteEvaluationPassifs(String id) async {
    final box = Hive.box(_evaluationsPassifsBox);
    await box.delete(id);
  }
}
