import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/app_provider.dart';
import '../services/auth_service.dart';
import '../services/update_service.dart';
import '../utils/app_theme.dart';
import '../widgets/stat_widgets.dart';
import '../widgets/update_dialog.dart';
import 'cooperatives_screen.dart';
import 'enquetes_screen.dart';
import 'diagnostics_screen.dart';
import 'classement_screen.dart';
import 'reports_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    _HomeTab(),
    CooperativesScreen(),
    EnquetesScreen(),
    DiagnosticsScreen(),
    ClassementScreen(),
    ReportsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Vérifier les mises à jour au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }

  Future<void> _checkForUpdates() async {
    try {
      final updateInfo = await UpdateService().checkForUpdate();
      
      if (updateInfo.isUpdateAvailable && mounted) {
        showDialog(
          context: context,
          barrierDismissible: !updateInfo.isMandatory,
          builder: (context) => UpdateDialog(
            updateInfo: updateInfo,
            onUpdateLater: () {
              Navigator.of(context).pop();
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('Erreur vérification mise à jour: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      appBar: _selectedIndex == 0 ? null : AppBar(
        title: Text(_getTitleForIndex(_selectedIndex)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: AppTheme.purpleGradient,
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryPurple,
                  ),
                ),
              ),
              accountName: const Text(
                'Utilisateur',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(user?.email ?? ''),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implémenter la page profil
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Page profil à venir')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implémenter la page paramètres
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Page paramètres à venir')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.system_update),
              title: const Text('Vérifier les mises à jour'),
              onTap: () {
                Navigator.pop(context);
                _checkForUpdates();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('À propos'),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'Coop Analyzer',
                  applicationVersion: '1.0.0',
                  applicationIcon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.purpleGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.analytics,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  children: [
                    const Text(
                      'Application d\'évaluation et diagnostic des coopératives agricoles',
                    ),
                  ],
                );
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Déconnexion',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Déconnexion'),
                    content: const Text('Voulez-vous vraiment vous déconnecter ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annuler'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Déconnexion'),
                      ),
                    ],
                  ),
                );
                
                if (confirm == true && context.mounted) {
                  await AuthService().signOut();
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              label: 'Coopératives',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Enquêtes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Diagnostics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events),
              label: 'Classement',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assessment),
              label: 'Rapports',
            ),
          ],
        ),
      ),
    );
  }
  
  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Accueil';
      case 1:
        return 'Coopératives';
      case 2:
        return 'Enquêtes';
      case 3:
        return 'Diagnostics';
      case 4:
        return 'Classement';
      case 5:
        return 'Rapports';
      default:
        return 'Coop Analyzer';
    }
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: Container(
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => AppTheme.purpleGradient.createShader(bounds),
                      child: const Text(
                        'Coop Analyzer',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Text(
                      'Diagnostic des coopératives',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textGray,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statistiques en temps réel',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<AppProvider>(
                    builder: (context, provider, child) {
                      return FutureBuilder<Map<String, dynamic>>(
                        future: provider.getStatistiques(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final stats = snapshot.data!;
                          
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: StatCard(
                                      title: 'Coopératives',
                                      value: '${stats['cooperatives_enregistrees']}',
                                      icon: Icons.business,
                                      gradient: AppTheme.purpleGradient,
                                      onTap: () {
                                        // Navigate to cooperatives
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: StatCard(
                                      title: 'Membres',
                                      value: '${stats['membres_totaux']}',
                                      icon: Icons.people,
                                      gradient: AppTheme.orangeGradient,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: StatCard(
                                      title: 'Enquêtes',
                                      value: '${stats['enquetes_realisees']}',
                                      icon: Icons.assignment_turned_in,
                                      gradient: AppTheme.tealGradient,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: StatCard(
                                      title: 'Score Moyen',
                                      value: '${(stats['score_moyen_global'] as double).toStringAsFixed(1)}',
                                      icon: Icons.star,
                                      gradient: AppTheme.pinkGradient,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Coopératives récentes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<AppProvider>(
                    builder: (context, provider, child) {
                      final cooperatives = provider.cooperatives.take(5).toList();
                      
                      if (cooperatives.isEmpty) {
                        return const EmptyState(
                          icon: Icons.business,
                          title: 'Aucune coopérative',
                          message: 'Ajoutez votre première coopérative pour commencer',
                        );
                      }

                      return Column(
                        children: cooperatives.map((coop) {
                          return CooperativeCard(
                            code: coop.code,
                            nom: coop.nom,
                            localisation: coop.localisation,
                            filiere: coop.filiere,
                            nbMembres: coop.nbMembres,
                            scoreGlobal: coop.scoreGlobal,
                            classification: coop.classification,
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
