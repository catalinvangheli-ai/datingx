import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../../models/user_profile.dart';
import '../../providers/user_provider.dart';
import '../../widgets/progress_indicator_widget.dart';
import 'partner_criteria_screen.dart';
import '../../services/api_service.dart';

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({super.key});

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  final List<String> _photoUrls = []; // URLs from Cloudinary
  final List<String> _cloudinaryIds = []; // For deletion
  String _bio = '';
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateBio();
    });
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  String _generateBio() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final profile = userProvider.currentUser;
    
    if (profile == null) return '';
    
    List<String> bioSections = [];
    
    // Introducere bazată pe identitate
    if (profile.basicIdentity != null) {
      final identity = profile.basicIdentity!;
      String intro = 'Sunt ';
      if (identity.gender == 'Bărbat') {
        intro += 'un bărbat';
      } else if (identity.gender == 'Femeie') {
        intro += 'o femeie';
      } else {
        intro += 'o persoană';
      }
      intro += ' de ${identity.age} ani din ${identity.city}, ${identity.country}. ';
      intro += 'Profesional, lucrez ca ${identity.occupation}.';
      bioSections.add(intro);
    }
    
    // Stil de viață
    if (profile.lifestyle != null) {
      final lifestyle = profile.lifestyle!;
      String lifestylePart = '';
      
      if (lifestyle.exercise.isNotEmpty) {
        switch (lifestyle.exercise) {
          case 'Foarte activ':
            lifestylePart += 'Țin foarte mult la sănătate și mă antrenez regulat. ';
            break;
          case 'Moderat activ':
            lifestylePart += 'Sunt o persoană activă și îmi place să mă mișc. ';
            break;
          case 'Ocazional':
            lifestylePart += 'Ocazional practic sport pentru relaxare. ';
            break;
          case 'Sedentar':
            lifestylePart += 'Prefer activități mai relaxante. ';
            break;
        }
      }
      
      if (lifestyle.smoking.isNotEmpty && lifestyle.smoking != 'Prefer să nu spun') {
        lifestylePart += '${lifestyle.smoking == 'Nu fumez' ? 'Nu fumez' : lifestyle.smoking}. ';
      }
      
      if (lifestyle.alcohol.isNotEmpty && lifestyle.alcohol != 'Prefer să nu spun') {
        if (lifestyle.alcohol == 'Nu beau') {
          lifestylePart += 'Nu consum alcool.';
        } else {
          lifestylePart += 'În ocazii sociale, ${lifestyle.alcohol.toLowerCase()}.';
        }
      }
      
      if (lifestylePart.isNotEmpty) {
        bioSections.add(lifestylePart);
      }
    }
    
    // Personalitate
    if (profile.personality != null) {
      final personality = profile.personality!;
      String personalityPart = 'Ca personalitate, ';
      
      if (personality.socialType.isNotEmpty) {
        switch (personality.socialType) {
          case 'Extrovertit':
            personalityPart += 'sunt o persoană extrovertită care iubește compania oamenilor';
            break;
          case 'Introvertit':
            personalityPart += 'sunt o fire mai introvertită care apreciază momentele de liniște';
            break;
          case 'Ambivert':
            personalityPart += 'sunt echilibrat/ă între timp petrecut în societate și momente de reflexie';
            break;
          default:
            personalityPart += 'am o personalitate interesantă';
        }
        personalityPart += '.';
        bioSections.add(personalityPart);
      }
    }
    
    // Valori
    if (profile.values != null) {
      final values = profile.values!;
      String valuesPart = '';
      
      if (values.religion.isNotEmpty && values.religion != 'Prefer să nu spun') {
        valuesPart += 'Religia (${values.religion}) este importantă pentru mine. ';
      }
      
      if (values.familyPlans.isNotEmpty && values.familyPlans != 'Incert') {
        valuesPart += 'În privința familiei: ${values.familyPlans.toLowerCase()}. ';
      }
      
      if (values.careerAmbition.isNotEmpty) {
        switch (values.careerAmbition) {
          case 'Foarte ambițios':
            valuesPart += 'Sunt ambițios/oasă în carieră și îmi doresc să evoluez continuu profesional.';
            break;
          case 'Moderat':
            valuesPart += 'Prefer să mențin un echilibru sănătos între viața profesională și personală.';
            break;
          case 'Relaxat':
            valuesPart += 'Îmi place să trăiesc fără prea mult stres legat de carieră.';
            break;
        }
      }
      
      if (valuesPart.isNotEmpty) {
        bioSections.add(valuesPart);
      }
    }
    
    // Interese
    if (profile.interests != null && profile.interests!.hobbies.isNotEmpty) {
      String interestsPart = 'În timpul liber îmi place să mă dedic pasiunilor mele: ';
      interestsPart += profile.interests!.hobbies.join(', ').toLowerCase() + '.';
      bioSections.add(interestsPart);
    }
    
    String generatedBio = bioSections.join(' ');
    
    setState(() {
      _bio = generatedBio;
      _bioController.text = generatedBio;
    });
    
    return generatedBio;
  }

  bool _canContinue() {
    return _photoUrls.isNotEmpty && _bio.length >= 50;
  }

  Future<void> _pickImage() async {
    if (_photoUrls.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maxim 6 fotografii'))
      );
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true, // Important pentru web - încarcă bytes
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // Verificăm dacă bytes-urile sunt disponibile
        if (file.bytes == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Eroare: Fișierul nu conține date. Încearcă alt fișier.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
        
        // Verificăm dimensiunea fișierului (max 5MB)
        if (file.bytes!.length > 5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Imaginea este prea mare! Maxim 5MB.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
        
        // Upload la Cloudinary prin API
        final response = await ApiService.uploadPhoto(
          file.bytes!,
          file.name,
        );
        
        if (response['success'] == true) {
          setState(() {
            _photoUrls.add(response['photo']['url']);
            _cloudinaryIds.add(response['photo']['cloudinaryId']);
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Fotografie adăugată: ${file.name}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la încărcarea imaginii: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removePhoto(int index) async {
    try {
      final cloudinaryId = _cloudinaryIds[index];
      await ApiService.deletePhoto(cloudinaryId);
      
      setState(() {
        _photoUrls.removeAt(index);
        _cloudinaryIds.removeAt(index);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fotografie ștearsă'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la ștergerea fotografiei: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _continue() {
    if (_canContinue()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // Salvează URL-urile Cloudinary și bio
      final photos = Photos(
        photoUrls: _photoUrls,
        bio: _bio,
      );
      
      userProvider.updatePhotos(photos);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PartnerCriteriaScreen())
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adaugă cel puțin o fotografie și o bio de minim 50 caractere'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fotografii & Bio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileProgressIndicator(currentStep: 6, totalSteps: 7),
            const SizedBox(height: 32),
            
            Text(
              'Fotografii (minim 1, recomandat 3-6)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _photoUrls.length + (_photoUrls.length < 6 ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _photoUrls.length) {
                  return _buildPhotoCard(index);
                } else {
                  return _buildAddPhotoCard();
                }
              },
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'Bio (minim 50 caractere)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Descrie-te pe scurt. Ce te face unic/ă? Ce cauți?',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            
            TextField(
              controller: _bioController,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Ex: Pasionat de călătorii și gătit, iubesc discuțiile profunde și filmele cu plot twist-uri. Caut pe cineva care prețuiește autenticitatea și are simțul umorului...',
                border: const OutlineInputBorder(),
                counterText: '${_bioController.text.length}/500',
              ),
              onChanged: (value) {
                setState(() {
                  _bio = value;
                });
              },
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
                    onPressed: _canContinue() ? _saveAndContinue : null,
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
    );
  }

  Widget _buildPhotoCard(int index) {
    final photoUrl = _photoUrls[index];
    
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).primaryColor, width: 2),
            image: DecorationImage(
              image: NetworkImage(photoUrl), // Load from Cloudinary
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removePhoto(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          left: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Foto ${index + 1}',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoCard() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[400]!, width: 2, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey[600]),
            const SizedBox(height: 4),
            Text(
              'Adaugă poză',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}

// Clasă pentru a stoca datele imaginii
class PhotoData {
  final String name;
  final Uint8List bytes;
  final String path;

  PhotoData({
    required this.name,
    required this.bytes,
    required this.path,
  });
}
