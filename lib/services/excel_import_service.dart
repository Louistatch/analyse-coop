import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../models/cooperative.dart';
import '../models/enquete_membre.dart';

class ExcelImportService {
  // Importer des coopératives depuis Excel
  static Future<List<Cooperative>?> importCooperatives() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return null;

      final bytes = result.files.first.bytes;
      if (bytes == null) return null;

      final excel = Excel.decodeBytes(bytes);
      final cooperatives = <Cooperative>[];

      // Chercher la feuille "2-Base_Cooperatives" ou la première feuille
      Sheet? sheet;
      if (excel.tables.containsKey('2-Base_Cooperatives')) {
        sheet = excel.tables['2-Base_Cooperatives'];
      } else if (excel.tables.containsKey('Base_Cooperatives')) {
        sheet = excel.tables['Base_Cooperatives'];
      } else {
        sheet = excel.tables.values.first;
      }

      if (sheet == null) return null;

      // Trouver la ligne d'en-tête
      int headerRow = -1;
      for (int i = 0; i < sheet.maxRows; i++) {
        final row = sheet.rows[i];
        if (row.any((cell) => 
            cell?.value?.toString().toLowerCase().contains('code') ?? false)) {
          headerRow = i;
          break;
        }
      }

      if (headerRow == -1) return null;

      // Lire les données
      for (int i = headerRow + 1; i < sheet.maxRows; i++) {
        final row = sheet.rows[i];
        
        // Vérifier si la ligne n'est pas vide
        if (row.every((cell) => cell?.value == null)) continue;

        try {
          // Extraire les valeurs (adapter les indices selon votre structure Excel)
          final code = _getCellValue(row, 1)?.toString() ?? '';
          final nom = _getCellValue(row, 2)?.toString() ?? '';
          final localisation = _getCellValue(row, 3)?.toString() ?? '';
          final filiere = _getCellValue(row, 4)?.toString() ?? '';
          final nbMembres = _parseIntValue(row, 5) ?? 0;
          final anneeCreation = _parseIntValue(row, 6) ?? 2020;
          final statutJuridique = _getCellValue(row, 7)?.toString() ?? 'SCOOPS';
          final actifTotal = _parseDoubleValue(row, 8) ?? 0.0;
          final passifTotal = _parseDoubleValue(row, 9) ?? 0.0;

          if (code.isNotEmpty && nom.isNotEmpty) {
            cooperatives.add(Cooperative(
              code: code,
              nom: nom,
              localisation: localisation,
              filiere: filiere,
              nbMembres: nbMembres,
              anneeCreation: anneeCreation,
              statutJuridique: statutJuridique,
              actifTotal: actifTotal,
              passifTotal: passifTotal,
            ));
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Erreur ligne $i: $e');
          }
          continue;
        }
      }

      return cooperatives;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erreur import coopératives: $e');
      }
      return null;
    }
  }

  // Importer des enquêtes depuis Excel
  static Future<List<EnqueteMembre>?> importEnquetes() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return null;

      final bytes = result.files.first.bytes;
      if (bytes == null) return null;

      final excel = Excel.decodeBytes(bytes);
      final enquetes = <EnqueteMembre>[];

      // Chercher la feuille "4-Saisie_Enquete"
      Sheet? sheet;
      if (excel.tables.containsKey('4-Saisie_Enquete')) {
        sheet = excel.tables['4-Saisie_Enquete'];
      } else if (excel.tables.containsKey('Saisie_Enquete')) {
        sheet = excel.tables['Saisie_Enquete'];
      } else {
        sheet = excel.tables.values.first;
      }

      if (sheet == null) return null;

      // Trouver la ligne d'en-tête (chercher "Code Coop")
      int headerRow = -1;
      for (int i = 0; i < sheet.maxRows; i++) {
        final row = sheet.rows[i];
        if (row.any((cell) => 
            cell?.value?.toString().toLowerCase().contains('code coop') ?? false)) {
          headerRow = i;
          break;
        }
      }

      if (headerRow == -1) return null;

      // Lire les données
      for (int i = headerRow + 1; i < sheet.maxRows; i++) {
        final row = sheet.rows[i];
        
        // Vérifier si la ligne n'est pas vide
        if (row.every((cell) => cell?.value == null)) continue;

        try {
          final codeCooperative = _getCellValue(row, 2)?.toString() ?? '';
          final idMembre = _getCellValue(row, 3)?.toString() ?? '';
          final genre = _getCellValue(row, 4)?.toString() ?? 'H';

          if (codeCooperative.isEmpty || idMembre.isEmpty) continue;

          // Lire les 25 réponses (colonnes 5 à 29)
          final enquete = EnqueteMembre(
            id: '${codeCooperative}_${idMembre}_${DateTime.now().millisecondsSinceEpoch}',
            codeCooperative: codeCooperative,
            idMembre: idMembre,
            genre: genre.toUpperCase().startsWith('H') ? 'H' : 'F',
            
            // Gouvernance (5 questions)
            decisionsDemo: _parseIntValue(row, 5) ?? 3,
            agRegulieres: _parseIntValue(row, 6) ?? 3,
            transparenceFinanciere: _parseIntValue(row, 7) ?? 3,
            statutsAppliques: _parseIntValue(row, 8) ?? 3,
            mandatsRespectes: _parseIntValue(row, 9) ?? 3,
            
            // Performance économique (5 questions)
            productionAugmentee: _parseIntValue(row, 10) ?? 3,
            revenusAmeliores: _parseIntValue(row, 11) ?? 3,
            accesMarche: _parseIntValue(row, 12) ?? 3,
            qualiteNormes: _parseIntValue(row, 13) ?? 3,
            coutsMaitrises: _parseIntValue(row, 14) ?? 3,
            
            // Gestion financière (5 questions)
            comptaAJour: _parseIntValue(row, 15) ?? 3,
            cotisationsCollectees: _parseIntValue(row, 16) ?? 3,
            accesCredit: _parseIntValue(row, 17) ?? 3,
            excedentsEquitables: _parseIntValue(row, 18) ?? 3,
            budgetRespecte: _parseIntValue(row, 19) ?? 3,
            
            // Actifs productifs (5 questions)
            equipementsOK: _parseIntValue(row, 20) ?? 3,
            infrastructuresAdaptees: _parseIntValue(row, 21) ?? 3,
            renouvellementPlanifie: _parseIntValue(row, 22) ?? 3,
            accesIntrants: _parseIntValue(row, 23) ?? 3,
            maintenanceReguliere: _parseIntValue(row, 24) ?? 3,
            
            // Résilience (5 questions)
            risquesClimatiques: _parseIntValue(row, 25) ?? 3,
            formationReguliere: _parseIntValue(row, 26) ?? 3,
            diversification: _parseIntValue(row, 27) ?? 3,
            epargneCollective: _parseIntValue(row, 28) ?? 3,
            releveJeunes: _parseIntValue(row, 29) ?? 3,
          );

          // Calculer les scores
          enquete.calculerScores();
          enquetes.add(enquete);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Erreur ligne $i: $e');
          }
          continue;
        }
      }

      return enquetes;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erreur import enquêtes: $e');
      }
      return null;
    }
  }

  // Utilitaires
  static dynamic _getCellValue(List<Data?> row, int index) {
    if (index >= row.length) return null;
    return row[index]?.value;
  }

  static int? _parseIntValue(List<Data?> row, int index) {
    final value = _getCellValue(row, index);
    if (value == null) return null;
    
    if (value is int) return value;
    if (value is double) return value.toInt();
    
    final str = value.toString();
    return int.tryParse(str);
  }

  static double? _parseDoubleValue(List<Data?> row, int index) {
    final value = _getCellValue(row, index);
    if (value == null) return null;
    
    if (value is double) return value;
    if (value is int) return value.toDouble();
    
    final str = value.toString();
    return double.tryParse(str);
  }
}
