import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/cooperative.dart';
import '../utils/app_theme.dart';
import '../widgets/stat_widgets.dart';
import 'evaluation_actifs_screen.dart';
import 'evaluation_passifs_screen.dart';

class CooperativesScreen extends StatelessWidget {
  const CooperativesScreen({super.key});

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
                      'Coopératives',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _showAddCooperativeDialog(context);
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.purpleGradient,
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

                  if (provider.cooperatives.isEmpty) {
                    return EmptyState(
                      icon: Icons.business,
                      title: 'Aucune coopérative',
                      message: 'Commencez par ajouter une coopérative',
                      buttonText: 'Ajouter une coopérative',
                      onButtonPressed: () {
                        _showAddCooperativeDialog(context);
                      },
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: provider.cooperatives.length,
                    itemBuilder: (context, index) {
                      final coop = provider.cooperatives[index];
                      return CooperativeCard(
                        code: coop.code,
                        nom: coop.nom,
                        localisation: coop.localisation,
                        filiere: coop.filiere,
                        nbMembres: coop.nbMembres,
                        scoreGlobal: coop.scoreGlobal,
                        classification: coop.classification,
                        onTap: () {
                          _showCooperativeDetails(context, coop);
                        },
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

  void _showAddCooperativeDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final codeController = TextEditingController();
    final nomController = TextEditingController();
    final localisationController = TextEditingController();
    final filiereController = TextEditingController();
    final nbMembresController = TextEditingController();
    final anneeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle coopérative'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Code',
                    hintText: 'COOP001',
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nomController,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: localisationController,
                  decoration: const InputDecoration(
                    labelText: 'Localisation',
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: filiereController,
                  decoration: const InputDecoration(
                    labelText: 'Filière',
                    hintText: 'Café, Cacao, Riz...',
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nbMembresController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de membres',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: anneeController,
                  decoration: const InputDecoration(
                    labelText: 'Année de création',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Requis' : null,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.primaryOrange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Les actifs et passifs seront ajoutés via les évaluations détaillées après création.',
                          style: TextStyle(fontSize: 12, color: AppTheme.textGray),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final cooperative = Cooperative(
                  code: codeController.text,
                  nom: nomController.text,
                  localisation: localisationController.text,
                  filiere: filiereController.text,
                  nbMembres: int.parse(nbMembresController.text),
                  anneeCreation: int.parse(anneeController.text),
                  statutJuridique: 'SCOOPS',
                  actifTotal: 0,  // Sera calculé depuis les évaluations
                  passifTotal: 0, // Sera calculé depuis les évaluations
                );

                context.read<AppProvider>().ajouterCooperative(cooperative);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Coopérative ajoutée avec succès'),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showCooperativeDetails(BuildContext context, Cooperative coop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppTheme.purpleGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.business,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coop.nom,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          coop.code,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailRow(
                icon: Icons.location_on,
                label: 'Localisation',
                value: coop.localisation,
              ),
              _DetailRow(
                icon: Icons.agriculture,
                label: 'Filière',
                value: coop.filiere,
              ),
              _DetailRow(
                icon: Icons.people,
                label: 'Membres',
                value: '${coop.nbMembres}',
              ),
              _DetailRow(
                icon: Icons.calendar_today,
                label: 'Année création',
                value: '${coop.anneeCreation}',
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Situation financière',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Actifs', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: const Size(0, 32),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EvaluationActifsScreen(cooperative: coop),
                            ),
                          );
                          if (result == true && context.mounted) {
                            _showCooperativeDetails(context, coop);
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Passifs', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryPink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: const Size(0, 32),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EvaluationPassifsScreen(cooperative: coop),
                            ),
                          );
                          if (result == true && context.mounted) {
                            _showCooperativeDetails(context, coop);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Consumer<AppProvider>(
                builder: (context, provider, child) {
                  final evaluationsActifs = provider.getEvaluationsActifsByCooperative(coop.code);
                  final evaluationsPassifs = provider.getEvaluationsPassifsByCooperative(coop.code);
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(
                        icon: Icons.account_balance,
                        label: 'Actif total',
                        value: evaluationsActifs.isEmpty 
                            ? 'Non évalué' 
                            : '${(coop.actifTotal / 1000000).toStringAsFixed(2)} M FCFA',
                      ),
                      _DetailRow(
                        icon: Icons.credit_card,
                        label: 'Passif total',
                        value: evaluationsPassifs.isEmpty
                            ? 'Non évalué'
                            : '${(coop.passifTotal / 1000000).toStringAsFixed(2)} M FCFA',
                      ),
                      if (evaluationsActifs.isNotEmpty && evaluationsPassifs.isNotEmpty) ...[
                        _DetailRow(
                          icon: Icons.trending_up,
                          label: 'Actif net',
                          value: '${(coop.actifNet / 1000000).toStringAsFixed(2)} M FCFA',
                        ),
                        _DetailRow(
                          icon: Icons.percent,
                          label: 'Ratio A/P',
                          value: coop.ratioAP.toStringAsFixed(2),
                        ),
                      ],
                      if (evaluationsActifs.isEmpty || evaluationsPassifs.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Ajoutez des évaluations pour calculer automatiquement les ratios financiers',
                                    style: TextStyle(fontSize: 11, color: AppTheme.textGray),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              if (coop.scoreGlobal != null) ...[
                const SizedBox(height: 24),
                const Text(
                  'Performance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                _DetailRow(
                  icon: Icons.star,
                  label: 'Score global',
                  value: '${coop.scoreGlobal!.toStringAsFixed(1)}/100',
                ),
                if (coop.classification != null)
                  _DetailRow(
                    icon: Icons.assessment,
                    label: 'Classification',
                    value: coop.classification!,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppTheme.primaryPurple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textGray,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
