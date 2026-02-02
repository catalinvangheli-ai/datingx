import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'ad_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Criterii OBLIGATORII
  String? _searchGender;
  RangeValues _ageRange = const RangeValues(18, 65);
  String? _searchRelationshipType; // OBLIGATORIU - tip relație căutată

  // Criterii OPȚIONALE
  String? _country;
  String? _city;
  List<String> _selectedInterests = [];

  bool _isSearching = false;
  List<dynamic> _searchResults = [];
  bool _showAdvancedSearch = false;

  final List<String> _genders = ['Bărbat', 'Femeie', 'Non-binar'];
  final List<String> _relationshipTypes = [
    '💍 Căsătorie / Relație serioasă pe termen lung',
    '❤️ Relație de iubire (fără presiune pentru căsătorie)',
    '🤝 Prietenie / Cunoștințe / Discuții',
    '😊 Relație casual / Fără angajament',
    '🔥 Aventură / Relație ocazională',
    '🎭 Relație deschisă / Non-monogamă',
    '🤷 Încă nu știu / Deschis la posibilități',
  ];
  final List<String> _allInterests = [
    'Muzică',
    'Sport',
    'Călătorii',
    'Citit',
    'Gaming',
    'Film',
    'Gătit',
    'Artă',
    'Tehnologie',
    'Natură'
  ];

  Future<void> _performSearch() async {
    if (_searchGender == null || _searchRelationshipType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
          _searchGender == null 
            ? 'Te rog selectează genul persoanei căutate'
            : 'Te rog selectează ce tip de relație cauți'
        )),
      );
      return;
    }

    setState(() => _isSearching = true);

    try {
      // Construiește criteriile de căutare
      final searchCriteria = {
        'gender': _searchGender,
        'minAge': _ageRange.start.round(),
        'maxAge': _ageRange.end.round(),
        'relationshipType': _searchRelationshipType, // OBLIGATORIU
        if (_country != null && _country!.isNotEmpty) 'country': _country,
        if (_city != null && _city!.isNotEmpty) 'city': _city,
        if (_selectedInterests.isNotEmpty) 'interests': _selectedInterests,
      };

      // Apelează API-ul de căutare
      final response = await ApiService.searchAds(searchCriteria);

      if (response['success'] == true) {
        setState(() {
          _searchResults = response['ads'] ?? [];
        });

        if (_searchResults.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Nu există anunțuri care se potrivesc criteriilor tale. Încearcă criterii mai largi!'),
              duration: Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Am găsit ${_searchResults.length} persoane!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Search error details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Eroare la căutare. Verifică conexiunea la internet.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caută Perechea Perfectă'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: _searchResults.isEmpty
          ? _buildSearchForm(isLoggedIn)
          : _buildSearchResults(),
    );
  }

  Widget _buildSearchForm(bool isLoggedIn) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isLoggedIn) ...[
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
                      'Creează un cont pentru a salva căutările și a comunica cu persoanele găsite!',
                      style: TextStyle(color: Colors.blue[900]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // SECȚIUNE OBLIGATORIE
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.pink[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.pink[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.pink[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Criterii Obligatorii',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink[900],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Gen
                const Text('Caut',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _searchGender,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Selectează genul',
                  ),
                  items: _genders
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (value) => setState(() => _searchGender = value),
                ),
                const SizedBox(height: 16),

                // Vârstă
                Text(
                  'Vârsta: ${_ageRange.start.round()} - ${_ageRange.end.round()} ani',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                RangeSlider(
                  values: _ageRange,
                  min: 18,
                  max: 80,
                  divisions: 62,
                  labels: RangeLabels(
                    _ageRange.start.round().toString(),
                    _ageRange.end.round().toString(),
                  ),
                  onChanged: (values) => setState(() => _ageRange = values),
                ),
                const SizedBox(height: 16),

                // Tip Relație - NOU OBLIGATORIU
                const Text(
                  'Ce tip de relație cauți?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _searchRelationshipType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Selectează tipul de relație',
                    helperText: '💡 Acest criteriu ajută la găsirea persoanelor compatibile',
                  ),
                  items: _relationshipTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type, style: const TextStyle(fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _searchRelationshipType = value),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Buton Căutare Detaliată
          OutlinedButton.icon(
            onPressed: () {
              setState(() => _showAdvancedSearch = !_showAdvancedSearch);
            },
            icon: Icon(_showAdvancedSearch ? Icons.expand_less : Icons.expand_more),
            label: Text(_showAdvancedSearch ? 'Ascunde Căutare Detaliată' : '+ Căutare Detaliată (opțional)'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFFE91E63)),
              foregroundColor: const Color(0xFFE91E63),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Filtrează după țară, oraș, interese comune',
            style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // SECȚIUNE OPȚIONALĂ (afișată doar dacă _showAdvancedSearch == true)
          if (_showAdvancedSearch)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Criterii Opționale',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Locație
                  const Text('Țara',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'ex: România',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) => _country = value,
                  ),
                  const SizedBox(height: 16),

                  const Text('Orașul',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'ex: București',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) => _city = value,
                  ),
                  const SizedBox(height: 16),

                  // Interese
                  const Text('Interese Comune',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _allInterests.map((interest) {
                      final isSelected =
                          _selectedInterests.contains(interest);
                      return FilterChip(
                        label: Text(interest),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedInterests.add(interest);
                            } else {
                              _selectedInterests.remove(interest);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 32),

          // Buton căutare
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSearching ? null : _performSearch,
              icon: _isSearching
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.search, size: 28),
              label: Text(
                _isSearching ? 'Căutare...' : 'Caută Acum',
                style: const TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.pink[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Găsite: ${_searchResults.length} persoane',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _searchResults = []),
                icon: const Icon(Icons.refresh),
                label: const Text('Căutare nouă'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final ad = _searchResults[index];
              final photos = (ad['photos'] as List?)?.map((p) => p['url'] as String).toList() ?? [];
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: photos.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            photos.first,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.pink[100],
                                child: Text(
                                  ad['name']?.substring(0, 1).toUpperCase() ?? '?',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink[700]),
                                ),
                              );
                            },
                          ),
                        )
                      : CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.pink[100],
                          child: Text(
                            ad['name']?.substring(0, 1).toUpperCase() ?? '?',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink[700]),
                          ),
                        ),
                  title: Text(
                    ad['title'] ?? ad['name'] ?? 'Anonim',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${ad['name']} • ${ad['age']} ani, ${ad['gender']}'),
                      if (ad['city'] != null)
                        Text('📍 ${ad['city']}, ${ad['country']}'),
                      if (ad['relationshipType'] != null)
                        Text('💝 ${ad['relationshipType']}', 
                            maxLines: 1, 
                            overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navighează la ecranul de detalii anunț
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AdDetailScreen(adId: ad['_id']),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
