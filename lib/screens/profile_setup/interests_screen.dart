import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/progress_indicator_widget.dart';
import '../../services/api_service.dart';
import '../main_screen.dart';

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

  bool _isSaving = false;

  Future<void> _saveProfile() async {
    if (!_canContinue()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selectează minim 3 hobby-uri, gen muzical și atitudine călătorii'))
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Salvăm interests
      final interests = Interests(
        hobbies: _selectedHobbies.toList(),
        musicTaste: _selectedMusic.toList(),
        travelAttitude: _selectedTravel.first,
      );
      
      userProvider.updateInterests(interests);
      
      print('🔍 InterestsScreen - Salvat interests');
      print('🔍 Relationship type: ${userProvider.currentUser?.values?.relationshipType}');
      
      // Salvăm profilul pe server
      final profile = userProvider.currentUser;
      final profileData = {
        'userId': authProvider.currentAuthUser?.id,
        // Basic Identity
        'name': profile?.basicIdentity?.name ?? '',
        'age': profile?.basicIdentity?.age ?? 18,
        'gender': profile?.basicIdentity?.gender ?? '',
        'country': profile?.basicIdentity?.country ?? '',
        'city': profile?.basicIdentity?.city ?? '',
        'height': profile?.basicIdentity?.height ?? 170,
        'occupation': profile?.basicIdentity?.occupation ?? '',
        'phoneNumber': profile?.basicIdentity?.phoneNumber ?? '',
        
        // Lifestyle
        'schedule': profile?.lifestyle?.schedule ?? '',
        'smokingHabit': profile?.lifestyle?.smoking ?? '',
        'drinkingHabit': profile?.lifestyle?.alcohol ?? '',
        'fitnessLevel': profile?.lifestyle?.exercise ?? '',
        'diet': profile?.lifestyle?.diet ?? '',
        'petPreference': profile?.lifestyle?.pets ?? '',
        
        // Personality
        'introvertExtrovert': profile?.personality?.socialType ?? '',
        'spontaneousPlanned': profile?.personality?.emotionalPace ?? '',
        'creativeAnalytical': profile?.personality?.conflictStyle ?? '',
        'personalSpace': profile?.personality?.personalSpace ?? '',
        
        // Values
        'relationshipType': profile?.values?.relationshipType ?? '',
        'wantsChildren': profile?.values?.familyPlans ?? '',
        'religionImportance': profile?.values?.religion ?? '',
        'politicalAlignment': profile?.values?.politics ?? '',
        'moneyManagement': profile?.values?.money ?? '',
        'careerAmbition': profile?.values?.careerAmbition ?? '',
        
        // Interests
        'interests': profile?.interests?.hobbies ?? [],
        'musicTaste': profile?.interests?.musicTaste ?? [],
        'travelAttitude': profile?.interests?.travelAttitude ?? '',
        
        // Metadata
        'profileComplete': false, // Nu e anunț, doar profil
      };
      
      print('📤 Salvăm profilul...');
      final response = await ApiService.saveProfile(profileData);
      
      if (response['success'] != true) {
        throw Exception('Salvarea a eșuat: ${response['message']}');
      }
      
      print('✅ Profil salvat cu succes!');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '✅ Detaliile profilului au fost salvate!',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Revenim la ecranul anterior (AdPostingScreen sau MainScreen)
        Navigator.pop(context);
      }
    } catch (e) {
      print('❌ Eroare la salvarea profilului: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Eroare la salvare: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
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
            const ProfileProgressIndicator(currentStep: 6, totalSteps: 6),
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
                    onPressed: _isSaving ? null : _saveProfile,
                    icon: _isSaving 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.save),
                    label: Text(_isSaving ? 'Se salvează...' : 'Salvează Profilul'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _canContinue() && !_isSaving ? const Color(0xFFE91E63) : null,
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
