import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
import 'profile_setup/basic_identity_screen.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final hasProfile = userProvider.currentUser != null;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('DatingX'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (hasProfile)
            IconButton(
              icon: const Icon(Icons.person),
              tooltip: 'Profil',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditProfileScreen())
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Delogare',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delogare'),
                  content: const Text('Sigur vrei să te deconectezi?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Anulează'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delogare'),
                    ),
                  ],
                ),
              );
              
              if (confirm == true && context.mounted) {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite, size: 100, color: Colors.white),
                const SizedBox(height: 32),
                const Text('DatingX', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                const Text('Compatibilitate Profundă', style: TextStyle(fontSize: 20, color: Colors.white70), textAlign: TextAlign.center),
                const SizedBox(height: 48),
                _FeatureItem(icon: Icons.calculate, text: 'Compatibilitate calculată științific'),
                const SizedBox(height: 16),
                _FeatureItem(icon: Icons.checklist, text: 'Criterii clare de căutare partener'),
                const SizedBox(height: 16),
                _FeatureItem(icon: Icons.verified_user, text: 'Doar profiluri complete (min. 80%)'),
                const SizedBox(height: 48),
                
                // Buton principal - diferit dacă are profil sau nu
                if (hasProfile)
                  Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const EditProfileScreen())
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Editează Profil'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFE91E63),
                          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Profil completat: ${userProvider.currentUser!.completionPercentage()}%',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const BasicIdentityScreen())
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFE91E63),
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Începe Acum', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                const SizedBox(height: 24),
                const Text('18+ only • Conform Google Play', style: TextStyle(fontSize: 12, color: Colors.white60)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16))),
        ],
      ),
    );
  }
}
