import 'package:flutter/material.dart';
import '../models/enquete_membre.dart';
import '../utils/app_theme.dart';
import '../widgets/stat_widgets.dart';

class EnqueteDetailsScreen extends StatelessWidget {
  final EnqueteMembre enquete;

  const EnqueteDetailsScreen({
    super.key,
    required this.enquete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'enquête'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête membre
              _buildMemberHeader(),
              
              const SizedBox(height: 24),
              
              // Score global
              _buildGlobalScore(),
              
              const SizedBox(height: 24),
              
              // Scores par dimension
              const Text(
                'Scores par dimension',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildDimensionScore(
                'Gouvernance',
                enquete.scoreGovernance ?? 0,
                AppTheme.primaryPurple,
                Icons.account_balance,
              ),
              const SizedBox(height: 12),
              
              _buildDimensionScore(
                'Performance Économique',
                enquete.scorePerformance ?? 0,
                AppTheme.secondaryOrange,
                Icons.trending_up,
              ),
              const SizedBox(height: 12),
              
              _buildDimensionScore(
                'Gestion Financière',
                enquete.scoreFinance ?? 0,
                AppTheme.accentTeal,
                Icons.account_balance_wallet,
              ),
              const SizedBox(height: 12),
              
              _buildDimensionScore(
                'Actifs Productifs',
                enquete.scoreActifs ?? 0,
                AppTheme.accentPink,
                Icons.factory,
              ),
              const SizedBox(height: 12),
              
              _buildDimensionScore(
                'Résilience',
                enquete.scoreResilience ?? 0,
                AppTheme.accentYellow,
                Icons.shield,
              ),
              
              const SizedBox(height: 32),
              
              // Détail des réponses
              _buildResponsesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.purpleGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                enquete.genre == 'H' ? Icons.man : Icons.woman,
                size: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    enquete.idMembre,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    enquete.codeCooperative,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: enquete.genre == 'H'
                          ? Colors.blue.withValues(alpha: 0.2)
                          : Colors.pink.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      enquete.genre == 'H' ? 'Homme' : 'Femme',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: enquete.genre == 'H' ? Colors.blue : Colors.pink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalScore() {
    final score = enquete.scoreGlobal ?? 0;
    
    Color getScoreColor(double score) {
      if (score >= 80) return AppTheme.successGreen;
      if (score >= 60) return AppTheme.warningOrange;
      return AppTheme.errorRed;
    }
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            getScoreColor(score),
            getScoreColor(score).withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: getScoreColor(score).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.star,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Score Global',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      score.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8, left: 4),
                      child: Text(
                        '/100',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionScore(String label, double score, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        '${score.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: score / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Détail des réponses',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 16),
        
        _buildResponseCategory(
          'Gouvernance',
          AppTheme.primaryPurple,
          [
            ResponseItem('Décisions démocratiques', enquete.decisionsDemo),
            ResponseItem('AG régulières', enquete.agRegulieres),
            ResponseItem('Transparence financière', enquete.transparenceFinanciere),
            ResponseItem('Statuts appliqués', enquete.statutsAppliques),
            ResponseItem('Mandats respectés', enquete.mandatsRespectes),
          ],
        ),
        
        const SizedBox(height: 16),
        
        _buildResponseCategory(
          'Performance Économique',
          AppTheme.secondaryOrange,
          [
            ResponseItem('Production augmentée', enquete.productionAugmentee),
            ResponseItem('Revenus améliorés', enquete.revenusAmeliores),
            ResponseItem('Accès marché', enquete.accesMarche),
            ResponseItem('Qualité aux normes', enquete.qualiteNormes),
            ResponseItem('Coûts maîtrisés', enquete.coutsMaitrises),
          ],
        ),
        
        const SizedBox(height: 16),
        
        _buildResponseCategory(
          'Gestion Financière',
          AppTheme.accentTeal,
          [
            ResponseItem('Compta à jour', enquete.comptaAJour),
            ResponseItem('Cotisations collectées', enquete.cotisationsCollectees),
            ResponseItem('Accès crédit', enquete.accesCredit),
            ResponseItem('Excédents équitables', enquete.excedentsEquitables),
            ResponseItem('Budget respecté', enquete.budgetRespecte),
          ],
        ),
        
        const SizedBox(height: 16),
        
        _buildResponseCategory(
          'Actifs Productifs',
          AppTheme.accentPink,
          [
            ResponseItem('Équipements OK', enquete.equipementsOK),
            ResponseItem('Infrastructures adaptées', enquete.infrastructuresAdaptees),
            ResponseItem('Renouvellement planifié', enquete.renouvellementPlanifie),
            ResponseItem('Accès intrants', enquete.accesIntrants),
            ResponseItem('Maintenance régulière', enquete.maintenanceReguliere),
          ],
        ),
        
        const SizedBox(height: 16),
        
        _buildResponseCategory(
          'Résilience',
          AppTheme.accentYellow,
          [
            ResponseItem('Risques climatiques', enquete.risquesClimatiques),
            ResponseItem('Formation régulière', enquete.formationReguliere),
            ResponseItem('Diversification', enquete.diversification),
            ResponseItem('Épargne collective', enquete.epargneCollective),
            ResponseItem('Relève jeunes', enquete.releveJeunes),
          ],
        ),
      ],
    );
  }

  Widget _buildResponseCategory(String titre, Color color, List<ResponseItem> items) {
    return Card(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  titre,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                
                return Column(
                  children: [
                    if (index > 0) const Divider(height: 24),
                    _buildResponseItem(item.label, item.value, color),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseItem(String label, int value, Color color) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textDark,
            ),
          ),
        ),
        Row(
          children: List.generate(5, (index) {
            final isActive = index < value;
            return Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: isActive ? color : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : AppTheme.textGray,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class ResponseItem {
  final String label;
  final int value;
  
  ResponseItem(this.label, this.value);
}
