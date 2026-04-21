import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/cooperative.dart';
import '../models/evaluation_actifs.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';

class EvaluationActifsScreen extends StatefulWidget {
  final Cooperative cooperative;
  final EvaluationActifs? evaluation; // Pour modification

  const EvaluationActifsScreen({
    super.key,
    required this.cooperative,
    this.evaluation,
  });

  @override
  State<EvaluationActifsScreen> createState() => _EvaluationActifsScreenState();
}

class _EvaluationActifsScreenState extends State<EvaluationActifsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Actifs immobilisés
  final TextEditingController _terrainsCtrl = TextEditingController();
  final TextEditingController _batimentsCtrl = TextEditingController();
  final TextEditingController _equipementsCtrl = TextEditingController();
  final TextEditingController _materielRoulantCtrl = TextEditingController();
  final TextEditingController _mobilierCtrl = TextEditingController();

  // Actifs circulants
  final TextEditingController _stocksMatieresCtrl = TextEditingController();
  final TextEditingController _stocksProduitsCtrl = TextEditingController();
  final TextEditingController _creancesCtrl = TextEditingController();
  final TextEditingController _disponibilitesCtrl = TextEditingController();
  final TextEditingController _autresActifsCtrl = TextEditingController();

  final TextEditingController _notesCtrl = TextEditingController();
  DateTime _dateEvaluation = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.evaluation != null) {
      _chargerEvaluation();
    }
  }

  void _chargerEvaluation() {
    final eval = widget.evaluation!;
    _terrainsCtrl.text = eval.terrains.toString();
    _batimentsCtrl.text = eval.batiments.toString();
    _equipementsCtrl.text = eval.equipements.toString();
    _materielRoulantCtrl.text = eval.materielRoulant.toString();
    _mobilierCtrl.text = eval.mobilier.toString();
    _stocksMatieresCtrl.text = eval.stocksMatieresPremiere.toString();
    _stocksProduitsCtrl.text = eval.stocksProduitsFinis.toString();
    _creancesCtrl.text = eval.creancesClients.toString();
    _disponibilitesCtrl.text = eval.disponibilites.toString();
    _autresActifsCtrl.text = eval.autresActifsCirculants.toString();
    _notesCtrl.text = eval.notes ?? '';
    _dateEvaluation = eval.dateEvaluation;
  }

  @override
  void dispose() {
    _terrainsCtrl.dispose();
    _batimentsCtrl.dispose();
    _equipementsCtrl.dispose();
    _materielRoulantCtrl.dispose();
    _mobilierCtrl.dispose();
    _stocksMatieresCtrl.dispose();
    _stocksProduitsCtrl.dispose();
    _creancesCtrl.dispose();
    _disponibilitesCtrl.dispose();
    _autresActifsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double _parseDouble(String text) {
    if (text.isEmpty) return 0.0;
    return double.tryParse(text.replaceAll(',', '.')) ?? 0.0;
  }

  double get _totalActifsImmobilises {
    return _parseDouble(_terrainsCtrl.text) +
        _parseDouble(_batimentsCtrl.text) +
        _parseDouble(_equipementsCtrl.text) +
        _parseDouble(_materielRoulantCtrl.text) +
        _parseDouble(_mobilierCtrl.text);
  }

  double get _totalActifsCirculants {
    return _parseDouble(_stocksMatieresCtrl.text) +
        _parseDouble(_stocksProduitsCtrl.text) +
        _parseDouble(_creancesCtrl.text) +
        _parseDouble(_disponibilitesCtrl.text) +
        _parseDouble(_autresActifsCtrl.text);
  }

  double get _totalActifs {
    return _totalActifsImmobilises + _totalActifsCirculants;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateEvaluation,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dateEvaluation = picked);
    }
  }

  Future<void> _sauvegarder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final evaluation = EvaluationActifs(
        id: widget.evaluation?.id ?? 'EVAL_A_${DateTime.now().millisecondsSinceEpoch}',
        cooperativeId: widget.cooperative.code,
        dateEvaluation: _dateEvaluation,
        terrains: _parseDouble(_terrainsCtrl.text),
        batiments: _parseDouble(_batimentsCtrl.text),
        equipements: _parseDouble(_equipementsCtrl.text),
        materielRoulant: _parseDouble(_materielRoulantCtrl.text),
        mobilier: _parseDouble(_mobilierCtrl.text),
        stocksMatieresPremiere: _parseDouble(_stocksMatieresCtrl.text),
        stocksProduitsFinis: _parseDouble(_stocksProduitsCtrl.text),
        creancesClients: _parseDouble(_creancesCtrl.text),
        disponibilites: _parseDouble(_disponibilitesCtrl.text),
        autresActifsCirculants: _parseDouble(_autresActifsCtrl.text),
        notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
      );

      if (widget.evaluation == null) {
        await provider.ajouterEvaluationActifs(evaluation);
      } else {
        await provider.modifierEvaluationActifs(evaluation);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Évaluation des actifs sauvegardée'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildMontantField(String label, TextEditingController controller, {IconData? icon}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: AppTheme.primaryOrange) : null,
        suffixText: 'FC',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildSectionCard(String title, Color color, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.evaluation == null ? 'Nouvelle Évaluation des Actifs' : 'Modifier Évaluation'),
            Text(
              widget.cooperative.nom,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date d'évaluation
              Card(
                color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today, color: AppTheme.primaryOrange),
                  title: const Text('Date d\'évaluation'),
                  subtitle: Text(
                    '${_dateEvaluation.day}/${_dateEvaluation.month}/${_dateEvaluation.year}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: TextButton(
                    onPressed: _selectDate,
                    child: const Text('Modifier'),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ACTIFS IMMOBILISÉS
              _buildSectionCard(
                'ACTIFS IMMOBILISÉS',
                AppTheme.primaryPurple,
                [
                  _buildMontantField('Terrains', _terrainsCtrl, icon: Icons.landscape),
                  const SizedBox(height: 12),
                  _buildMontantField('Bâtiments', _batimentsCtrl, icon: Icons.home_work),
                  const SizedBox(height: 12),
                  _buildMontantField('Équipements agricoles', _equipementsCtrl, icon: Icons.agriculture),
                  const SizedBox(height: 12),
                  _buildMontantField('Matériel roulant', _materielRoulantCtrl, icon: Icons.local_shipping),
                  const SizedBox(height: 12),
                  _buildMontantField('Mobilier et matériel de bureau', _mobilierCtrl, icon: Icons.chair),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Actifs Immobilisés:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_totalActifsImmobilises.toStringAsFixed(2)} FC',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ACTIFS CIRCULANTS
              _buildSectionCard(
                'ACTIFS CIRCULANTS',
                AppTheme.primaryTurquoise,
                [
                  _buildMontantField('Stocks matières premières', _stocksMatieresCtrl, icon: Icons.inventory_2),
                  const SizedBox(height: 12),
                  _buildMontantField('Stocks produits finis', _stocksProduitsCtrl, icon: Icons.inventory),
                  const SizedBox(height: 12),
                  _buildMontantField('Créances clients', _creancesCtrl, icon: Icons.account_balance_wallet),
                  const SizedBox(height: 12),
                  _buildMontantField('Disponibilités (banque/caisse)', _disponibilitesCtrl, icon: Icons.account_balance),
                  const SizedBox(height: 12),
                  _buildMontantField('Autres actifs circulants', _autresActifsCtrl, icon: Icons.more_horiz),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTurquoise.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Actifs Circulants:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_totalActifsCirculants.toStringAsFixed(2)} FC',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.primaryTurquoise,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // TOTAL GÉNÉRAL
              Card(
                color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL ACTIFS',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tous les actifs de la coopérative',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      Text(
                        '${_totalActifs.toStringAsFixed(2)} FC',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesCtrl,
                decoration: InputDecoration(
                  labelText: 'Notes et observations',
                  hintText: 'Ajoutez des commentaires sur cette évaluation...',
                  prefixIcon: const Icon(Icons.note_add),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // Bouton sauvegarder
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _sauvegarder,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isLoading ? 'Sauvegarde...' : 'Sauvegarder l\'évaluation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
