import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class AdPostingScreen extends StatefulWidget {
  const AdPostingScreen({super.key});

  @override
  State<AdPostingScreen> createState() => _AdPostingScreenState();
}

class _AdPostingScreenState extends State<AdPostingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController(); // Controller pentru înălțime
  
  String? _gender;
  String? _relationshipType;
  List<String> _selectedInterests = [];
  
  // CRITERII OPȚIONALE NOI
  String? _hasChildren;
  String? _wantsChildren;
  String? _education;
  String? _smoking;
  String? _drinking;
  String? _religion;
  List<String> _selectedLanguages = [];
  String? _bodyType;
  String? _relationshipStatus;
  
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isPosting = false;
  
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
  
  // Liste pentru criterii noi
  final List<String> _hasChildrenOptions = ['Nu', 'Da', 'Prefer să nu spun'];
  final List<String> _wantsChildrenOptions = ['Da', 'Nu', 'Poate', 'Deja am'];
  final List<String> _educationOptions = ['Liceu', 'Facultate', 'Masterat', 'Doctorat', 'Altele'];
  final List<String> _smokingOptions = ['Nu', 'Ocazional', 'Da'];
  final List<String> _drinkingOptions = ['Nu consum', 'Ocazional', 'Social', 'Frecvent'];
  final List<String> _religionOptions = [
    'Creștin-Ortodox', 'Catolic', 'Protestant', 'Muslim', 
    'Budist', 'Ateu', 'Agnostic', 'Alta'
  ];
  final List<String> _allLanguages = [
    'Română', 'Engleză', 'Franceză', 'Germană', 'Spaniolă', 
    'Italiană', 'Rusă', 'Maghiară', 'Turcă'
  ];
  final List<String> _bodyTypeOptions = [
    'Athletic', 'Slim', 'Average', 'Curvy', 'Plus Size'
  ];
  final List<String> _relationshipStatusOptions = [
    'Necăsătorit(ă)', 'Divorțat(ă)', 'Văduv(ă)'
  ];

  @override
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      
      if (images.isNotEmpty) {
        setState(() {
          // Limităm la maxim 6 poze
          final remainingSlots = 6 - _selectedImages.length;
          final imagesToAdd = images.take(remainingSlots);
          _selectedImages.addAll(imagesToAdd.map((xfile) => File(xfile.path)));
        });
      }
    } catch (e) {
      print('Eroare la selectarea pozelor: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eroare la selectarea pozelor: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _postAd() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Te rugăm să adaugi cel puțin o poză!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (!authProvider.isAuthenticated) {
        throw Exception('Nu ești autentificat!');
      }

      print('📤 Postăm anunț...');
      
      // IMPORTANT: Ștergem pozele vechi din Profile (sistem vechi) 
      // pentru a evita eroarea "maxim 6 poze"
      try {
        print('🗑️ Ștergem pozele vechi din Profile...');
        await ApiService.deleteAllPhotos();
        print('✅ Poze vechi șterse');
      } catch (e) {
        print('⚠️ Nu s-au putut șterge pozele vechi (posibil să nu existe): $e');
        // Continuăm oricum, poate nu există poze vechi
      }
      
      // Upload poze ȘI salvează anunțul complet
      List<Map<String, String>> uploadedPhotos = [];
      for (var image in _selectedImages) {
        print('📸 Încărcăm poza: ${image.path}');
        final imageBytes = await image.readAsBytes();
        final fileName = image.path.split('/').last;
        final response = await ApiService.uploadPhoto(imageBytes, fileName);
        if (response['success'] == true && response['photo'] != null) {
          uploadedPhotos.add({
            'url': response['photo']['url'],
            'cloudinaryId': response['photo']['cloudinaryId'],
          });
          print('✅ Poză încărcată: ${response['photo']['url']}');
        }
      }

      // Creăm anunțul cu toate datele
      final adData = {
        'title': _titleController.text.trim(),
        'bio': _descriptionController.text.trim(),
        'name': _nameController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()) ?? 18,
        'gender': _gender ?? '',
        'country': _countryController.text.trim(),
        'city': _cityController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'relationshipType': _relationshipType ?? '',
        'interests': _selectedInterests,
        'photos': uploadedPhotos,
        // CRITERII OPȚIONALE NOI - trimite doar dacă sunt completate
        if (_hasChildren != null) 'hasChildren': _hasChildren,
        if (_wantsChildren != null) 'wantsChildren': _wantsChildren,
        if (_education != null) 'education': _education,
        if (_heightController.text.trim().isNotEmpty) 
          'height': int.tryParse(_heightController.text.trim()),
        if (_smoking != null) 'smoking': _smoking,
        if (_drinking != null) 'drinking': _drinking,
        if (_religion != null) 'religion': _religion,
        if (_selectedLanguages.isNotEmpty) 'languages': _selectedLanguages,
        if (_bodyType != null) 'bodyType': _bodyType,
        if (_relationshipStatus != null) 'relationshipStatus': _relationshipStatus,
      };

      print('📤 Salvăm anunțul: $adData');
      final saveResponse = await ApiService.createAd(adData);
      
      if (saveResponse['success'] == true) {
        print('✅ Anunț postat cu succes!');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Anunț postat cu succes!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          await Future.delayed(const Duration(seconds: 1));
          
          if (mounted) {
            Navigator.pop(context, true);
          }
        }
      } else {
        throw Exception('Eroare la salvarea anunțului');
      }
      
    } catch (e) {
      print('❌ Eroare la postarea anunțului: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Postează Anunț'),
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instrucțiuni
              Card(
                color: Colors.pink[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.pink[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Completează detaliile anunțului tău matrimonial. Toate câmpurile sunt obligatorii.',
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // DATE DE BAZĂ OBLIGATORII
              Text(
                'Date Personale *',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Gen
              Text(
                'Sunt *',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: InputDecoration(
                  hintText: 'Selectează genul',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: _genders
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (value) => setState(() => _gender = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Genul este obligatoriu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Vârstă
              Text(
                'Vârsta *',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'ex: 25',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vârsta este obligatorie';
                  }
                  final age = int.tryParse(value.trim());
                  if (age == null || age < 18 || age > 100) {
                    return 'Vârsta trebuie să fie între 18 și 100 ani';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tip Relație
              Text(
                'Caut *',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _relationshipType,
                decoration: InputDecoration(
                  hintText: 'Selectează tipul de relație',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: _relationshipTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type, style: const TextStyle(fontSize: 14)),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _relationshipType = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tipul de relație este obligatoriu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Titlu
              Text(
                'Titlu Anunț *',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'ex: Caut relație serioasă',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLength: 60,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Titlul este obligatoriu';
                  }
                  if (value.trim().length < 10) {
                    return 'Titlul trebuie să aibă cel puțin 10 caractere';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Descriere
              Text(
                'Descriere *',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Descrie-te și spune ce cauți...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLines: 6,
                maxLength: 500,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Descrierea este obligatorie';
                  }
                  if (value.trim().length < 50) {
                    return 'Descrierea trebuie să aibă cel puțin 50 caractere';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Fotografii
              Text(
                'Fotografii * (minim 1, maxim 6)',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              
              // Grid cu poze selectate
              if (_selectedImages.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImages[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              
              const SizedBox(height: 12),
              
              // Buton adaugă poze
              if (_selectedImages.length < 6)
                OutlinedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: Text(_selectedImages.isEmpty 
                    ? 'Adaugă Fotografii' 
                    : 'Adaugă Mai Multe (${_selectedImages.length}/6)'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFFE91E63)),
                    foregroundColor: const Color(0xFFE91E63),
                  ),
                ),
              const SizedBox(height: 24),

              // Date de contact
              Text(
                'Date de Contact',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Nume
              Text(
                'Nume *',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Numele tău',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Numele este obligatoriu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Telefon
              Text(
                'Telefon *',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'ex: 0712345678',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Telefonul este obligatoriu';
                  }
                  if (value.trim().length < 10) {
                    return 'Numărul de telefon nu este valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Oraș
              Text(
                'Localitatea *',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  hintText: 'ex: București',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Localitatea este obligatorie';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Țara
              Text(
                'Țara *',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _countryController,
                decoration: InputDecoration(
                  hintText: 'ex: România',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Țara este obligatorie';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Interese
              Text(
                'Interese (opțional)',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allInterests.map((interest) {
                  final isSelected = _selectedInterests.contains(interest);
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
              const SizedBox(height: 24),

              // DIVIDER - Criterii detaliate
              Divider(thickness: 2),
              Text(
                '✨ Criterii Detaliate (Opțional)',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE91E63),
                ),
              ),
              Text(
                'Completează pentru a primi match-uri mai relevante',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),

              // 1. Copii
              Text('Ai copii?', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _hasChildren,
                decoration: InputDecoration(
                  hintText: 'Selectează',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: _hasChildrenOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                onChanged: (value) => setState(() => _hasChildren = value),
              ),
              const SizedBox(height: 16),

              Text('Dorești copii în viitor?', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _wantsChildren,
                decoration: InputDecoration(
                  hintText: 'Selectează',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: _wantsChildrenOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                onChanged: (value) => setState(() => _wantsChildren = value),
              ),
              const SizedBox(height: 16),

              // 2. Educație
              Text('Educație', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _education,
                decoration: InputDecoration(
                  hintText: 'Selectează nivelul',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: _educationOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                onChanged: (value) => setState(() => _education = value),
              ),
              const SizedBox(height: 16),

              // 3. Înălțime
              Text('Înălțime (cm)', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'ex: 175',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                  suffixText: 'cm',
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final height = int.tryParse(value.trim());
                    if (height == null) {
                      return 'Introdu un număr valid';
                    }
                    if (height < 100 || height > 250) {
                      return 'Înălțimea trebuie să fie între 100-250 cm';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 4. Stil viață
              Text('Fumător?', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _smoking,
                decoration: InputDecoration(
                  hintText: 'Selectează',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: _smokingOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                onChanged: (value) => setState(() => _smoking = value),
              ),
              const SizedBox(height: 16),

              Text('Consum alcool?', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _drinking,
                decoration: InputDecoration(
                  hintText: 'Selectează',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: _drinkingOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                onChanged: (value) => setState(() => _drinking = value),
              ),
              const SizedBox(height: 16),

              // 5. Religie
              Text('Religie', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _religion,
                decoration: InputDecoration(
                  hintText: 'Selectează',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: _religionOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                onChanged: (value) => setState(() => _religion = value),
              ),
              const SizedBox(height: 16),

              // 6. Limbi vorbite
              Text('Limbi vorbite', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allLanguages.map((lang) {
                  final isSelected = _selectedLanguages.contains(lang);
                  return FilterChip(
                    label: Text(lang),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedLanguages.add(lang);
                        } else {
                          _selectedLanguages.remove(lang);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // 7. Tip corp
              Text('Tip corp', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _bodyType,
                decoration: InputDecoration(
                  hintText: 'Selectează',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: _bodyTypeOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                onChanged: (value) => setState(() => _bodyType = value),
              ),
              const SizedBox(height: 16),

              // 8. Status relație
              Text('Status relație', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _relationshipStatus,
                decoration: InputDecoration(
                  hintText: 'Selectează',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: _relationshipStatusOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                onChanged: (value) => setState(() => _relationshipStatus = value),
              ),
              const SizedBox(height: 32),

              // Buton postare
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPosting ? null : _postAd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: _isPosting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Se postează...'),
                          ],
                        )
                      : Text(
                          'Postează Anunțul',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
