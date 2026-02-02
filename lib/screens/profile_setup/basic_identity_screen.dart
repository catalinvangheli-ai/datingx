import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/user_profile.dart';
import '../../providers/user_provider.dart';
import '../../widgets/progress_indicator_widget.dart';
import 'lifestyle_screen.dart';

class BasicIdentityScreen extends StatefulWidget {
  const BasicIdentityScreen({super.key});

  @override
  State<BasicIdentityScreen> createState() => _BasicIdentityScreenState();
}

class _BasicIdentityScreenState extends State<BasicIdentityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _gender = '';
  int _age = 25;
  String _country = '';
  final _cityController = TextEditingController();
  int _height = 170;
  final _occupationController = TextEditingController();
  final _phoneController = TextEditingController(); // Opțional
  
  final List<String> _europeanCountries = [
    'România',
    'Albania',
    'Andorra',
    'Austria',
    'Belarus',
    'Belgia',
    'Bosnia și Herțegovina',
    'Bulgaria',
    'Croația',
    'Cipru',
    'Cehia',
    'Danemarca',
    'Estonia',
    'Finlanda',
    'Franța',
    'Germania',
    'Grecia',
    'Ungaria',
    'Islanda',
    'Irlanda',
    'Italia',
    'Kosovo',
    'Letonia',
    'Liechtenstein',
    'Lituania',
    'Luxemburg',
    'Macedonia de Nord',
    'Malta',
    'Moldova',
    'Monaco',
    'Muntenegru',
    'Olanda',
    'Norvegia',
    'Polonia',
    'Portugalia',
    'San Marino',
    'Serbia',
    'Slovacia',
    'Slovenia',
    'Spania',
    'Suedia',
    'Elveția',
    'Turcia',
    'Ucraina',
    'Regatul Unit',
    'Vatican',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _occupationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveAndContinue() {
    if (_formKey.currentState!.validate() && _gender.isNotEmpty) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // NU mai creăm user nou aici - ar trebui să existe deja din RelationshipTypeScreen
      
      final identity = BasicIdentity(
        name: _nameController.text,
        gender: _gender,
        age: _age,
        country: _country,
        city: _cityController.text,
        height: _height,
        occupation: _occupationController.text,
        phoneNumber: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      );
      
      userProvider.updateBasicIdentity(identity);
      
      print('🔍 BasicIdentityScreen - Salvat identity');
      print('🔍 Relationship type păstrat: ${userProvider.currentUser?.values?.relationshipType}');
      
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LifestyleScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Identitate de Bază')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfileProgressIndicator(currentStep: 2, totalSteps: 6),
              
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nume',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Introdu numele' : null,
              ),
              const SizedBox(height: 24),
              
              const SizedBox(height: 32),
              const Text('Gen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [
                  ChoiceChip(label: const Text('Bărbat'), selected: _gender == 'bărbat', onSelected: (selected) => setState(() => _gender = 'bărbat')),
                  ChoiceChip(label: const Text('Femeie'), selected: _gender == 'femeie', onSelected: (selected) => setState(() => _gender = 'femeie')),
                ],
              ),
              const SizedBox(height: 24),
              Text('Vârstă: $_age ani', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Slider(value: _age.toDouble(), min: 18, max: 80, divisions: 62, label: _age.toString(), onChanged: (value) => setState(() => _age = value.toInt())),
              const SizedBox(height: 24),
              const Text('Țară', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _country.isEmpty ? null : _country,
                decoration: const InputDecoration(
                  labelText: 'Selectează țara',
                  border: OutlineInputBorder(),
                ),
                items: _europeanCountries.map((country) {
                  return DropdownMenuItem(value: country, child: Text(country));
                }).toList(),
                onChanged: (value) => setState(() => _country = value ?? ''),
                validator: (value) => value == null || value.isEmpty ? 'Selectează țara' : null,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'Oraș', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Introdu orașul' : null,
              ),
              const SizedBox(height: 24),
              Text('Înălțime: $_height cm', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Slider(value: _height.toDouble(), min: 140, max: 220, divisions: 80, label: '$_height cm', onChanged: (value) => setState(() => _height = value.toInt())),
              const SizedBox(height: 24),
              TextFormField(
                controller: _occupationController,
                decoration: const InputDecoration(labelText: 'Ocupație', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Introdu ocupația' : null,
              ),
              const SizedBox(height: 24),
              
              // Câmp telefon opțional
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Telefon (opțional)',
                  hintText: '+40 xxx xxx xxx',
                  border: OutlineInputBorder(),
                  helperText: '📞 Dacă vrei să poți fi contactat și telefonic',
                  helperMaxLines: 2,
                  suffixIcon: Icon(Icons.phone, color: Colors.grey[400]),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Înapoi'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _saveAndContinue,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Continuă'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
