import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_profile.dart';

class ProfileDetailScreen extends StatelessWidget {
  final Map<String, dynamic> profileData;

  const ProfileDetailScreen({super.key, required this.profileData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(profileData['name'] ?? 'Profil'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header cu poze
            _buildPhotoSection(),

            // Informații de bază
            _buildBasicInfoSection(),

            // Telefon (dacă există)
            if (profileData['phoneNumber'] != null &&
                profileData['phoneNumber'].toString().isNotEmpty)
              _buildPhoneSection(context),

            // Lifestyle
            _buildLifestyleSection(),

            // Personality
            _buildPersonalitySection(),

            // Values
            _buildValuesSection(),

            // Interests
            _buildInterestsSection(),

            // Buton mesaj
            _buildMessageButton(context),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    final photos = profileData['photos'] as List<dynamic>? ?? [];

    if (photos.isEmpty) {
      return Container(
        height: 300,
        color: Colors.pink[50],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, size: 80, color: Colors.pink[200]),
              const SizedBox(height: 8),
              Text(
                'Nicio fotografie',
                style: TextStyle(color: Colors.pink[300], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: PageView.builder(
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final photoUrl = photos[index]['url'] as String;
          return GestureDetector(
            onTap: () {
              // Deschide fotografia în modul full screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _FullScreenImage(imageUrl: photoUrl),
                ),
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 50),
                    );
                  },
                ),
                if (photos.length > 1)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${index + 1}/${photos.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            profileData['name'] ?? 'Anonim',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.cake, size: 20, color: Colors.pink[700]),
              const SizedBox(width: 8),
              Text(
                '${profileData['age']} ani',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 16),
              Icon(Icons.person, size: 20, color: Colors.pink[700]),
              const SizedBox(width: 8),
              Text(
                profileData['gender'] ?? '',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (profileData['city'] != null || profileData['country'] != null)
            Row(
              children: [
                Icon(Icons.location_on, size: 20, color: Colors.pink[700]),
                const SizedBox(width: 8),
                Text(
                  '${profileData['city'] ?? ''}, ${profileData['country'] ?? ''}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          if (profileData['height'] != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.height, size: 20, color: Colors.pink[700]),
                const SizedBox(width: 8),
                Text(
                  '${profileData['height']} cm',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
          if (profileData['occupation'] != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.work, size: 20, color: Colors.pink[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    profileData['occupation'],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhoneSection(BuildContext context) {
    final phone = profileData['phoneNumber'].toString();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.phone, color: Colors.green[700], size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Telefon de contact',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  phone,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.phone_in_talk, color: Colors.green[700]),
            onPressed: () async {
              final uri = Uri.parse('tel:$phone');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Nu se poate deschide aplicația telefon')),
                );
              }
            },
            tooltip: 'Sună',
          ),
        ],
      ),
    );
  }

  Widget _buildLifestyleSection() {
    // Câmpuri individuale din backend, nu obiect nested
    final smoking = profileData['smokingHabit'];
    final drinking = profileData['drinkingHabit'];
    final exercise = profileData['fitnessLevel'];
    final diet = profileData['diet'];
    final pets = profileData['petPreference'];
    
    if (smoking == null && drinking == null && exercise == null && diet == null && pets == null) {
      return const SizedBox.shrink();
    }
    
    return _buildSection(
      'Stil de Viață',
      Icons.favorite,
      [
        if (smoking != null)
          _buildInfoRow('🚬 Fumat', smoking),
        if (drinking != null)
          _buildInfoRow('🍷 Băut', drinking),
        if (exercise != null)
          _buildInfoRow('💪 Sport', exercise),
        if (diet != null)
          _buildInfoRow('🍽️ Dietă', diet),
        if (pets != null)
          _buildInfoRow('🐾 Animale', pets),
      ],
    );
  }

  Widget _buildPersonalitySection() {
    // Câmpuri individuale din backend
    final introExtro = profileData['introvertExtrovert'];
    final spontaneous = profileData['spontaneousPlanned'];
    final creative = profileData['creativeAnalytical'];
    
    if (introExtro == null && spontaneous == null && creative == null) {
      return const SizedBox.shrink();
    }
    
    return _buildSection(
      'Personalitate',
      Icons.psychology,
      [
        if (introExtro != null)
          _buildInfoRow('👥 Stil social', introExtro),
        if (spontaneous != null)
          _buildInfoRow('⏱️ Ritm emoțional', spontaneous),
        if (creative != null)
          _buildInfoRow('🧠 Stil conflict', creative),
      ],
    );
  }

  Widget _buildValuesSection() {
    // Câmpuri individuale din backend
    final religion = profileData['religionImportance'];
    final politics = profileData['politicalAlignment'];
    final wantKids = profileData['wantsChildren'];
    final relationship = profileData['relationshipType'];
    
    if (religion == null && politics == null && wantKids == null && relationship == null) {
      return const SizedBox.shrink();
    }
    
    return _buildSection(
      'Valori',
      Icons.star,
      [
        if (religion != null)
          _buildInfoRow('🙏 Religie', religion),
        if (politics != null)
          _buildInfoRow('🗳️ Politică', politics),
        if (wantKids != null)
          _buildInfoRow('👶 Copii', wantKids),
        if (relationship != null)
          _buildInfoRow('💑 Tip relație', relationship),
      ],
    );
  }

  Widget _buildInterestsSection() {
    // interests vine ca Array direct din backend, nu ca Map
    final interestsData = profileData['interests'];
    
    if (interestsData == null) return const SizedBox.shrink();
    
    List<String> allInterests = [];
    if (interestsData is List) {
      allInterests = List<String>.from(interestsData);
    }

    if (allInterests.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      'Interese',
      Icons.interests,
      [_buildChipsList('🎯 Pasiuni', allInterests)],
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.pink[700]),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipsList(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map((item) => Chip(
                    label: Text(item),
                    backgroundColor: Colors.pink[50],
                    labelStyle: TextStyle(color: Colors.pink[900]),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildMessageButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            _showMessageDialog(context);
          },
          icon: const Icon(Icons.message),
          label: const Text('Trimite mesaj'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  void _showMessageDialog(BuildContext context) {
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.message, color: Colors.pink[700]),
            const SizedBox(width: 8),
            const Text('Trimite mesaj'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Către: ${profileData['name']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Scrie mesajul tău aici...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '💡 Pentru moment, mesajele nu sunt salvate. Folosește telefonul de mai sus pentru contact direct.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anulează'),
          ),
          ElevatedButton(
            onPressed: () {
              if (messageController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mesajul nu poate fi gol')),
                );
                return;
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '📧 Mesaj trimis către ${profileData['name']}!\n'
                    '(Pentru moment, folosește telefonul pentru contact real)',
                  ),
                  duration: const Duration(seconds: 4),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
            ),
            child: const Text('Trimite'),
          ),
        ],
      ),
    );
  }
}

// Widget pentru vizualizare fotografie în modul full screen
class _FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const _FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(Icons.broken_image, color: Colors.white, size: 100),
              );
            },
          ),
        ),
      ),
    );
  }
}
