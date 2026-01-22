import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/progress_indicator_widget.dart';
import '../main_screen.dart';

class PartnerCriteriaScreen extends StatefulWidget {
  const PartnerCriteriaScreen({super.key});

  @override
  State<PartnerCriteriaScreen> createState() => _PartnerCriteriaScreenState();
}

class _PartnerCriteriaScreenState extends State<PartnerCriteriaScreen> {
  RangeValues _ageRange = const RangeValues(25, 35);
  double _maxDistance = 50;
  final Set<String> _dealBreakers = {};
  final Set<String> _mustHaves = {};
  
  final List<String> _dealBreakerOptions = [
    'Fumează',
    'Nu vrea copii',
    'Necasătorit/ă anterior',
    'Are copii',
    'Nu are job stabil',
    'Locuiește cu părinții',
  ];

  final List<String> _mustHaveOptions = [
    'Educație superioară',
    'Job stabil',
    'Mașină',
    'Locuință proprie',
    'Aceleași valori religioase',
    'Stil de viață activ',
    'Pasiune comună',
  ];

  bool _canContinue() {
    return _dealBreakers.isNotEmpty || _mustHaves.isNotEmpty;
  }

  void _saveAndFinish() async {
    if (_canContinue()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final criteria = PartnerCriteria(
        ageRange: '${_ageRange.start.toInt()}-${_ageRange.end.toInt()}',
        maxDistance: _maxDistance.toInt(),
        dealBreakers: _dealBreakers.toList(),
        mustHaves: _mustHaves.toList(),
      );
      
      userProvider.updatePartnerCriteria(criteria);
      
      // Verificăm procentul de completare
      final completionPercent = userProvider.currentUser?.completionPercentage() ?? 0;
      
      if (completionPercent >= 80) {
        // Salvăm profilul în storage
        final saved = await authProvider.saveUserProfile(userProvider.currentUser!);
        
        if (saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil salvat cu succes!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        
        // Profil valid, mergem la Main Screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
      } else {
        // Profil incomplet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil completat $completionPercent%. Minim necesar: 80%'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selectează cel puțin un criteriu (deal-breaker sau must-have)'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criterii Partener'),
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
            const ProfileProgressIndicator(currentStep: 7, totalSteps: 7),
            const SizedBox(height: 32),
            
            Text(
              'Vârsta partenerului',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${_ageRange.start.toInt()} - ${_ageRange.end.toInt()} ani',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            RangeSlider(
              values: _ageRange,
              min: 18,
              max: 80,
              divisions: 62,
              labels: RangeLabels(
                _ageRange.start.toInt().toString(),
                _ageRange.end.toInt().toString(),
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _ageRange = values;
                });
              },
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Distanță maximă',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${_maxDistance.toInt()} km',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            Slider(
              value: _maxDistance,
              min: 5,
              max: 200,
              divisions: 39,
              label: '${_maxDistance.toInt()} km',
              onChanged: (value) {
                setState(() {
                  _maxDistance = value;
                });
              },
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'Deal-breakers (inacceptabil)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _dealBreakerOptions.map((option) {
                final isSelected = _dealBreakers.contains(option);
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  selectedColor: Colors.red[100],
                  checkmarkColor: Colors.red[900],
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _dealBreakers.add(option);
                      } else {
                        _dealBreakers.remove(option);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'Must-haves (obligatoriu)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _mustHaveOptions.map((option) {
                final isSelected = _mustHaves.contains(option);
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  selectedColor: Colors.green[100],
                  checkmarkColor: Colors.green[900],
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _mustHaves.add(option);
                      } else {
                        _mustHaves.remove(option);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 32),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Criteriile tale vor fi folosite pentru calcularea compatibilității. Persoanele care nu îndeplinesc deal-breakers-urile nu vor apărea în rezultate.',
                      style: TextStyle(fontSize: 14, color: Colors.blue[900]),
                    ),
                  ),
                ],
              ),
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
                    onPressed: _canContinue() ? _saveAndFinish : null,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Finalizează Profil'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
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
