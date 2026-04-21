import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/cooperative.dart';
import '../models/enquete_membre.dart';

class PdfExportService {
  // Exporter un rapport complet de diagnostic
  static Future<void> exportDiagnosticReport({
    required List<Map<String, dynamic>> diagnostics,
    required String projectName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // En-tête
          _buildHeader(projectName),
          pw.SizedBox(height: 20),
          
          // Résumé général
          _buildSummary(diagnostics),
          pw.SizedBox(height: 30),
          
          // Diagnostics par coopérative
          ...diagnostics.map((diagnostic) => 
            _buildCooperativeDiagnostic(diagnostic)
          ),
        ],
      ),
    );

    // Afficher le dialogue d'impression/sauvegarde
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Diagnostic_Cooperatives_${DateTime.now().toString().split(' ')[0]}.pdf',
    );
  }

  // Exporter le classement
  static Future<void> exportClassement({
    required List<Map<String, dynamic>> classement,
    required String projectName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(projectName),
            pw.SizedBox(height: 20),
            pw.Text(
              'CLASSEMENT DES COOPÉRATIVES',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.purple,
              ),
            ),
            pw.SizedBox(height: 20),
            _buildClassementTable(classement),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Classement_Cooperatives_${DateTime.now().toString().split(' ')[0]}.pdf',
    );
  }

  // Exporter une enquête individuelle
  static Future<void> exportEnquete({
    required EnqueteMembre enquete,
    required String cooperativeName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Text(
            'FICHE D\'ENQUÊTE',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 20),
          
          // Identification
          _buildEnqueteHeader(enquete, cooperativeName),
          pw.SizedBox(height: 20),
          
          // Scores globaux
          _buildEnqueteScores(enquete),
          pw.SizedBox(height: 20),
          
          // Détail des réponses
          _buildEnqueteResponses(enquete),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Enquete_${enquete.codeCooperative}_${enquete.idMembre}.pdf',
    );
  }

  // Construire l'en-tête du document
  static pw.Widget _buildHeader(String projectName) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.purple100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'COOP ANALYZER',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.purple,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            projectName,
            style: const pw.TextStyle(
              fontSize: 14,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Date: ${DateTime.now().toString().split(' ')[0]}',
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  // Construire le résumé général
  static pw.Widget _buildSummary(List<Map<String, dynamic>> diagnostics) {
    final scoresMoyens = diagnostics.fold<double>(
      0,
      (sum, d) => sum + ((d['scores'] as Map<String, dynamic>)['score_global'] as double),
    ) / diagnostics.length;

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.purple, width: 2),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'RÉSUMÉ GÉNÉRAL',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Nombre de coopératives évaluées:'),
              pw.Text(
                '${diagnostics.length}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Score moyen global:'),
              pw.Text(
                '${scoresMoyens.toStringAsFixed(1)}/100',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Construire le diagnostic d'une coopérative
  static pw.Widget _buildCooperativeDiagnostic(Map<String, dynamic> diagnostic) {
    final coop = diagnostic['cooperative'] as Cooperative;
    final scores = diagnostic['scores'] as Map<String, dynamic>;
    final classification = diagnostic['classification'] as String;
    final recommandations = diagnostic['recommandations'] as Map<String, String>;

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 30),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.purple,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  '${coop.code} - ${coop.nom}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.Text(
                  '${(scores['score_global'] as double).toStringAsFixed(1)}/100',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          
          // Classification
          pw.Text(
            'Classification: $classification',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.purple800,
            ),
          ),
          pw.SizedBox(height: 12),
          
          // Scores par dimension
          pw.Text(
            'Scores par dimension:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          _buildScoreBar('Gouvernance', scores['score_governance'] as double),
          _buildScoreBar('Performance', scores['score_performance'] as double),
          _buildScoreBar('Finance', scores['score_finance'] as double),
          _buildScoreBar('Actifs', scores['score_actifs'] as double),
          _buildScoreBar('Résilience', scores['score_resilience'] as double),
          
          pw.SizedBox(height: 12),
          
          // Recommandations
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Recommandations:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  '• ${recommandations['rec_gouvernance']}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  '• ${recommandations['rec_performance']}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  '• ${recommandations['rec_finance']}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
          
          pw.Divider(height: 30, thickness: 2),
        ],
      ),
    );
  }

  static pw.Widget _buildScoreBar(String label, double score) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 12),
            ),
          ),
          pw.Expanded(
            child: pw.Stack(
              children: [
                pw.Container(
                  height: 12,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey300,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                ),
                pw.Container(
                  width: (score / 100) * 200, // Largeur fixe relative
                  height: 12,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.purple,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Text(
            '${score.toStringAsFixed(1)}%',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildClassementTable(List<Map<String, dynamic>> classement) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        // En-tête
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.purple),
          children: [
            _buildTableCell('Rang', isHeader: true),
            _buildTableCell('Code', isHeader: true),
            _buildTableCell('Nom', isHeader: true),
            _buildTableCell('Score', isHeader: true),
            _buildTableCell('Classification', isHeader: true),
          ],
        ),
        // Données
        ...classement.map((item) {
          final coop = item['cooperative'] as Cooperative;
          final scores = item['scores'] as Map<String, dynamic>;
          final classification = item['classification'] as String;
          
          return pw.TableRow(
            children: [
              _buildTableCell('${item['rang']}'),
              _buildTableCell(coop.code),
              _buildTableCell(coop.nom),
              _buildTableCell('${(scores['score_global'] as double).toStringAsFixed(1)}'),
              _buildTableCell(classification),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.white : PdfColors.black,
        ),
      ),
    );
  }

  static pw.Widget _buildEnqueteHeader(EnqueteMembre enquete, String cooperativeName) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.purple),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Coopérative:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(cooperativeName),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('ID Membre:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(enquete.idMembre),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Genre:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(enquete.genre == 'H' ? 'Homme' : 'Femme'),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildEnqueteScores(EnqueteMembre enquete) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.purple100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'SCORE GLOBAL',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '${enquete.scoreGlobal?.toStringAsFixed(1) ?? "N/A"}/100',
            style: pw.TextStyle(
              fontSize: 32,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.purple,
            ),
          ),
          pw.SizedBox(height: 16),
          _buildScoreBar('Gouvernance', enquete.scoreGovernance ?? 0),
          _buildScoreBar('Performance', enquete.scorePerformance ?? 0),
          _buildScoreBar('Finance', enquete.scoreFinance ?? 0),
          _buildScoreBar('Actifs', enquete.scoreActifs ?? 0),
          _buildScoreBar('Résilience', enquete.scoreResilience ?? 0),
        ],
      ),
    );
  }

  static pw.Widget _buildEnqueteResponses(EnqueteMembre enquete) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DÉTAIL DES RÉPONSES',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 12),
        _buildResponseSection('Gouvernance', [
          'Décisions démocratiques: ${enquete.decisionsDemo}/5',
          'AG régulières: ${enquete.agRegulieres}/5',
          'Transparence financière: ${enquete.transparenceFinanciere}/5',
          'Statuts appliqués: ${enquete.statutsAppliques}/5',
          'Mandats respectés: ${enquete.mandatsRespectes}/5',
        ]),
        pw.SizedBox(height: 12),
        _buildResponseSection('Performance Économique', [
          'Production augmentée: ${enquete.productionAugmentee}/5',
          'Revenus améliorés: ${enquete.revenusAmeliores}/5',
          'Accès marché: ${enquete.accesMarche}/5',
          'Qualité normes: ${enquete.qualiteNormes}/5',
          'Coûts maîtrisés: ${enquete.coutsMaitrises}/5',
        ]),
      ],
    );
  }

  static pw.Widget _buildResponseSection(String title, List<String> responses) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.purple,
            ),
          ),
          pw.SizedBox(height: 8),
          ...responses.map((r) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Text('• $r', style: const pw.TextStyle(fontSize: 10)),
          )),
        ],
      ),
    );
  }
}
