import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile.dart';
import '../../providers/user_provider.dart';
import '../../widgets/progress_indicator_widget.dart';
import 'photos_screen.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final Set<String> _selectedHobbies = {};
  final Set<String> _selectedMusic = {};
  final Set<String> _selectedTravel = {};
  
  final List<String> _hobbiesOptions = [
    'Citit',
    'Sport',
    'Gaming',
    'Gătit',
    'Arte',
    'Fotografie',
    'Dans',
    'Muzică',
    'Filme/Seriale',
    'Călătorii',
    'Natură',
    'Tehnologie',
  ];

  final List<String> _musicOptions = [
    'Pop',
    'Rock',
    'Hip-hop',
    'Electronica',
    'Jazz',
    'Clasică',
    'Manele',
    'Folk',
  ];

  final List<String> _travelOptions = [
    'iubesc să călătoresc constant',
    'câteva călătorii pe an',
    'ocazional',
    'prefer să stau acasă',
  ];

  bool _canContinue() {
    return _selectedHobbies.length >= 3 && 
           _selectedMusic.isNotEmpty && 
           _selectedTravel.isNotEmpty;
  }

  void _saveAndContinue() {
    if (_canContinue()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      final interests = Interests(
        hobbies: _selectedHobbies.toList(),
        musicTaste: _selectedMusic.toList(),
        travelAttitude: _selectedTravel.first,
      );
      
      userProvider.updateInterests(interests);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PhotosScreen())
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selectează minim 3 hobby-uri, gen muzical și atitudine călătorii'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interese'),
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
            const ProfileProgressIndicator(currentStep: 5, totalSteps: 7),
            const SizedBox(height: 32),
            
            Text(
              'Hobby-uri (alege minim 3)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _hobbiesOptions.map((hobby) {
                final isSelected = _selectedHobbies.contains(hobby);
                return FilterChip(
                  label: Text(hobby),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedHobbies.add(hobby);
                      } else {
                        _selectedHobbies.remove(hobby);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Genuri muzicale preferate',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _musicOptions.map((music) {
                final isSelected = _selectedMusic.contains(music);
                return FilterChip(
                  label: Text(music),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedMusic.add(music);
                      } else {
                        _selectedMusic.remove(music);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Atitudine față de călătorii',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._travelOptions.map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: _selectedTravel.isNotEmpty ? _selectedTravel.first : null,
                onChanged: (value) {
                  setState(() {
                    _selectedTravel.clear();
                    if (value != null) _selectedTravel.add(value);
                  });
                },
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
            
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
}
