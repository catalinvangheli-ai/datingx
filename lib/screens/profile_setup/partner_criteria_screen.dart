import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/progress_indicator_widget.dart';
import '../../services/api_service.dart';
import '../main_screen.dart';

class PartnerCriteriaScreen extends StatefulWidget {
  const PartnerCriteriaScreen({super.key});

  @override
  State<PartnerCriteriaScreen> createState() => _PartnerCriteriaScreenState();
}

class _PartnerCriteriaScreenState extends State<PartnerCriteriaScreen> {
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

  bool _isPublishing = false;

  Future<void> _publishProfile() async {
    if (!_canContinue()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Selectează cel puțin un criteriu (deal-breaker sau must-have)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isPublishing = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Salvăm criteriile partenerului
      final criteria = PartnerCriteria(
        ageRange: '',
        maxDistance: 0,
        dealBreakers: _dealBreakers.toList(),
        mustHaves: _mustHaves.toList(),
      );
      
      userProvider.updatePartnerCriteria(criteria);
      
      // Verificăm completarea profilului
      final completionPercent = userProvider.currentUser?.completionPercentage() ?? 0;
      
      if (completionPercent < 80) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚠️ Profil completat doar $completionPercent%. Minim necesar: 80%'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        setState(() {
          _isPublishing = false;
        });
        return;
      }
      
      // Construim datele complete ale profilului pentru salvare
      final profile = userProvider.currentUser;
      final profileData = {
        'userId': authProvider.currentAuthUser?.id,
        // Basic Identity
        'name': profile?.basicIdentity?.name,
        'age': profile?.basicIdentity?.age,
        'gender': profile?.basicIdentity?.gender,
        'country': profile?.basicIdentity?.country,
        'city': profile?.basicIdentity?.city,
        'occupation': profile?.basicIdentity?.occupation,
        'phoneNumber': profile?.basicIdentity?.phoneNumber,
        
        // Lifestyle
        'smokingHabit': profile?.lifestyle?.smoking,
        'drinkingHabit': profile?.lifestyle?.alcohol,
        'fitnessLevel': profile?.lifestyle?.exercise,
        'diet': profile?.lifestyle?.diet,
        'petPreference': profile?.lifestyle?.pets,
        
        // Personality (dacă există)
        'introvertExtrovert': profile?.personality?.socialType,
        'spontaneousPlanned': profile?.personality?.emotionalPace,
        'creativeAnalytical': profile?.personality?.conflictStyle,
        
        // Values (dacă există)
        'relationshipType': profile?.intention?.relationshipGoal,
        'wantsChildren': profile?.values?.familyPlans,
        'religionImportance': profile?.values?.religion,
        'politicalAlignment': profile?.values?.politics,
        
        // Interests
        'interests': profile?.interests?.hobbies,
        
        // Photos
        'photos': profile?.photos?.photoUrls.map((url) {
          return {
            'url': url,
            'cloudinaryId': url.split('/').last.split('.').first, // Extract ID from URL
          };
        }).toList(),
        
        // Bio
        'bio': profile?.photos?.bio,
        
        // Partner Criteria - doar deal-breakers (vârsta și genul se aleg la căutare)
        'dealBreakers': _dealBreakers.toList(),
        'mustHaves': _mustHaves.toList(),
        
        // Metadata
        'profileComplete': true, // Marcăm profilul ca fiind complet și publicat
      };
      
      print('📤 Publicăm profilul cu datele: ${profileData.toString()}');
      
      // Salvăm profilul pe server
      final response = await ApiService.saveProfile(profileData);
      
      print('✅ Răspuns server la publicare: ${response.toString()}');
      
      if (context.mounted) {
        // Arătăm mesaj de succes
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '🎉 Anunțul tău matrimonial a fost publicat cu succes!\nAcum poți fi găsit/ă de alți utilizatori.',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
        
        // Așteptăm puțin să vadă mesajul
        await Future.delayed(const Duration(seconds: 1));
        
        // Mergem la Main Screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
      }
      
    } catch (e) {
      print('❌ Eroare la publicarea profilului: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Eroare la publicare: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
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
              'Criterii Partener',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Definește ce NU accepți și ce este OBLIGATORIU la un partener.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              '💡 Criteriile de vârstă, gen și locație le vei alege când cauți profiluri.',
              style: TextStyle(fontSize: 13, color: Colors.blue[700], fontStyle: FontStyle.italic),
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
                      'Aceste criterii te ajută să definești ce vrei și ce nu vrei la un partener. Persoanele cu deal-breakers nu vor apărea în căutările tale.',
                      style: TextStyle(fontSize: 14, color: Colors.blue[900]),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Buton mare de publicare
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _isPublishing ? null : _publishProfile,
                icon: _isPublishing 
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.celebration, size: 28),
                label: Text(
                  _isPublishing ? 'Se publică...' : '🎉 Publică Anunțul Matrimonial',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63), // Pink
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Buton înapoi mai mic
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isPublishing ? null : () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Înapoi la Fotografii'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
