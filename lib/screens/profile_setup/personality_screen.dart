import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile.dart';
import '../../providers/user_provider.dart';
import '../../widgets/progress_indicator_widget.dart';
import 'values_screen.dart';

class PersonalityScreen extends StatefulWidget {
  const PersonalityScreen({super.key});

  @override
  State<PersonalityScreen> createState() => _PersonalityScreenState();
}

class _PersonalityScreenState extends State<PersonalityScreen> {
  String _socialType = '';
  String _conflictStyle = '';
  String _emotionalPace = '';
  String _personalSpace = '';

  bool _canContinue() {
    return _socialType.isNotEmpty && 
           _conflictStyle.isNotEmpty && 
           _emotionalPace.isNotEmpty && 
           _personalSpace.isNotEmpty;
  }

  void _saveAndContinue() {
    if (_canContinue()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      final personality = Personality(
        socialType: _socialType,
        conflictStyle: _conflictStyle,
        emotionalPace: _emotionalPace,
        personalSpace: _personalSpace,
      );
      
      userProvider.updatePersonality(personality);
      
      print('🔍 PersonalityScreen - Salvat personality');
      print('🔍 Relationship type: ${userProvider.currentUser?.values?.relationshipType}');
      
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ValuesScreen())
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
        title: const Text('Personalitate'),
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
              'Tipul social',
              [
                'extrovertit (energie din interacțiuni)',
                'ambivertit (echilibrat)',
                'introvertit (energie din timp singur)',
              ],
              _socialType,
              (value) => setState(() => _socialType = value),
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              'Stil de rezolvare conflicte',
              [
                'discuție calmă imediată',
                'timp de gândire apoi discuție',
                'evitare și trecere peste',
              ],
              _conflictStyle,
              (value) => setState(() => _conflictStyle = value),
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              'Ritm emoțional',
              [
                'exprim imediat ce simt',
                'procesez intern apoi împărtășesc',
                'prefer să nu vorbesc despre emoții',
              ],
              _emotionalPace,
              (value) => setState(() => _emotionalPace = value),
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              'Spațiu personal',
              [
                'am nevoie de mult timp singur',
                'echilibrat între timp împreună/separat',
                'prefer să petrec majoritatea timpului împreună',
              ],
              _personalSpace,
              (value) => setState(() => _personalSpace = value),
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
