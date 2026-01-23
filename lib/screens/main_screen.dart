import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import 'search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<String> _photoUrls = [];
  bool _isLoadingPhotos = false;

  @override
  void initState() {
    super.initState();
    _loadPhotosFromServer();
  }

  Future<void> _loadPhotosFromServer() async {
    // Verificăm dacă utilizatorul este autentificat înainte de a încărca fotografiile
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      // Utilizatorul nu e autentificat, nu încărcăm fotografii
      return;
    }
    
    setState(() => _isLoadingPhotos = true);
    try {
      final response = await ApiService.getProfile();
      if (response['success'] == true && response['profile'] != null) {
        final photos = response['profile']['photos'] as List<dynamic>?;
        if (photos != null) {
          setState(() {
            _photoUrls = photos.map((p) => p['url'] as String).toList();
          });
        }
      }
    } catch (e) {
      print('Error loading photos: $e');
    } finally {
      setState(() => _isLoadingPhotos = false);
    }
  }

  void _searchForMatch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Șterge Cont'),
        content: const Text('Ești sigur că vrei să ștergi contul? Această acțiune este PERMANENTĂ și nu poate fi anulată!'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Anulează')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Șterge Cont'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // TODO: Call API to delete account
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.logout();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Eroare la ștergerea contului: $e')),
          );
        }
      }
    }
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final completionPercentage = userProvider.getCompletionPercentage();
    final isVisible = userProvider.isProfileVisible();

    return Scaffold(
      appBar: AppBar(
        title: const Text('DatingX'),
        actions: [
          if (completionPercentage >= 80)
            IconButton(
              icon: const Icon(Icons.search_rounded),
              tooltip: 'Caută Pereche',
              onPressed: _searchForMatch,
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text('Profil: $completionPercentage%', style: const TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
      body: _getBody(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Descoperă'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Compatibilități'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Mesaje'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _getBody(int index) {
    switch (index) {
      case 0:
        return _buildDiscoverTab();
      case 1:
        return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.favorite, size: 64, color: Colors.pink), SizedBox(height: 16), Text('Compatibilitățile tale', style: TextStyle(fontSize: 18))]));
      case 2:
        return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.message, size: 64, color: Colors.pink), SizedBox(height: 16), Text('Mesajele tale', style: TextStyle(fontSize: 18))]));
      case 3:
        return _buildProfileTab();
      default:
        return _buildDiscoverTab();
    }
  }

  Widget _buildDiscoverTab() {
    final userProvider = Provider.of<UserProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isAuthenticated;
    final completionPercentage = userProvider.getCompletionPercentage();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE91E63), // Pink
            Color(0xFF9C27B0), // Purple
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.explore, size: 80, color: Colors.white),
              SizedBox(height: 24),
              Text(
                'Descoperă Perechea Perfectă',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Găsește persoana care ți se potrivește perfect bazat pe compatibilitate reală',
                style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _searchForMatch,
                  icon: Icon(Icons.search, size: 28),
                  label: Text('Caută Perechea Perfectă', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              SizedBox(height: 16),
            
            // Buton Publică Anunț
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  if (authProvider.isAuthenticated) {
                    // Dacă e logat, du-l la completare profil
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                    );
                  } else {
                    // Dacă nu e logat, du-l la login
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  }
                },
                icon: Icon(Icons.add_circle_outline, size: 24),
                label: Text('Publică Anunț Matrimonial', style: TextStyle(fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 18, horizontal: 32),
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    final userProvider = Provider.of<UserProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = userProvider.currentUser;
    final isLoggedIn = authProvider.isAuthenticated;
    final completionPercentage = userProvider.getCompletionPercentage();

    // Dacă nu e logat, arată opțiuni de login/register
    if (!isLoggedIn) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_circle, size: 100, color: Colors.pink[200]),
              SizedBox(height: 24),
              Text(
                'Creează un Profil',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Conectează-te sau creează un cont pentru a-ți completa profilul și a fi vizibil în căutări!',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  icon: Icon(Icons.login, size: 24),
                  label: Text('Conectare / Înregistrare', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Dacă e logat dar profilul e incomplet, arată buton pentru completare
    if (completionPercentage < 80) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment, size: 100, color: Colors.orange[300]),
              SizedBox(height: 24),
              Text(
                'Completează-ți Profilul',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Pentru a fi vizibil în căutări și a găsi perechea perfectă, completează-ți profilul!',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              LinearProgressIndicator(
                value: completionPercentage / 100,
                backgroundColor: Colors.grey[200],
                color: Colors.orange,
                minHeight: 8,
              ),
              SizedBox(height: 8),
              Text(
                'Progres: $completionPercentage%',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange[700]),
              ),
              SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                    _loadPhotosFromServer();
                  },
                  icon: Icon(Icons.edit, size: 24),
                  label: Text('Completează Profilul', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Dacă profilul e complet, arată profilul normal
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Profilul Meu', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                  _loadPhotosFromServer();
                },
                icon: Icon(Icons.edit),
                label: Text('Editare'),
              ),
            ],
          ),
          SizedBox(height: 24),
          
          if (_photoUrls.isNotEmpty) ...[
            Text('Fotografii', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _photoUrls.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _photoUrls[index],
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey[300],
                            child: Icon(Icons.error),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 24),
          ] else if (_isLoadingPhotos) ...[
            Center(child: CircularProgressIndicator()),
            SizedBox(height: 24),
          ],
          
          if (user?.basicIdentity != null) ...[
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Identitate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Text('Gen: ${user!.basicIdentity!.gender}'),
                    Text('Vârstă: ${user.basicIdentity!.age} ani'),
                    Text('Oraș: ${user.basicIdentity!.city}'),
                    Text('Înălțime: ${user.basicIdentity!.height} cm'),
                    Text('Ocupație: ${user.basicIdentity!.occupation}'),
                  ],
                ),
              ),
            ),
          ],
          if (user?.lifestyle != null) ...[
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stil de Viață', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Text('Program: ${user!.lifestyle!.schedule}'),
                    Text('Fumat: ${user.lifestyle!.smoking}'),
                    Text('Alcool: ${user.lifestyle!.alcohol}'),
                    Text('Exerciții: ${user.lifestyle!.exercise}'),
                    Text('Dietă: ${user.lifestyle!.diet}'),
                    Text('Animale: ${user.lifestyle!.pets}'),
                  ],
                ),
              ),
            ),
          ],
          
          SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _searchForMatch,
              icon: Icon(Icons.favorite),
              label: Text('Caută Perechea Potrivită'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _deleteAccount,
              icon: Icon(Icons.delete_forever),
              label: Text('Șterge Cont'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                foregroundColor: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
