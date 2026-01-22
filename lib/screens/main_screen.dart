import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final completionPercentage = userProvider.getCompletionPercentage();
    final isVisible = userProvider.isProfileVisible();

    return Scaffold(
      appBar: AppBar(
        title: const Text('DatingX'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text('Profil: $completionPercentage%', style: const TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
      body: isVisible
          ? _getBody(_currentIndex)
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 24),
                    Text('Profilul tău este $completionPercentage% complet', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    Text('Trebuie să completezi minimum 80% din profil pentru a fi vizibil.', style: TextStyle(fontSize: 16, color: Colors.grey[600]), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
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
        return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.explore, size: 64, color: Colors.pink), SizedBox(height: 16), Text('Descoperă persoane compatibile', style: TextStyle(fontSize: 18))]));
      case 1:
        return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.favorite, size: 64, color: Colors.pink), SizedBox(height: 16), Text('Compatibilitățile tale', style: TextStyle(fontSize: 18))]));
      case 2:
        return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.message, size: 64, color: Colors.pink), SizedBox(height: 16), Text('Mesajele tale', style: TextStyle(fontSize: 18))]));
      case 3:
        return _buildProfileTab();
      default:
        return const Center(child: Text('Descoperă'));
    }
  }

  Widget _buildProfileTab() {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Profilul Meu', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          if (user?.basicIdentity != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Identitate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
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
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Stil de Viață', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
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
        ],
      ),
    );
  }
}
