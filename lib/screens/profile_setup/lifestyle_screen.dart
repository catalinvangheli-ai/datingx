import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile.dart';
import '../../providers/user_provider.dart';
import '../../widgets/progress_indicator_widget.dart';
import 'personality_screen.dart';

class LifestyleScreen extends StatefulWidget {
  const LifestyleScreen({super.key});

  @override
  State<LifestyleScreen> createState() => _LifestyleScreenState();
}

class _LifestyleScreenState extends State<LifestyleScreen> {
  String _schedule = '';
  String _smoking = '';
  String _alcohol = '';
  String _exercise = '';
  String _diet = '';
  String _pets = '';

  bool _canContinue() {
    return _schedule.isNotEmpty && 
           _smoking.isNotEmpty && 
           _alcohol.isNotEmpty && 
           _exercise.isNotEmpty && 
           _diet.isNotEmpty && 
           _pets.isNotEmpty;
  }

  void _saveAndContinue() {
    if (_canContinue()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      final lifestyle = Lifestyle(
        schedule: _schedule,
        smoking: _smoking,
        alcohol: _alcohol,
        exercise: _exercise,
        diet: _diet,
        pets: _pets,
      );
      
      userProvider.updateLifestyle(lifestyle);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PersonalityScreen())
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completează toate câmpurile'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stil de Viață'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileProgressIndicator(currentStep: 2, totalSteps: 7),
            const SizedBox(height: 32),
            _buildSection('Program', ['program flexibil', 'program fix 9-5', 'ture de noapte'], _schedule, (value) => setState(() => _schedule = value)),
            const SizedBox(height: 24),
            _buildSection('Fumat', ['niciodată', 'ocazional', 'regulat'], _smoking, (value) => setState(() => _smoking = value)),
            const SizedBox(height: 24),
            _buildSection('Alcool', ['niciodată', 'social', 'regulat'], _alcohol, (value) => setState(() => _alcohol = value)),
            const SizedBox(height: 24),
            _buildSection('Exerciții', ['niciodată', '1-2x/săptămână', '3-4x/săptămână', 'zilnic'], _exercise, (value) => setState(() => _exercise = value)),
            const SizedBox(height: 24),
            _buildSection('Dietă', ['orice', 'vegetarian', 'vegan', 'pescatarian'], _diet, (value) => setState(() => _diet = value)),
            const SizedBox(height: 24),
            _buildSection('Animale', ['am câini', 'am pisici', 'nu am dar îmi plac', 'nu vreau'], _pets, (value) => setState(() => _pets = value)),
            const SizedBox(height: 32),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Înapoi'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _canContinue() ? _saveAndContinue : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Continuă'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> options, String selected, Function(String) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            return ChoiceChip(label: Text(option), selected: selected == option, onSelected: (isSelected) {
              if (isSelected) onSelected(option);
            });
          }).toList(),
        ),
      ],
    );
  }
}
