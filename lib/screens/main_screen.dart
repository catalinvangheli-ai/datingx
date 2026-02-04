import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import 'search_screen.dart';
import 'ad_posting_screen.dart';
import 'photo_gallery_screen.dart';
import 'ad_detail_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<dynamic> _myAds = [];
  bool _isLoadingAds = false;

  @override
  void initState() {
    super.initState();
    _loadProfileFromServer();
    _loadMyAds();
  }

  Future<void> _loadProfileFromServer() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (!authProvider.isAuthenticated) {
      return;
    }
    
    try {
      print('🔄 MainScreen - Încărcăm profilul de pe server...');
      final profileData = await authProvider.loadUserProfileFromServer();
      if (profileData != null) {
        userProvider.loadUserProfileFromServer(profileData);
        print('✅ MainScreen - Profil încărcat! Completion: ${userProvider.getCompletionPercentage()}%');
        print('🔍 MainScreen - relationshipType: ${userProvider.currentUser?.values?.relationshipType}');
      }
    } catch (e) {
      print('❌ MainScreen - Eroare la încărcarea profilului: $e');
    }
  }

  Future<void> _loadMyAds() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      return;
    }
    
    setState(() => _isLoadingAds = true);
    try {
      final response = await ApiService.getMyAds();
      if (response['success'] == true && response['ads'] != null) {
        setState(() {
          _myAds = response['ads'];
        });
      }
    } catch (e) {
      print('Error loading ads: $e');
    } finally {
      setState(() => _isLoadingAds = false);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('DatingX'),
        actions: [
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
        return _buildFavoritesTab();
      case 2:
        return _buildMessagesTab();
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
                    // Dacă e logat, du-l la postare anunț
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdPostingScreen()),
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
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isAuthenticated;

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
                'Creează un Cont',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Conectează-te pentru a posta anunțuri și a vizualiza anunțurile tale!',
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

    // Dacă e logat, arată anunțurile lui
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Anunțurile Mele',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () async {
                  await authProvider.logout();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                icon: Icon(Icons.logout),
                tooltip: 'Delogare',
              ),
            ],
          ),
          SizedBox(height: 16),

          // Email utilizator
          Card(
            color: Colors.pink[50],
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.pink[700]),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      authProvider.currentAuthUser?.email ?? 'Utilizator',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          
          if (_myAds.isNotEmpty) ...[
            Text('${_myAds.length} ${_myAds.length == 1 ? 'anunț postat' : 'anunțuri postate'}', 
                 style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            SizedBox(height: 16),
            
            // Listă cu anunțuri
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _myAds.length,
              itemBuilder: (context, index) {
                final ad = _myAds[index];
                
                // Extrage pozele cu verificare robustă
                List<String> photos = [];
                try {
                  if (ad['photos'] != null) {
                    final photosList = ad['photos'] as List;
                    for (var p in photosList) {
                      if (p is Map && p['url'] != null && p['url'] is String) {
                        photos.add(p['url'] as String);
                      } else if (p is String) {
                        photos.add(p);
                      }
                    }
                  }
                } catch (e) {
                  print('⚠️ Error parsing photos for ad ${ad['_id']}: $e');
                }
                
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      // Deschide pagina cu detalii anunț
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdDetailScreen(adId: ad['_id']),
                        ),
                      ).then((_) => _loadMyAds()); // Reload după ce se întoarce
                    },
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Prima poză ca thumbnail
                          if (photos.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                photos.first,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[300],
                                    child: Icon(Icons.error),
                                  );
                                },
                              ),
                            )
                          else
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.photo, color: Colors.grey[400], size: 40),
                            ),
                          
                          SizedBox(width: 16),
                          
                          // Detalii anunț
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ad['title'] ?? 'Anunț fără titlu',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                                    SizedBox(width: 4),
                                    Text(
                                      '${ad['name']}, ${ad['age']} ani',
                                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.photo_library_outlined, size: 16, color: Colors.grey[600]),
                                    SizedBox(width: 4),
                                    Text(
                                      '${photos.length} ${photos.length == 1 ? 'fotografie' : 'fotografii'}',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            
            SizedBox(height: 24),
          ] else if (_isLoadingAds) ...[
            Center(child: CircularProgressIndicator()),
            SizedBox(height: 24),
          ] else ...[
            Card(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Nu ai anunțuri postate încă',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Postează primul tău anunț pentru a găsi perechea perfectă!',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
          ],
          
          // Buton postare anunț
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdPostingScreen()),
                );
                
                // Dacă anunțul a fost postat cu succes, reîncarcă lista
                if (result == true) {
                  await _loadMyAds();
                  print('🔄 Anunțurile au fost reîncărcate');
                }
              },
              icon: Icon(Icons.add_circle_outline),
              label: Text('Postează Anunț Nou'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Buton căutare
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _searchForMatch,
              icon: Icon(Icons.search),
              label: Text('Caută Perechea Potrivită'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                foregroundColor: Colors.pink,
                side: BorderSide(color: Colors.pink),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Setări',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),
          
          Card(
            child: ListTile(
              leading: Icon(Icons.person),
              title: Text(authProvider.currentAuthUser?.email ?? 'Nu ești conectat'),
              subtitle: Text('Email cont'),
            ),
          ),
          
          SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              icon: Icon(Icons.logout),
              label: Text('Delogare'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.orange,
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
                side: BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return FutureBuilder(
      future: ApiService.getMyFavorites(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text('Eroare: ${snapshot.error}'),
              ],
            ),
          );
        }

        final data = snapshot.data as Map<String, dynamic>;
        final favorites = data['favorites'] as List? ?? [];

        if (favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Niciun anunț salvat',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Text(
                  'Salvează anunțurile care te interesează',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final ad = favorites[index];

            // Extrage pozele cu verificare robustă
            List<String> photos = [];
            try {
              if (ad['photos'] != null) {
                final photosList = ad['photos'] as List;
                for (var p in photosList) {
                  if (p is Map && p['url'] != null && p['url'] is String) {
                    photos.add(p['url'] as String);
                  } else if (p is String) {
                    photos.add(p);
                  }
                }
              }
            } catch (e) {
              print('⚠️ Error parsing photos for ad ${ad['_id']}: $e');
            }

            return Card(
              margin: EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdDetailScreen(adId: ad['_id']),
                    ),
                  ).then((_) => setState(() {})); // Refresh când se întoarce
                },
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Thumbnail
                      if (photos.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            photos.first,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: Icon(Icons.person, size: 40),
                              );
                            },
                          ),
                        )
                      else
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.pink[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.person, size: 40, color: Colors.pink),
                        ),
                      SizedBox(width: 16),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ad['title'] ?? 'Fără titlu',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${ad['name']} • ${ad['age']} ani',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            if (ad['city'] != null)
                              Text(
                                '📍 ${ad['city']}',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                      Icon(Icons.favorite, color: Colors.red),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessagesTab() {
    return FutureBuilder(
      future: ApiService.getConversations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text('Eroare: ${snapshot.error}'),
              ],
            ),
          );
        }

        final data = snapshot.data as Map<String, dynamic>;
        final conversations = data['conversations'] as List? ?? [];

        if (conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.message_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Niciun mesaj',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Text(
                  'Trimite primul mesaj când găsești pe cineva interesant',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            final conv = conversations[index];
            final hasUnread = (conv['unreadCount'] ?? 0) > 0;

            return Card(
              margin: EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: conv['adPhoto'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.network(
                          conv['adPhoto'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.pink[100],
                              child: Icon(Icons.person, color: Colors.pink),
                            );
                          },
                        ),
                      )
                    : CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.pink[100],
                        child: Icon(Icons.person, color: Colors.pink),
                      ),
                title: Text(
                  conv['adName'] ?? conv['userEmail'] ?? 'Utilizator',
                  style: TextStyle(
                    fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  conv['lastMessage'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: hasUnread ? Colors.black : Colors.grey,
                    fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
                trailing: hasUnread
                    ? Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.pink,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${conv['unreadCount']}',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      )
                    : Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to chat screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deschide chat cu ${conv['adName']}')),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
