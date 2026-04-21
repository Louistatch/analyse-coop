import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/cooperative.dart';
import '../models/evaluation_passifs.dart';
import '../providers/app_provider.dart';
import '../utils/app_theme.dart';

class EvaluationPassifsScreen extends StatefulWidget {
  final Cooperative cooperative;
  final EvaluationPassifs? evaluation; // Pour modification

  const EvaluationPassifsScreen({
    super.key,
    required this.cooperative,
    this.evaluation,
  });

  @override
  State<EvaluationPassifsScreen> createState() => _EvaluationPassifsScreenState();
}

class _EvaluationPassifsScreenState extends State<EvaluationPassifsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Capitaux propres
  final TextEditingController _capitalSocialCtrl = TextEditingController();
  final TextEditingController _reservesStatutairesCtrl = TextEditingController();
  final TextEditingController _reservesFacultativesCtrl = TextEditingController();
  final TextEditingController _resultatExerciceCtrl = TextEditingController();

  // Dettes long terme
  final TextEditingController _empruntsLongTermeCtrl = TextEditingController();
  final TextEditingController _autresDettesLongTermeCtrl = TextEditingController();

  // Dettes court terme
  final TextEditingController _empruntsCourtTermeCtrl = TextEditingController();
  final TextEditingController _dettesFournisseursCtrl = TextEditingController();
  final TextEditingController _dettesFiscalesCtrl = TextEditingController();
  final TextEditingController _dettesSocialesCtrl = TextEditingController();
  final TextEditingController _autresPassifsCtrl = TextEditingController();

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
    _capitalSocialCtrl.text = eval.capitalSocial.toString();
    _reservesStatutairesCtrl.text = eval.reservesStatutaires.toString();
    _reservesFacultativesCtrl.text = eval.reservesFacultatives.toString();
    _resultatExerciceCtrl.text = eval.resultatExercice.toString();
    _empruntsLongTermeCtrl.text = eval.empruntsLongTerme.toString();
    _autresDettesLongTermeCtrl.text = eval.autresDettesLongTerme.toString();
    _empruntsCourtTermeCtrl.text = eval.empruntsCourtTerme.toString();
    _dettesFournisseursCtrl.text = eval.dettesFournisseurs.toString();
    _dettesFiscalesCtrl.text = eval.dettesFiscales.toString();
    _dettesSocialesCtrl.text = eval.dettesSociales.toString();
    _autresPassifsCtrl.text = eval.autresPassifsCirculants.toString();
    _notesCtrl.text = eval.notes ?? '';
    _dateEvaluation = eval.dateEvaluation;
  }

  @override
  void dispose() {
    _capitalSocialCtrl.dispose();
    _reservesStatutairesCtrl.dispose();
    _reservesFacultativesCtrl.dispose();
    _resultatExerciceCtrl.dispose();
    _empruntsLongTermeCtrl.dispose();
    _autresDettesLongTermeCtrl.dispose();
    _empruntsCourtTermeCtrl.dispose();
    _dettesFournisseursCtrl.dispose();
    _dettesFiscalesCtrl.dispose();
    _dettesSocialesCtrl.dispose();
    _autresPassifsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double _parseDouble(String text) {
    if (text.isEmpty) return 0.0;
    return double.tryParse(text.replaceAll(',', '.')) ?? 0.0;
  }

  double get _totalCapitauxPropres {
    return _parseDouble(_capitalSocialCtrl.text) +
        _parseDouble(_reservesStatutairesCtrl.text) +
        _parseDouble(_reservesFacultativesCtrl.text) +
        _parseDouble(_resultatExerciceCtrl.text);
  }

  double get _totalDettesLongTerme {
    return _parseDouble(_empruntsLongTermeCtrl.text) +
        _parseDouble(_autresDettesLongTermeCtrl.text);
  }

  double get _totalDettesCourtTerme {
    return _parseDouble(_empruntsCourtTermeCtrl.text) +
        _parseDouble(_dettesFournisseursCtrl.text) +
        _parseDouble(_dettesFiscalesCtrl.text) +
        _parseDouble(_dettesSocialesCtrl.text) +
        _parseDouble(_autresPassifsCtrl.text);
  }

  double get _totalPassifs {
    return _totalCapitauxPropres + _totalDettesLongTerme + _totalDettesCourtTerme;
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
      final evaluation = EvaluationPassifs(
        id: widget.evaluation?.id ?? 'EVAL_P_${DateTime.now().millisecondsSinceEpoch}',
        cooperativeId: widget.cooperative.code,
        dateEvaluation: _dateEvaluation,
        capitalSocial: _parseDouble(_capitalSocialCtrl.text),
        reservesStatutaires: _parseDouble(_reservesStatutairesCtrl.text),
        reservesFacultatives: _parseDouble(_reservesFacultativesCtrl.text),
        resultatExercice: _parseDouble(_resultatExerciceCtrl.text),
        empruntsLongTerme: _parseDouble(_empruntsLongTermeCtrl.text),
        autresDettesLongTerme: _parseDouble(_autresDettesLongTermeCtrl.text),
        empruntsCourtTerme: _parseDouble(_empruntsCourtTermeCtrl.text),
        dettesFournisseurs: _parseDouble(_dettesFournisseursCtrl.text),
        dettesFiscales: _parseDouble(_dettesFiscalesCtrl.text),
        dettesSociales: _parseDouble(_dettesSocialesCtrl.text),
        autresPassifsCirculants: _parseDouble(_autresPassifsCtrl.text),
        notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
      );

      if (widget.evaluation == null) {
        await provider.ajouterEvaluationPassifs(evaluation);
      } else {
        await provider.modifierEvaluationPassifs(evaluation);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Évaluation des passifs sauvegardée'),
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
        prefixIcon: icon != null ? Icon(icon, color: AppTheme.primaryPink) : null,
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
            Text(widget.evaluation == null ? 'Nouvelle Évaluation des Passifs' : 'Modifier Évaluation'),
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
                color: AppTheme.primaryPink.withValues(alpha: 0.1),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today, color: AppTheme.primaryPink),
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

              // CAPITAUX PROPRES
              _buildSectionCard(
                'CAPITAUX PROPRES',
                AppTheme.primaryPurple,
                [
                  _buildMontantField('Capital social', _capitalSocialCtrl, icon: Icons.account_balance),
                  const SizedBox(height: 12),
                  _buildMontantField('Réserves statutaires', _reservesStatutairesCtrl, icon: Icons.shield),
                  const SizedBox(height: 12),
                  _buildMontantField('Réserves facultatives', _reservesFacultativesCtrl, icon: Icons.savings),
                  const SizedBox(height: 12),
                  _buildMontantField('Résultat de l\'exercice', _resultatExerciceCtrl, icon: Icons.trending_up),
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
                          'Total Capitaux Propres:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_totalCapitauxPropres.toStringAsFixed(2)} FC',
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

              // DETTES LONG TERME
              _buildSectionCard(
                'DETTES À LONG TERME',
                AppTheme.primaryOrange,
                [
                  _buildMontantField('Emprunts à long terme', _empruntsLongTermeCtrl, icon: Icons.credit_card),
                  const SizedBox(height: 12),
                  _buildMontantField('Autres dettes à long terme', _autresDettesLongTermeCtrl, icon: Icons.more_horiz),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Dettes Long Terme:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_totalDettesLongTerme.toStringAsFixed(2)} FC',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.primaryOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // DETTES COURT TERME
              _buildSectionCard(
                'DETTES À COURT TERME',
                AppTheme.primaryTurquoise,
                [
                  _buildMontantField('Emprunts à court terme', _empruntsCourtTermeCtrl, icon: Icons.schedule),
                  const SizedBox(height: 12),
                  _buildMontantField('Dettes fournisseurs', _dettesFournisseursCtrl, icon: Icons.store),
                  const SizedBox(height: 12),
                  _buildMontantField('Dettes fiscales', _dettesFiscalesCtrl, icon: Icons.account_balance_wallet),
                  const SizedBox(height: 12),
                  _buildMontantField('Dettes sociales', _dettesSocialesCtrl, icon: Icons.people),
                  const SizedBox(height: 12),
                  _buildMontantField('Autres passifs circulants', _autresPassifsCtrl, icon: Icons.more_horiz),
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
                          'Total Dettes Court Terme:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_totalDettesCourtTerme.toStringAsFixed(2)} FC',
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
                color: AppTheme.primaryPink.withValues(alpha: 0.1),
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
                            'TOTAL PASSIFS',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tous les passifs de la coopérative',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      Text(
                        '${_totalPassifs.toStringAsFixed(2)} FC',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: AppTheme.primaryPink,
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
                    backgroundColor: AppTheme.primaryPink,
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
