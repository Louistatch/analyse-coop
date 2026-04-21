import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/stat_widgets.dart';
import 'add_enquete_screen.dart';
import 'enquete_details_screen.dart';

class EnquetesScreen extends StatelessWidget {
  const EnquetesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Enquêtes',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddEnqueteScreen(),
                        ),
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.tealGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
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

                  if (provider.enquetes.isEmpty) {
                    return EmptyState(
                      icon: Icons.assignment,
                      title: 'Aucune enquête',
                      message: 'Commencez par saisir des enquêtes pour les membres des coopératives',
                      buttonText: 'Nouvelle enquête',
                      onButtonPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddEnqueteScreen(),
                          ),
                        );
                      },
                    );
                  }

                  // Grouper par coopérative
                  final enquetesParCoop = <String, int>{};
                  for (var enquete in provider.enquetes) {
                    enquetesParCoop[enquete.codeCooperative] = 
                        (enquetesParCoop[enquete.codeCooperative] ?? 0) + 1;
                  }

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Résumé par coopérative
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.bar_chart,
                                    color: AppTheme.primaryPurple,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Résumé par coopérative',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ...enquetesParCoop.entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: AppTheme.tealGradient,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          entry.key,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${entry.value} enquête${entry.value > 1 ? 's' : ''}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.textGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      const Text(
                        'Toutes les enquêtes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Liste des enquêtes
                      ...provider.enquetes.map((enquete) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: AppTheme.tealGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                enquete.genre == 'H' ? Icons.man : Icons.woman,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              '${enquete.codeCooperative} - ${enquete.idMembre}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Score: ${enquete.scoreGlobal?.toStringAsFixed(1) ?? "N/A"}/100',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EnqueteDetailsScreen(
                                    enquete: enquete,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ],
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
