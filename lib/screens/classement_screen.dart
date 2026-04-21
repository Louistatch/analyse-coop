import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/stat_widgets.dart';

class ClassementScreen extends StatelessWidget {
  const ClassementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Classement',
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

                  final classement = provider.getClassement();

                  if (classement.isEmpty) {
                    return const EmptyState(
                      icon: Icons.emoji_events,
                      title: 'Aucun classement',
                      message: 'Le classement sera généré une fois que vous aurez ajouté des coopératives et des enquêtes',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: classement.length,
                    itemBuilder: (context, index) {
                      final item = classement[index];
                      final rang = item['rang'] as int;
                      final coop = item['cooperative'];
                      final scores = item['scores'] as Map<String, dynamic>;
                      final scoreGlobal = scores['score_global'] as double;
                      final classification = item['classification'] as String;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              _RankBadge(rank: rang),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      coop.nom,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: AppTheme.textGray,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          coop.localisation,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textGray,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(
                                          Icons.agriculture,
                                          size: 14,
                                          color: AppTheme.textGray,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          coop.filiere,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textGray,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    _ClassificationBadge(
                                      classification: classification,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    scoreGlobal.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryPurple,
                                    ),
                                  ),
                                  const Text(
                                    '/100',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textGray,
                                    ),
                                  ),
                                ],
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

class _RankBadge extends StatelessWidget {
  final int rank;

  const _RankBadge({required this.rank});

  Gradient _getGradient() {
    if (rank == 1) {
      return const LinearGradient(
        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (rank == 2) {
      return const LinearGradient(
        colors: [Color(0xFFC0C0C0), Color(0xFF808080)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (rank == 3) {
      return const LinearGradient(
        colors: [Color(0xFFCD7F32), Color(0xFF8B4513)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return const LinearGradient(
        colors: [AppTheme.textGray, AppTheme.textGray],
      );
    }
  }

  IconData _getIcon() {
    if (rank <= 3) {
      return Icons.emoji_events;
    } else {
      return Icons.tag;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: _getGradient(),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIcon(),
            color: Colors.white,
            size: 20,
          ),
          Text(
            '#$rank',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassificationBadge extends StatelessWidget {
  final String classification;

  const _ClassificationBadge({required this.classification});

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        classification,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
