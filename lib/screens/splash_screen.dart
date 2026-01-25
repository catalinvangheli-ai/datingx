import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import 'main_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadProfile();
  }

  Future<void> _checkAuthAndLoadProfile() async {
    print('🔍 Checking authentication and loading profile...');
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Încarcă utilizatorul (verifică token salvat)
    await authProvider.loadCurrentUser();
    
    // Dacă e autentificat, încarcă profilul de pe server
    if (authProvider.isAuthenticated) {
      print('✅ User is authenticated, loading profile from server...');
      
      try {
        final profileData = await authProvider.loadUserProfileFromServer();
        if (profileData != null) {
          print('📥 Profile data received: ${profileData.keys}');
          print('🔍 relationshipType in data: ${profileData['relationshipType']}');
          print('🔍 wantsChildren in data: ${profileData['wantsChildren']}');
          userProvider.loadUserProfileFromServer(profileData);
          print('✅ Profile loaded. Completion: ${userProvider.getCompletionPercentage()}%');
          print('🔍 relationshipType after load: ${userProvider.currentUser?.values?.relationshipType}');
        } else {
          print('⚠️ No profile found on server');
        }
      } catch (e) {
        print('❌ Error loading profile: $e');
      }
    } else {
      print('⚠️ User not authenticated');
    }
    
    // Navighează după 1 secundă (pentru a arăta logo-ul)
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      // Mergi la MainScreen (funcționează și fără autentificare)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE91E63),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            const Text(
              'DatingX',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Compatibilitate Profundă',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
