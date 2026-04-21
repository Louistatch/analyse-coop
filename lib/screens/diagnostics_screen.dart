import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/stat_widgets.dart';

class DiagnosticsScreen extends StatelessWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Diagnostics',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            Expanded(
              child: Consumer<AppProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final diagnostics = provider.getDiagnosticsComplets();

                  if (diagnostics.isEmpty) {
                    return const EmptyState(
                      icon: Icons.analytics,
                      title: 'Aucun diagnostic',
                      message: 'Ajoutez des coopératives et des enquêtes pour générer des diagnostics',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: diagnostics.length,
                    itemBuilder: (context, index) {
                      final diagnostic = diagnostics[index];
                      final coop = diagnostic['cooperative'];
                      final scores = diagnostic['scores'] as Map<String, dynamic>;
                      final classification = diagnostic['classification'] as String;
                      final recommandations = diagnostic['recommandations'] as Map<String, String>;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.purpleGradient,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      coop.code,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      coop.nom,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _ClassificationChip(classification: classification),
                              const SizedBox(height: 16),
                              const Text(
                                'Scores par dimension',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ScoreIndicator(
                                label: 'Gouvernance',
                                score: scores['score_governance'] as double,
                                color: AppTheme.primaryPurple,
                              ),
                              const SizedBox(height: 8),
                              ScoreIndicator(
                                label: 'Performance',
                                score: scores['score_performance'] as double,
                                color: AppTheme.secondaryOrange,
                              ),
                              const SizedBox(height: 8),
                              ScoreIndicator(
                                label: 'Finance',
                                score: scores['score_finance'] as double,
                                color: AppTheme.accentTeal,
                              ),
                              const SizedBox(height: 8),
                              ScoreIndicator(
                                label: 'Actifs',
                                score: scores['score_actifs'] as double,
                                color: AppTheme.accentPink,
                              ),
                              const SizedBox(height: 8),
                              ScoreIndicator(
                                label: 'Résilience',
                                score: scores['score_resilience'] as double,
                                color: AppTheme.accentYellow,
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.infoBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.lightbulb,
                                          size: 16,
                                          color: AppTheme.infoBlue,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Recommandations',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.infoBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      recommandations['rec_gouvernance'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassificationChip extends StatelessWidget {
  final String classification;

  const _ClassificationChip({required this.classification});

  Color _getColor() {
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

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            classification,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
