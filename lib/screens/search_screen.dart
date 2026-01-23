import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'profile_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Criterii OBLIGATORII
  String? _searchGender;
  RangeValues _ageRange = const RangeValues(18, 65);

  // Criterii OPȚIONALE
  String? _country;
  String? _city;
  RangeValues? _heightRange;
  String? _education;
  String? _occupation;
  List<String> _selectedInterests = [];
  String? _smokingPreference;
  String? _drinkingPreference;
  String? _relationshipGoal;

  bool _isSearching = false;
  List<dynamic> _searchResults = [];

  final List<String> _genders = ['Bărbat', 'Femeie', 'Non-binar'];
  final List<String> _educationLevels = [
    'Liceu',
    'Facultate',
    'Masterat',
    'Doctorat',
    'Altele'
  ];
  final List<String> _smokingOptions = ['Nu fumez', 'Fumez ocazional', 'Fumez'];
  final List<String> _drinkingOptions = [
    'Nu beau',
    'Beau ocazional',
    'Beau social'
  ];
  final List<String> _relationshipGoals = [
    'Relație serioasă',
    'Prietenie',
    'Ceva casual',
    'Încă nu știu'
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
    if (_searchGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te rog selectează genul persoanei căutate')),
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
        if (_country != null && _country!.isNotEmpty) 'country': _country,
        if (_city != null && _city!.isNotEmpty) 'city': _city,
        if (_heightRange != null) ...{
          'minHeight': _heightRange!.start.round(),
          'maxHeight': _heightRange!.end.round(),
        },
        if (_education != null) 'education': _education,
        if (_occupation != null && _occupation!.isNotEmpty)
          'occupation': _occupation,
        if (_selectedInterests.isNotEmpty) 'interests': _selectedInterests,
        if (_smokingPreference != null) 'smoking': _smokingPreference,
        if (_drinkingPreference != null) 'drinking': _drinkingPreference,
        if (_relationshipGoal != null) 'relationshipGoal': _relationshipGoal,
      };

      // Apelează API-ul de căutare
      final response = await ApiService.searchProfiles(searchCriteria);

      if (response['success'] == true) {
        setState(() {
          _searchResults = response['results'] ?? [];
        });

        if (_searchResults.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Nu există profiluri care se potrivesc criteriilor tale. Încearcă criterii mai largi!'),
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
              ],
            ),
          ),

          const SizedBox(height: 24),

          // SECȚIUNE OPȚIONALĂ
          ExpansionTile(
            title: const Text('Criterii Opționale (pentru căutare detaliată)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            initiallyExpanded: false,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Locație
                    const Text('Țara',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'ex: România',
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
                      ),
                      onChanged: (value) => _city = value,
                    ),
                    const SizedBox(height: 16),

                    // Înălțime
                    const Text('Înălțime (opțional)',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: Text(_heightRange == null
                          ? 'Adaugă filtru înălțime'
                          : '${_heightRange!.start.round()} - ${_heightRange!.end.round()} cm'),
                      value: _heightRange != null,
                      onChanged: (value) {
                        setState(() {
                          _heightRange =
                              value ? const RangeValues(150, 200) : null;
                        });
                      },
                    ),
                    if (_heightRange != null)
                      RangeSlider(
                        values: _heightRange!,
                        min: 140,
                        max: 220,
                        divisions: 80,
                        labels: RangeLabels(
                          '${_heightRange!.start.round()} cm',
                          '${_heightRange!.end.round()} cm',
                        ),
                        onChanged: (values) =>
                            setState(() => _heightRange = values),
                      ),
                    const SizedBox(height: 16),

                    // Educație
                    const Text('Educație',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _education,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Orice nivel',
                      ),
                      items: _educationLevels
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (value) => setState(() => _education = value),
                    ),
                    const SizedBox(height: 16),

                    // Ocupație
                    const Text('Ocupație',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'ex: Inginer, Doctor, Artist',
                      ),
                      onChanged: (value) => _occupation = value,
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
                    const SizedBox(height: 16),

                    // Fumat
                    const Text('Fumat',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _smokingPreference,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Orice preferință',
                      ),
                      items: _smokingOptions
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _smokingPreference = value),
                    ),
                    const SizedBox(height: 16),

                    // Băut
                    const Text('Băut',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _drinkingPreference,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Orice preferință',
                      ),
                      items: _drinkingOptions
                          .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _drinkingPreference = value),
                    ),
                    const SizedBox(height: 16),

                    // Scop relație
                    const Text('Scop Relație',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _relationshipGoal,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Orice scop',
                      ),
                      items: _relationshipGoals
                          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _relationshipGoal = value),
                    ),
                  ],
                ),
              ),
            ],
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
              final profile = _searchResults[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.pink[100],
                    child: Text(
                      profile['name']?.substring(0, 1).toUpperCase() ?? '?',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink[700]),
                    ),
                  ),
                  title: Text(
                    profile['name'] ?? 'Anonim',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${profile['age']} ani, ${profile['gender']}'),
                      if (profile['city'] != null)
                        Text('📍 ${profile['city']}, ${profile['country']}'),
                      if (profile['occupation'] != null)
                        Text('💼 ${profile['occupation']}'),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navighează la ecranul de detalii profil
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfileDetailScreen(profileData: profile),
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
