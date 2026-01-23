import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

class UserProvider extends ChangeNotifier {
  UserProfile? _currentUser;
  
  UserProfile? get currentUser => _currentUser;
  
  void setUser(UserProfile user) {
    _currentUser = user;
    notifyListeners();
  }
  
  void updateBasicIdentity(BasicIdentity identity) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      basicIdentity: identity,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }
  
  void updateLifestyle(Lifestyle lifestyle) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      lifestyle: lifestyle,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }
  
  void updatePersonality(Personality personality) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      personality: personality,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }
  
  void updateValues(Values values) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      values: values,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }
  
  void updateIntention(RelationshipIntention intention) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      intention: intention,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }
  
  void updateWhatIOffer(WhatIOffer offer) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      whatIOffer: offer,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }
  
  void updateWhatIDontWant(WhatIDontWant dontWant) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      whatIDontWant: dontWant,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }
  
  void updateInterests(Interests interests) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      interests: interests,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }
  
  void updatePhotos(Photos photos) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      photos: photos,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }
  
  void updatePartnerCriteria(PartnerCriteria criteria) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      partnerCriteria: criteria,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }
  
  int getCompletionPercentage() {
    return _currentUser?.completionPercentage() ?? 0;
  }
  
  bool isProfileVisible() {
    return _currentUser?.isVisible() ?? false;
  }
  
  // Încarcă profilul din datele de pe server
  void loadUserProfileFromServer(Map<String, dynamic> profileData) {
    try {
      print('📥 Loading profile from server: $profileData');
      
      // Creează UserProfile din datele backend
      final userId = profileData['userId'] ?? profileData['_id'] ?? '';
      
      // Basic Identity - OBLIGATORIU pentru profileComplete
      BasicIdentity? basicIdentity;
      if (profileData['name'] != null) {
        basicIdentity = BasicIdentity(
          name: profileData['name'] ?? '',
          gender: profileData['gender'] ?? '',
          age: profileData['age'] ?? 25,
          country: profileData['country'] ?? '',
          city: profileData['city'] ?? '',
          height: profileData['height'] ?? 170,
          occupation: profileData['occupation'] ?? '',
          phoneNumber: profileData['phoneNumber'],
        );
      }
      
      // Lifestyle
      Lifestyle? lifestyle;
      if (profileData['smoking'] != null || profileData['alcohol'] != null) {
        lifestyle = Lifestyle(
          schedule: profileData['schedule'] ?? '',
          smoking: profileData['smoking'] ?? '',
          alcohol: profileData['alcohol'] ?? '',
          exercise: profileData['exercise'] ?? '',
          diet: profileData['diet'] ?? '',
          pets: profileData['pets'] ?? '',
        );
      }
      
      // Interests
      Interests? interests;
      if (profileData['hobbies'] != null && profileData['hobbies'] is List) {
        interests = Interests(
          hobbies: List<String>.from(profileData['hobbies'] ?? []),
          musicTaste: List<String>.from(profileData['musicTaste'] ?? []),
          travelAttitude: profileData['travelAttitude'] ?? '',
        );
      }
      
      _currentUser = UserProfile(
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        basicIdentity: basicIdentity,
        lifestyle: lifestyle,
        interests: interests,
      );
      
      print('✅ Profile loaded successfully. Completion: ${getCompletionPercentage()}%');
      notifyListeners();
    } catch (e) {
      print('❌ Eroare la parsarea profilului: $e');
    }
  }
}
