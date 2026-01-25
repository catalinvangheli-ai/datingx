import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile.dart';
import '../../providers/user_provider.dart';
import '../../widgets/progress_indicator_widget.dart';
import 'interests_screen.dart';

class ValuesScreen extends StatefulWidget {
  const ValuesScreen({super.key});

  @override
  State<ValuesScreen> createState() => _ValuesScreenState();
}

class _ValuesScreenState extends State<ValuesScreen> {
  String _relationshipType = '';
  String _familyPlans = '';
  String _religion = '';
  String _politics = '';
  String _money = '';
  String _careerAmbition = '';

  bool _canContinue() {
    return _relationshipType.isNotEmpty &&
           _familyPlans.isNotEmpty && 
           _religion.isNotEmpty && 
           _politics.isNotEmpty && 
           _money.isNotEmpty && 
           _careerAmbition.isNotEmpty;
  }

  void _saveAndContinue() {
    if (_canContinue()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      final values = Values(
        relationshipType: _relationshipType,
        familyPlans: _familyPlans,
        religion: _religion,
        politics: _politics,
        money: _money,
        careerAmbition: _careerAmbition,
      );
      
      userProvider.updateValues(values);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const InterestsScreen())
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
        title: const Text('Valori'),
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
            const ProfileProgressIndicator(currentStep: 4, totalSteps: 6),
            const SizedBox(height: 32),
            
            _buildSection(
              'Ce fel de relație cauți? ❤️',
              [
                '💍 Căsătorie / Relație serioasă pe termen lung',
                '❤️ Relație de iubire (fără presiune pentru căsătorie)',
                '🤝 Prietenie / Cunoștințe / Discuții',
                '😊 Relație casual / Fără angajament',
                '🔥 Aventură / Relație ocazională',
                '🎭 Relație deschisă / Non-monogamă',
                '🤷 Încă nu știu / Deschis la posibilități',
              ],
              _relationshipType,
              (value) => setState(() => _relationshipType = value),
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              'Planuri de familie',
              [
                'vreau copii în viitorul apropiat',
                'vreau copii dar mai târziu',
                'nu sunt sigur/ă',
                'nu vreau copii niciodată',
              ],
              _familyPlans,
              (value) => setState(() => _familyPlans = value),
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              'Religie',
              [
                'foarte important pentru mine',
                'moderat important',
                'nu prea important',
                'deloc important',
              ],
              _religion,
              (value) => setState(() => _religion = value),
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              'Politică',
              [
                'discutăm deschis și respectuos',
                'preferăm să evităm subiectul',
                'trebuie să avem aceleași vederi',
              ],
              _politics,
              (value) => setState(() => _politics = value),
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              'Viziune despre bani',
              [
                'economiși/planificare pe termen lung',
                'echilibrat',
                'trăiesc clipa/spontan',
              ],
              _money,
              (value) => setState(() => _money = value),
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              'Ambiție carieră',
              [
                'cariera este prioritatea #1',
                'echilibru muncă-viață personală',
                'viața personală mai importantă',
              ],
              _careerAmbition,
              (value) => setState(() => _careerAmbition = value),
            ),
            
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
                      backgroundColor: _canContinue() ? Colors.red : null,
                      foregroundColor: _canContinue() ? Colors.white : null,
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
        ...options.map((option) {
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: selected,
            onChanged: (value) {
              if (value != null) onSelected(value);
            },
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ],
    );
  }
}
