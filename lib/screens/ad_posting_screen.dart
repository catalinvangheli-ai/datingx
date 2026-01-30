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
  
  String? _gender;
  String? _relationshipType;
  List<String> _selectedInterests = [];
  
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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _ageController.dispose();
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
      
      // PASUL 0: Ștergem toate pozele vechi pentru a posta anunț nou
      try {
        print('🗑️ Ștergem pozele vechi...');
        await ApiService.deleteAllPhotos();
        print('✅ Poze vechi șterse');
      } catch (e) {
        print('⚠️ Nu s-au putut șterge pozele vechi (probabil nu existau): $e');
        // Continuăm oricum - poate e primul anunț
      }
      
      // PASUL 1: Creăm/actualizăm profilul cu date de bază pentru a permite upload-ul de poze
      final initialProfileData = {
        'name': _nameController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()) ?? 18,
        'gender': _gender ?? '',
        'country': _countryController.text.trim(),
        'profileComplete': false, // Încă nu e complet
      };
      
      print('📋 Creăm profilul de bază...');
      await ApiService.saveProfile(initialProfileData);
      
      // PASUL 2: Upload poze (acestea se salvează automat în profil prin /photo/upload)
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

      // PASUL 3: Actualizăm profilul cu toate datele complete
      final adData = {
        // Date de bază OBLIGATORII pentru căutare
        'name': _nameController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()) ?? 18,
        'gender': _gender ?? '',
        'country': _countryController.text.trim(),
        'city': _cityController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'relationshipType': _relationshipType ?? '',
        'interests': _selectedInterests,
        
        // Bio include titlul și descrierea
        'bio': '${_titleController.text.trim()}\n\n${_descriptionController.text.trim()}',
        
        // NU trimitem photos - sunt deja salvate prin /photo/upload
        
        'profileComplete': true, // ACUM e complet
      };

      print('📤 Salvăm datele anunțului: $adData');
      final saveResponse = await ApiService.saveProfile(adData);
      
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
          
          // Așteaptă puțin și apoi întoarce-te
          await Future.delayed(const Duration(seconds: 1));
          
          if (mounted) {
            Navigator.pop(context, true); // Returnează true pentru a indica succes
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
