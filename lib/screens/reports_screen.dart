import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../services/pdf_export_service.dart';
import '../services/excel_import_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedFilter = 'all';
  String _selectedCooperative = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapports & Graphiques'),
        actions: [
          // Import Excel
          IconButton(
            onPressed: _showImportMenu,
            icon: const Icon(Icons.upload_file),
            tooltip: 'Importer Excel',
          ),
          // Export PDF
          IconButton(
            onPressed: _showExportMenu,
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Exporter PDF',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filtres
              _buildFilters(),
              
              const SizedBox(height: 24),
              
              // Graphique en camembert - Distribution des classifications
              _buildPieChartCard(),
              
              const SizedBox(height: 24),
              
              // Graphique en barres - Scores moyens par dimension
              _buildBarChartCard(),
              
              const SizedBox(height: 24),
              
              // Graphique radar - Profil moyen
              _buildRadarChartCard(),
              
              const SizedBox(height: 24),
              
              // Graphique en ligne - Évolution des scores
              _buildLineChartCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.filter_list, color: AppTheme.primaryPurple),
                SizedBox(width: 12),
                Text(
                  'Filtres',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Filtre par coopérative
            Consumer<AppProvider>(
              builder: (context, provider, child) {
                return DropdownButtonFormField<String>(
                  value: _selectedCooperative,
                  decoration: const InputDecoration(
                    labelText: 'Coopérative',
                    prefixIcon: Icon(Icons.business),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: 'all',
                      child: Text('Toutes les coopératives'),
                    ),
                    ...provider.cooperatives.map((coop) {
                      return DropdownMenuItem(
                        value: coop.code,
                        child: Text('${coop.code} - ${coop.nom}'),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCooperative = value ?? 'all';
                    });
                  },
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Filtre par score
            DropdownButtonFormField<String>(
              value: _selectedFilter,
              decoration: const InputDecoration(
                labelText: 'Niveau de performance',
                prefixIcon: Icon(Icons.star),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Tous les niveaux')),
                DropdownMenuItem(value: 'excellent', child: Text('Excellent (≥80)')),
                DropdownMenuItem(value: 'bon', child: Text('Bon (60-79)')),
                DropdownMenuItem(value: 'moyen', child: Text('Moyen (40-59)')),
                DropdownMenuItem(value: 'faible', child: Text('Faible (<40)')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value ?? 'all';
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distribution des classifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 24),
            Consumer<AppProvider>(
              builder: (context, provider, child) {
                final diagnostics = _getFilteredDiagnostics(provider);
                
                if (diagnostics.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('Aucune donnée disponible'),
                    ),
                  );
                }

                // Compter les classifications
                final classifications = <String, int>{};
                for (var diagnostic in diagnostics) {
                  final classification = diagnostic['classification'] as String;
                  classifications[classification] = (classifications[classification] ?? 0) + 1;
                }

                return SizedBox(
                  height: 250,
                  child: Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 60,
                            sections: _buildPieSections(classifications),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: classifications.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: _getClassificationColor(entry.key),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${entry.key}: ${entry.value}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChartCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scores moyens par dimension',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 24),
            Consumer<AppProvider>(
              builder: (context, provider, child) {
                final diagnostics = _getFilteredDiagnostics(provider);
                
                if (diagnostics.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('Aucune donnée disponible'),
                    ),
                  );
                }

                // Calculer les moyennes
                final moyennes = <String, double>{
                  'GOV': 0, 'PERF': 0, 'FIN': 0, 'ACT': 0, 'RES': 0,
                };

                for (var diagnostic in diagnostics) {
                  final scores = diagnostic['scores'] as Map<String, dynamic>;
                  moyennes['GOV'] = moyennes['GOV']! + (scores['score_governance'] as double);
                  moyennes['PERF'] = moyennes['PERF']! + (scores['score_performance'] as double);
                  moyennes['FIN'] = moyennes['FIN']! + (scores['score_finance'] as double);
                  moyennes['ACT'] = moyennes['ACT']! + (scores['score_actifs'] as double);
                  moyennes['RES'] = moyennes['RES']! + (scores['score_resilience'] as double);
                }

                final count = diagnostics.length.toDouble();
                moyennes.updateAll((key, value) => value / count);

                return SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      maxY: 100,
                      barGroups: [
                        _buildBarGroup(0, moyennes['GOV']!, AppTheme.primaryPurple),
                        _buildBarGroup(1, moyennes['PERF']!, AppTheme.secondaryOrange),
                        _buildBarGroup(2, moyennes['FIN']!, AppTheme.accentTeal),
                        _buildBarGroup(3, moyennes['ACT']!, AppTheme.accentPink),
                        _buildBarGroup(4, moyennes['RES']!, AppTheme.accentYellow),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const labels = ['GOV', 'PERF', 'FIN', 'ACT', 'RES'];
                              if (value.toInt() < labels.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    labels[value.toInt()],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}',
                                style: const TextStyle(fontSize: 12),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: 20,
                      ),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadarChartCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profil moyen des coopératives',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 24),
            Consumer<AppProvider>(
              builder: (context, provider, child) {
                final diagnostics = _getFilteredDiagnostics(provider);
                
                if (diagnostics.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('Aucune donnée disponible'),
                    ),
                  );
                }

                // Calculer les moyennes pour le radar chart
                final moyennes = <double>[];
                final labels = [
                  'Gouvernance',
                  'Performance',
                  'Finance',
                  'Actifs',
                  'Résilience',
                ];

                double sumGov = 0, sumPerf = 0, sumFin = 0, sumAct = 0, sumRes = 0;
                for (var diagnostic in diagnostics) {
                  final scores = diagnostic['scores'] as Map<String, dynamic>;
                  sumGov += scores['score_governance'] as double;
                  sumPerf += scores['score_performance'] as double;
                  sumFin += scores['score_finance'] as double;
                  sumAct += scores['score_actifs'] as double;
                  sumRes += scores['score_resilience'] as double;
                }

                final count = diagnostics.length.toDouble();
                moyennes.addAll([
                  sumGov / count,
                  sumPerf / count,
                  sumFin / count,
                  sumAct / count,
                  sumRes / count,
                ]);

                return SizedBox(
                  height: 300,
                  child: RadarChart(
                    RadarChartData(
                      radarShape: RadarShape.polygon,
                      tickCount: 5,
                      ticksTextStyle: const TextStyle(fontSize: 10),
                      radarBorderData: const BorderSide(color: Colors.grey, width: 2),
                      gridBorderData: const BorderSide(color: Colors.grey, width: 1),
                      tickBorderData: const BorderSide(color: Colors.grey),
                      getTitle: (index, angle) {
                        return RadarChartTitle(
                          text: labels[index],
                          angle: angle,
                        );
                      },
                      dataSets: [
                        RadarDataSet(
                          fillColor: AppTheme.primaryPurple.withValues(alpha: 0.3),
                          borderColor: AppTheme.primaryPurple,
                          borderWidth: 2,
                          dataEntries: moyennes
                              .map((value) => RadarEntry(value: value))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChartCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comparaison des coopératives',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Score global par coopérative',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textGray,
              ),
            ),
            const SizedBox(height: 24),
            Consumer<AppProvider>(
              builder: (context, provider, child) {
                final diagnostics = _getFilteredDiagnostics(provider);
                
                if (diagnostics.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('Aucune donnée disponible'),
                    ),
                  );
                }

                final spots = <FlSpot>[];
                for (var i = 0; i < diagnostics.length; i++) {
                  final scores = diagnostics[i]['scores'] as Map<String, dynamic>;
                  spots.add(FlSpot(i.toDouble(), scores['score_global'] as double));
                }

                return SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 100,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: AppTheme.primaryPurple,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.primaryPurple.withValues(alpha: 0.2),
                          ),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() < diagnostics.length) {
                                final coop = diagnostics[value.toInt()]['cooperative'];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    coop.code,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}',
                                style: const TextStyle(fontSize: 12),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: true),
                      borderData: FlBorderData(show: true),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredDiagnostics(AppProvider provider) {
    var diagnostics = provider.getDiagnosticsComplets();

    // Filtre par coopérative
    if (_selectedCooperative != 'all') {
      diagnostics = diagnostics.where((d) {
        return d['cooperative'].code == _selectedCooperative;
      }).toList();
    }

    // Filtre par score
    if (_selectedFilter != 'all') {
      diagnostics = diagnostics.where((d) {
        final score = (d['scores'] as Map<String, dynamic>)['score_global'] as double;
        switch (_selectedFilter) {
          case 'excellent':
            return score >= 80;
          case 'bon':
            return score >= 60 && score < 80;
          case 'moyen':
            return score >= 40 && score < 60;
          case 'faible':
            return score < 40;
          default:
            return true;
        }
      }).toList();
    }

    return diagnostics;
  }

  List<PieChartSectionData> _buildPieSections(Map<String, int> classifications) {
    final total = classifications.values.fold<int>(0, (sum, value) => sum + value);
    
    return classifications.entries.map((entry) {
      final percentage = (entry.value / total * 100).toStringAsFixed(1);
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '$percentage%',
        color: _getClassificationColor(entry.key),
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getClassificationColor(String classification) {
    if (classification.contains('fort')) {
      return AppTheme.successGreen;
    } else if (classification.contains('fragile')) {
      return AppTheme.warningOrange;
    } else if (classification.contains('Neutre')) {
      return AppTheme.infoBlue;
    } else {
      return AppTheme.errorRed;
    }
  }

  BarChartGroupData _buildBarGroup(int x, double value, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          color: color,
          width: 24,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }

  void _showImportMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.business, color: AppTheme.primaryPurple),
              title: const Text('Importer des coopératives'),
              onTap: () async {
                Navigator.pop(context);
                final cooperatives = await ExcelImportService.importCooperatives();
                if (cooperatives != null && cooperatives.isNotEmpty && mounted) {
                  final provider = context.read<AppProvider>();
                  for (var coop in cooperatives) {
                    await provider.ajouterCooperative(coop);
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${cooperatives.length} coopératives importées'),
                        backgroundColor: AppTheme.successGreen,
                      ),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment, color: AppTheme.accentTeal),
              title: const Text('Importer des enquêtes'),
              onTap: () async {
                Navigator.pop(context);
                final enquetes = await ExcelImportService.importEnquetes();
                if (enquetes != null && enquetes.isNotEmpty && mounted) {
                  final provider = context.read<AppProvider>();
                  for (var enquete in enquetes) {
                    await provider.ajouterEnquete(enquete);
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${enquetes.length} enquêtes importées'),
                        backgroundColor: AppTheme.successGreen,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showExportMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.analytics, color: AppTheme.primaryPurple),
              title: const Text('Exporter le diagnostic complet'),
              onTap: () async {
                Navigator.pop(context);
                final provider = context.read<AppProvider>();
                final diagnostics = provider.getDiagnosticsComplets();
                final parametrage = provider.parametrage;
                
                await PdfExportService.exportDiagnosticReport(
                  diagnostics: diagnostics,
                  projectName: parametrage?.nomProjet ?? 'Diagnostic Coopératives',
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events, color: AppTheme.secondaryOrange),
              title: const Text('Exporter le classement'),
              onTap: () async {
                Navigator.pop(context);
                final provider = context.read<AppProvider>();
                final classement = provider.getClassement();
                final parametrage = provider.parametrage;
                
                await PdfExportService.exportClassement(
                  classement: classement,
                  projectName: parametrage?.nomProjet ?? 'Diagnostic Coopératives',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
