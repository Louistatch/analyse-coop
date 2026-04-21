import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/enquete_membre.dart';
import '../models/cooperative.dart';
import '../utils/app_theme.dart';

class AddEnqueteScreen extends StatefulWidget {
  const AddEnqueteScreen({super.key});

  @override
  State<AddEnqueteScreen> createState() => _AddEnqueteScreenState();
}

class _AddEnqueteScreenState extends State<AddEnqueteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  
  int _currentPage = 0;
  
  // Identification
  Cooperative? _selectedCooperative;
  final _idMembreController = TextEditingController();
  String _genre = 'H';
  
  // Réponses (initialisées à 3 = Moyen)
  final Map<String, int> _reponses = {
    // Gouvernance (5 questions)
    'decisions_demo': 3,
    'ag_regulieres': 3,
    'transparence_financiere': 3,
    'statuts_appliques': 3,
    'mandats_respectes': 3,
    
    // Performance économique (5 questions)
    'production_augmentee': 3,
    'revenus_ameliores': 3,
    'acces_marche': 3,
    'qualite_normes': 3,
    'couts_maitrises': 3,
    
    // Gestion financière (5 questions)
    'compta_a_jour': 3,
    'cotisations_collectees': 3,
    'acces_credit': 3,
    'excedents_equitables': 3,
    'budget_respecte': 3,
    
    // Actifs productifs (5 questions)
    'equipements_ok': 3,
    'infrastructures_adaptees': 3,
    'renouvellement_planifie': 3,
    'acces_intrants': 3,
    'maintenance_reguliere': 3,
    
    // Résilience (5 questions)
    'risques_climatiques': 3,
    'formation_reguliere': 3,
    'diversification': 3,
    'epargne_collective': 3,
    'releve_jeunes': 3,
  };

  @override
  void dispose() {
    _idMembreController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _saveEnquete() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCooperative == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une coopérative'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
        return;
      }

      final enquete = EnqueteMembre(
        id: '${_selectedCooperative!.code}_${_idMembreController.text}_${DateTime.now().millisecondsSinceEpoch}',
        codeCooperative: _selectedCooperative!.code,
        idMembre: _idMembreController.text,
        genre: _genre,
        decisionsDemo: _reponses['decisions_demo']!,
        agRegulieres: _reponses['ag_regulieres']!,
        transparenceFinanciere: _reponses['transparence_financiere']!,
        statutsAppliques: _reponses['statuts_appliques']!,
        mandatsRespectes: _reponses['mandats_respectes']!,
        productionAugmentee: _reponses['production_augmentee']!,
        revenusAmeliores: _reponses['revenus_ameliores']!,
        accesMarche: _reponses['acces_marche']!,
        qualiteNormes: _reponses['qualite_normes']!,
        coutsMaitrises: _reponses['couts_maitrises']!,
        comptaAJour: _reponses['compta_a_jour']!,
        cotisationsCollectees: _reponses['cotisations_collectees']!,
        accesCredit: _reponses['acces_credit']!,
        excedentsEquitables: _reponses['excedents_equitables']!,
        budgetRespecte: _reponses['budget_respecte']!,
        equipementsOK: _reponses['equipements_ok']!,
        infrastructuresAdaptees: _reponses['infrastructures_adaptees']!,
        renouvellementPlanifie: _reponses['renouvellement_planifie']!,
        accesIntrants: _reponses['acces_intrants']!,
        maintenanceReguliere: _reponses['maintenance_reguliere']!,
        risquesClimatiques: _reponses['risques_climatiques']!,
        formationReguliere: _reponses['formation_reguliere']!,
        diversification: _reponses['diversification']!,
        epargneCollective: _reponses['epargne_collective']!,
        releveJeunes: _reponses['releve_jeunes']!,
      );

      context.read<AppProvider>().ajouterEnquete(enquete);

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enquête enregistrée avec succès'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle enquête'),
        actions: [
          if (_currentPage == 5)
            TextButton.icon(
              onPressed: _saveEnquete,
              icon: const Icon(Icons.check),
              label: const Text('Terminer'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.successGreen,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Progress indicator
              _buildProgressIndicator(),
              
              // Pages
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildIdentificationPage(),
                    _buildQuestionPage(
                      'Gouvernance',
                      AppTheme.primaryPurple,
                      [
                        QuestionData('decisions_demo', 'Les décisions sont-elles prises de manière démocratique ?'),
                        QuestionData('ag_regulieres', 'Les réunions de l\'AG sont-elles régulières et participatives ?'),
                        QuestionData('transparence_financiere', 'La transparence financière est-elle respectée ?'),
                        QuestionData('statuts_appliques', 'Les statuts et règlements sont-ils appliqués ?'),
                        QuestionData('mandats_respectes', 'Les élus respectent-ils leur mandat ?'),
                      ],
                    ),
                    _buildQuestionPage(
                      'Performance Économique',
                      AppTheme.secondaryOrange,
                      [
                        QuestionData('production_augmentee', 'La production a-t-elle augmenté ?'),
                        QuestionData('revenus_ameliores', 'Les revenus se sont-ils améliorés ?'),
                        QuestionData('acces_marche', 'L\'accès au marché est-il facilité ?'),
                        QuestionData('qualite_normes', 'La qualité répond-elle aux normes ?'),
                        QuestionData('couts_maitrises', 'Les coûts sont-ils maîtrisés ?'),
                      ],
                    ),
                    _buildQuestionPage(
                      'Gestion Financière',
                      AppTheme.accentTeal,
                      [
                        QuestionData('compta_a_jour', 'La comptabilité est-elle à jour ?'),
                        QuestionData('cotisations_collectees', 'Les cotisations sont-elles bien collectées ?'),
                        QuestionData('acces_credit', 'L\'accès au crédit est-il facilité ?'),
                        QuestionData('excedents_equitables', 'Les excédents sont-ils répartis équitablement ?'),
                        QuestionData('budget_respecte', 'Le budget est-il respecté ?'),
                      ],
                    ),
                    _buildQuestionPage(
                      'Actifs Productifs',
                      AppTheme.accentPink,
                      [
                        QuestionData('equipements_ok', 'Les équipements sont-ils en bon état ?'),
                        QuestionData('infrastructures_adaptees', 'Les infrastructures sont-elles adaptées ?'),
                        QuestionData('renouvellement_planifie', 'Le renouvellement est-il planifié ?'),
                        QuestionData('acces_intrants', 'L\'accès aux intrants est-il facilité ?'),
                        QuestionData('maintenance_reguliere', 'La maintenance est-elle régulière ?'),
                      ],
                    ),
                    _buildQuestionPage(
                      'Résilience',
                      AppTheme.accentYellow,
                      [
                        QuestionData('risques_climatiques', 'Les risques climatiques sont-ils gérés ?'),
                        QuestionData('formation_reguliere', 'La formation est-elle régulière ?'),
                        QuestionData('diversification', 'Y a-t-il une diversification des activités ?'),
                        QuestionData('epargne_collective', 'L\'épargne collective est-elle pratiquée ?'),
                        QuestionData('releve_jeunes', 'La relève des jeunes est-elle assurée ?'),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Navigation buttons
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: List.generate(6, (index) {
              final isActive = index <= _currentPage;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.primaryPurple : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'Étape ${_currentPage + 1} sur 6',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentificationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.purpleGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.person, color: Colors.white, size: 32),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Identification du membre',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          const Text(
            'Coopérative',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Consumer<AppProvider>(
            builder: (context, provider, child) {
              return DropdownButtonFormField<Cooperative>(
                value: _selectedCooperative,
                decoration: InputDecoration(
                  hintText: 'Sélectionner une coopérative',
                  prefixIcon: const Icon(Icons.business),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: provider.cooperatives.map((coop) {
                  return DropdownMenuItem(
                    value: coop,
                    child: Text('${coop.code} - ${coop.nom}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCooperative = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Veuillez sélectionner une coopérative' : null,
              );
            },
          ),
          
          const SizedBox(height: 24),
          const Text(
            'ID Membre',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _idMembreController,
            decoration: const InputDecoration(
              hintText: 'M001',
              prefixIcon: Icon(Icons.badge),
            ),
            validator: (value) =>
                value?.isEmpty ?? true ? 'Requis' : null,
          ),
          
          const SizedBox(height: 24),
          const Text(
            'Genre',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildGenreButton('H', 'Homme', Icons.man),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGenreButton('F', 'Femme', Icons.woman),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenreButton(String value, String label, IconData icon) {
    final isSelected = _genre == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _genre = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.purpleGradient : null,
          color: isSelected ? null : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : AppTheme.textGray,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.textGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionPage(String titre, Color color, List<QuestionData> questions) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.quiz, color: Colors.white, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    titre,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.infoBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, size: 16, color: AppTheme.infoBlue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Échelle: 1=Très faible | 2=Faible | 3=Moyen | 4=Bon | 5=Excellent',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.infoBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          ...questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _buildQuestionCard(
                'Q${index + 1}',
                question.text,
                question.key,
                color,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(String numero, String question, String key, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    numero,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final value = index + 1;
                final isSelected = _reponses[key] == value;
                
                return InkWell(
                  onTap: () {
                    setState(() {
                      _reponses[key] = value;
                    });
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected ? color : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$value',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppTheme.textGray,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Très faible', style: TextStyle(fontSize: 10, color: AppTheme.textGray)),
                Text('Excellent', style: TextStyle(fontSize: 10, color: AppTheme.textGray)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousPage,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Précédent'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppTheme.primaryPurple),
                  foregroundColor: AppTheme.primaryPurple,
                ),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentPage == 0 ? 1 : 1,
            child: ElevatedButton.icon(
              onPressed: _currentPage < 5 ? _nextPage : _saveEnquete,
              icon: Icon(_currentPage < 5 ? Icons.arrow_forward : Icons.check),
              label: Text(_currentPage < 5 ? 'Suivant' : 'Terminer'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: _currentPage < 5 ? AppTheme.primaryPurple : AppTheme.successGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuestionData {
  final String key;
  final String text;
  
  QuestionData(this.key, this.text);
}
