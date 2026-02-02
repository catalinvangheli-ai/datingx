import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/user_profile.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/progress_indicator_widget.dart';
import '../../services/api_service.dart';
import '../main_screen.dart';
import 'basic_identity_screen.dart';

class RelationshipTypeScreen extends StatefulWidget {
  const RelationshipTypeScreen({super.key});

  @override
  State<RelationshipTypeScreen> createState() => _RelationshipTypeScreenState();
}

class _RelationshipTypeScreenState extends State<RelationshipTypeScreen> {
  String _relationshipType = '';
  bool _isPublishing = false;

  bool _canContinue() {
    return _relationshipType.isNotEmpty;
  }

  bool _shouldContinueToFullProfile() {
    // Doar pentru aventură ocazională ne oprim aici
    return _relationshipType != '🔥 Aventură / Relație ocazională';
  }

  Future<void> _publishCasualProfile() async {
    setState(() {
      _isPublishing = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // VERIFICARE CRITICĂ: Utilizatorul trebuie să fie autentificat
      if (!authProvider.isAuthenticated || authProvider.currentAuthUser?.id == null) {
        throw Exception('Nu ești autentificat! Te rog să te loghezi din nou.');
      }
      
      print('✅ Casual profile - User authenticated: ${authProvider.currentAuthUser?.email}');
      print('✅ Casual profile - User ID: ${authProvider.currentAuthUser?.id}');

      // Pentru aventură ocazională, salvăm doar tipul de relație
      if (userProvider.currentUser == null) {
        final newUser = UserProfile(
          userId: const Uuid().v4(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        userProvider.setUser(newUser);
      }

      final values = Values(
        relationshipType: _relationshipType,
        familyPlans: '',
        religion: '',
        politics: '',
        money: '',
        careerAmbition: '',
      );

      userProvider.updateValues(values);

      // Salvăm pe server
      final profileData = {
        'userId': authProvider.currentAuthUser?.id,
        'relationshipType': _relationshipType,
        'profileComplete': true,
      };

      print('📤 Casual profile - Salvăm: $profileData');
      final response = await ApiService.saveProfile(profileData);
      print('📥 Casual profile - Răspuns: $response');
      
      if (response['success'] != true) {
        throw Exception('Salvarea a eșuat: ${response['message']}');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '🎉 Profilul tău a fost publicat!\nPoți completa mai multe detalii mai târziu din Setări.',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );

        await Future.delayed(const Duration(seconds: 1));

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

  void _saveAndContinue() {
    if (!_canContinue()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selectează tipul de relație')),
      );
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.currentUser == null) {
      final newUser = UserProfile(
        userId: const Uuid().v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      userProvider.setUser(newUser);
    }

    final values = Values(
      relationshipType: _relationshipType,
      familyPlans: '',
      religion: '',
      politics: '',
      money: '',
      careerAmbition: '',
    );

    userProvider.updateValues(values);

    print('🔍 RelationshipTypeScreen - Salvat relationshipType: $_relationshipType');
    print('🔍 UserProvider currentUser: ${userProvider.currentUser?.toJson()}');

    if (_shouldContinueToFullProfile()) {
      // Continuăm la Basic Identity pentru relații serioase
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const BasicIdentityScreen()),
      );
    } else {
      // Pentru aventură ocazională, publicăm direct
      _publishCasualProfile();
    }
  }

  Widget _buildRelationshipTypeCard(String emoji, String title, String description) {
    final isSelected = _relationshipType == '$emoji $title';
    return InkWell(
      onTap: () => setState(() => _relationshipType = '$emoji $title'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE91E63).withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFFE91E63) : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFE91E63).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFFE91E63) : Colors.black87,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFFE91E63),
                    size: 28,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ce fel de relație cauți?'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileProgressIndicator(currentStep: 1, totalSteps: 6),
            const SizedBox(height: 32),

            const Text(
              'Alege tipul de relație',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Acest lucru ne ajută să îți personalizăm experiența și să te conectăm cu persoane potrivite.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            _buildRelationshipTypeCard(
              '💍',
              'Căsătorie / Relație serioasă pe termen lung',
              'Caut o relație serioasă cu intenție de căsătorie',
            ),
            const SizedBox(height: 16),

            _buildRelationshipTypeCard(
              '❤️',
              'Relație de iubire (fără presiune pentru căsătorie)',
              'Vreau o relație de iubire autentică, dar fără graba căsătoriei',
            ),
            const SizedBox(height: 16),

            _buildRelationshipTypeCard(
              '🤝',
              'Prietenie / Cunoștințe / Discuții',
              'Caut prieteni sau persoane cu care să am conversații interesante',
            ),
            const SizedBox(height: 16),

            _buildRelationshipTypeCard(
              '🔥',
              'Aventură / Relație ocazională',
              'Nu caut ceva serios, doar distracție și momente plăcute',
            ),
            const SizedBox(height: 16),

            _buildRelationshipTypeCard(
              '🎭',
              'Relație deschisă / Non-monogamă',
              'Sunt interesat/ă de relații non-tradiționale',
            ),
            const SizedBox(height: 16),

            _buildRelationshipTypeCard(
              '🤷',
              'Încă nu știu / Deschis la posibilități',
              'Vreau să văd ce apare, fără planuri clare',
            ),
            const SizedBox(height: 32),

            if (_relationshipType == '🔥 Aventură / Relație ocazională')
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pentru aventură ocazională nu este nevoie să completezi toate detaliile. Poți publica profilul direct!',
                        style: TextStyle(fontSize: 14, color: Colors.orange[900]),
                      ),
                    ),
                  ],
                ),
              ),

            if (_relationshipType.isNotEmpty && _relationshipType != '🔥 Aventură / Relație ocazională')
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
                        'Pentru relații serioase, te rugăm să completezi profilul complet pentru a găsi persoane compatibile.',
                        style: TextStyle(fontSize: 14, color: Colors.blue[900]),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_canContinue() && !_isPublishing) ? _saveAndContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isPublishing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _shouldContinueToFullProfile() ? 'Continuă' : 'Publică Profilul',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
