import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'photo_gallery_screen.dart';

class AdDetailScreen extends StatefulWidget {
  final String adId;

  const AdDetailScreen({super.key, required this.adId});

  @override
  State<AdDetailScreen> createState() => _AdDetailScreenState();
}

class _AdDetailScreenState extends State<AdDetailScreen> {
  Map<String, dynamic>? _ad;
  bool _isLoading = true;
  bool _isMyAd = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getAd(widget.adId);
      if (response['success'] == true && response['ad'] != null) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        setState(() {
          _ad = response['ad'];
          // Verifică dacă acest anunț este al utilizatorului curent
          _isMyAd = _ad!['userId'] == authProvider.currentAuthUser?.id;
        });
      }
    } catch (e) {
      print('Error loading ad: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Eroare la încărcarea anunțului'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteAd() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Șterge Anunțul'),
        content: Text('Sigur vrei să ștergi acest anunț? Această acțiune nu poate fi anulată.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Anulează'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Șterge'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteAd(widget.adId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Anunț șters cu succes!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); // Returnează true pentru a indica că s-a șters
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Eroare la ștergere: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_ad != null ? _ad!['title'] ?? 'Anunț' : 'Încărcare...'),
        actions: _isMyAd
            ? [
                IconButton(
                  icon: Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: _deleteAd,
                  tooltip: 'Șterge anunțul',
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _ad == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Anunț negăsit', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                    ],
                  ),
                )
              : _buildAdContent(),
    );
  }

  Widget _buildAdContent() {
    final photos = (_ad!['photos'] as List?)?.map((p) => p['url'] as String).toList() ?? [];
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Galerie de poze
          if (photos.isNotEmpty) ...[
            SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhotoGalleryScreen(
                            photos: photos,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    child: Image.network(
                      photos[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.error, size: 64),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              color: Colors.black87,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  photos.length,
                  (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            ),
          ],
          
          // Detalii anunț
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titlu
                Text(
                  _ad!['title'] ?? '',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                
                // Date personale
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.person_outline, 'Nume', _ad!['name'] ?? ''),
                        Divider(),
                        _buildInfoRow(Icons.cake_outlined, 'Vârstă', '${_ad!['age']} ani'),
                        Divider(),
                        _buildInfoRow(Icons.wc_outlined, 'Gen', _ad!['gender'] ?? ''),
                        Divider(),
                        _buildInfoRow(Icons.location_on_outlined, 'Locație', 
                          '${_ad!['city'] ?? ''}, ${_ad!['country'] ?? ''}'),
                        Divider(),
                        _buildInfoRow(Icons.phone_outlined, 'Telefon', _ad!['phoneNumber'] ?? ''),
                        Divider(),
                        _buildInfoRow(Icons.favorite_outline, 'Caută', _ad!['relationshipType'] ?? ''),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Descriere
                if (_ad!['bio'] != null && _ad!['bio']!.isNotEmpty) ...[
                  Text('Descriere', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        _ad!['bio'],
                        style: TextStyle(fontSize: 15, height: 1.5),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
                
                // Interese
                if (_ad!['interests'] != null && (_ad!['interests'] as List).isNotEmpty) ...[
                  Text('Interese', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (_ad!['interests'] as List).map((interest) {
                      return Chip(
                        label: Text(interest.toString()),
                        backgroundColor: Colors.pink[50],
                        labelStyle: TextStyle(color: Colors.pink[700]),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                ],
                
                // Vizualizări
                Row(
                  children: [
                    Icon(Icons.visibility_outlined, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(
                      '${_ad!['views'] ?? 0} vizualizări',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.pink[400]),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
