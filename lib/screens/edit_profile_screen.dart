import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
import 'profile_setup/basic_identity_screen.dart';
import 'profile_setup/lifestyle_screen.dart';
import 'profile_setup/personality_screen.dart';
import 'profile_setup/values_screen.dart';
import 'profile_setup/interests_screen.dart';
import 'profile_setup/photos_screen.dart';
import 'profile_setup/partner_criteria_screen.dart';
import 'login_screen.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final profile = userProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editează Profilul'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: profile == null
          ? const Center(child: Text('Nu există profil'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info utilizator
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: const Color(0xFFE91E63),
                            child: Text(
                              authProvider.currentAuthUser?.email[0].toUpperCase() ?? 'U',
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  authProvider.currentAuthUser?.email ?? '',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Profil completat: ${profile.completionPercentage()}%',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Secțiuni editabile
                  Text(
                    'Secțiuni Profil',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildEditSection(
                    context,
                    'Identitate',
                    profile.basicIdentity?.isComplete() ?? false,
                    Icons.person,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BasicIdentityScreen()),
                    ),
                  ),
                  
                  _buildEditSection(
                    context,
                    'Stil de viață',
                    profile.lifestyle?.isComplete() ?? false,
                    Icons.fitness_center,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LifestyleScreen()),
                    ),
                  ),
                  
                  _buildEditSection(
                    context,
                    'Personalitate',
                    profile.personality?.isComplete() ?? false,
                    Icons.psychology,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PersonalityScreen()),
                    ),
                  ),
                  
                  _buildEditSection(
                    context,
                    'Valori',
                    profile.values?.isComplete() ?? false,
                    Icons.favorite,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ValuesScreen()),
                    ),
                  ),
                  
                  _buildEditSection(
                    context,
                    'Interese',
                    profile.interests?.isComplete() ?? false,
                    Icons.interests,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const InterestsScreen()),
                    ),
                  ),
                  
                  _buildEditSection(
                    context,
                    'Fotografii și Bio',
                    profile.photos?.isComplete() ?? false,
                    Icons.photo_camera,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PhotosScreen()),
                    ),
                  ),
                  
                  _buildEditSection(
                    context,
                    'Criterii Partener',
                    profile.partnerCriteria?.isComplete() ?? false,
                    Icons.search,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PartnerCriteriaScreen()),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Buton salvare
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final saved = await authProvider.saveUserProfile(profile);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(saved 
                                  ? 'Profil salvat cu succes!' 
                                  : 'Eroare la salvarea profilului'),
                              backgroundColor: saved ? Colors.green : Colors.red,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Salvează Modificările'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E63),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Buton ștergere profil
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Șterge Profilul'),
                            content: const Text(
                              'Sigur vrei să ștergi profilul? Vei pierde toate informațiile completate, dar contul tău va rămâne activ.'
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Anulează'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Șterge'),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirm == true && context.mounted) {
                          final deleted = await authProvider.deleteUserProfile();
                          if (deleted && context.mounted) {
                            // Creează un profil nou gol
                            final newProfile = UserProfile(
                              userId: authProvider.currentAuthUser!.id,
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                            );
                            userProvider.setUser(newProfile);
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profil șters cu succes!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            
                            Navigator.pop(context);
                          }
                        }
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Șterge Profil'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Buton ștergere cont
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Șterge Contul'),
                            content: const Text(
                              'ATENȚIE! Această acțiune va șterge permanent contul și toate datele asociate. Nu poți anula această acțiune!'
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Anulează'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Șterge Definitiv'),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirm == true && context.mounted) {
                          final deleted = await authProvider.deleteAccount();
                          if (deleted && context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cont șters cu succes!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Șterge Cont Permanent'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEditSection(
    BuildContext context,
    String title,
    bool isComplete,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icon,
          color: isComplete ? Colors.green : Colors.grey,
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isComplete ? Icons.check_circle : Icons.cancel,
              color: isComplete ? Colors.green : Colors.red,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
