import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../models/compatibility_result.dart';

class MatchingProvider extends ChangeNotifier {
  final List<CompatibilityResult> _matches = [];
  
  List<CompatibilityResult> get matches => _matches;
  
  CompatibilityResult calculateCompatibility(UserProfile currentUser, UserProfile otherUser) {
    if (_hasAbsoluteIncompatibility(currentUser, otherUser)) {
      return CompatibilityResult(
        userId: otherUser.userId,
        overallScore: 0,
        scoreBreakdown: {},
        compatibleAreas: [],
        incompatibleAreas: ['Deal-breaker absolut'],
        summaryText: 'Incompatibilitate pe criterii esențiale',
      );
    }
    
    Map<String, double> breakdown = {};
    List<String> compatible = [];
    List<String> incompatible = [];
    
    double lifestyleScore = _calculateLifestyleScore(currentUser, otherUser);
    breakdown['Lifestyle'] = lifestyleScore;
    if (lifestyleScore >= 70) compatible.add('Stiluri de viață compatibile');
    else if (lifestyleScore < 50) incompatible.add('Diferențe majore în lifestyle');
    
    double valuesScore = _calculateValuesScore(currentUser, otherUser);
    breakdown['Values'] = valuesScore;
    if (valuesScore >= 70) compatible.add('Valori similare');
    else if (valuesScore < 50) incompatible.add('Valori diferite');
    
    double intentionScore = _calculateIntentionScore(currentUser, otherUser);
    breakdown['Intention'] = intentionScore;
    if (intentionScore >= 70) compatible.add('Intenții aliniate');
    else if (intentionScore < 50) incompatible.add('Intenții diferite');
    
    double personalityScore = _calculatePersonalityScore(currentUser, otherUser);
    breakdown['Personality'] = personalityScore;
    if (personalityScore >= 70) compatible.add('Personalități complementare');
    else if (personalityScore < 50) incompatible.add('Clash de personalitate');
    
    double othersScore = _calculateOthersScore(currentUser, otherUser);
    breakdown['Others'] = othersScore;
    
    double overall = (lifestyleScore * 0.30) + 
                     (valuesScore * 0.25) + 
                     (intentionScore * 0.25) + 
                     (personalityScore * 0.15) + 
                     (othersScore * 0.05);
    
    String summary = _generateSummary(overall, compatible, incompatible);
    
    return CompatibilityResult(
      userId: otherUser.userId,
      overallScore: overall,
      scoreBreakdown: breakdown,
      compatibleAreas: compatible,
      incompatibleAreas: incompatible,
      summaryText: summary,
    );
  }
  
  bool _hasAbsoluteIncompatibility(UserProfile user1, UserProfile user2) {
    if (user1.whatIDontWant?.dealbreakers.contains('fumători') ?? false) {
      if (user2.lifestyle?.smoking == 'regulat') return true;
    }
    if (user1.whatIDontWant?.dealbreakers.contains('persoane indisponibile emoțional') ?? false) {
      if (user2.intention?.emotionalAvailability == 'complicat' || 
          user2.intention?.emotionalAvailability == 'încă mă vindec din trecut') {
        return true;
      }
    }
    return false;
  }
  
  double _calculateLifestyleScore(UserProfile user1, UserProfile user2) {
    if (user1.lifestyle == null || user2.lifestyle == null) return 50;
    double score = 0;
    int factors = 0;
    
    if (user1.lifestyle!.schedule == user2.lifestyle!.schedule) score += 100;
    else if (_isScheduleCompatible(user1.lifestyle!.schedule, user2.lifestyle!.schedule)) score += 70;
    else score += 30;
    factors++;
    
    if (user1.lifestyle!.smoking == user2.lifestyle!.smoking) score += 100;
    else score += 40;
    factors++;
    
    if (user1.lifestyle!.alcohol == user2.lifestyle!.alcohol) score += 100;
    else if (_isAlcoholCompatible(user1.lifestyle!.alcohol, user2.lifestyle!.alcohol)) score += 80;
    else score += 50;
    factors++;
    
    if (user1.lifestyle!.exercise == user2.lifestyle!.exercise) score += 100;
    else score += 60;
    factors++;
    
    if (user1.lifestyle!.diet == user2.lifestyle!.diet) score += 100;
    else if (user1.lifestyle!.diet == 'orice' || user2.lifestyle!.diet == 'orice') score += 80;
    else score += 30;
    factors++;
    
    if (user1.lifestyle!.pets == user2.lifestyle!.pets) score += 100;
    else if (_isPetsCompatible(user1.lifestyle!.pets, user2.lifestyle!.pets)) score += 70;
    else score += 40;
    factors++;
    
    return score / factors;
  }
  
  bool _isScheduleCompatible(String schedule1, String schedule2) {
    if (schedule1 == 'ture de noapte' && schedule2 == 'ture de noapte') return true;
    if (schedule1 == 'program flexibil' || schedule2 == 'program flexibil') return true;
    return false;
  }
  
  bool _isAlcoholCompatible(String alcohol1, String alcohol2) {
    List<String> moderate = ['niciodată', 'social'];
    return moderate.contains(alcohol1) && moderate.contains(alcohol2);
  }
  
  bool _isPetsCompatible(String pets1, String pets2) {
    if (pets1.contains('nu am dar îmi plac') || pets2.contains('nu am dar îmi plac')) return true;
    return false;
  }
  
  double _calculateValuesScore(UserProfile user1, UserProfile user2) {
    if (user1.values == null || user2.values == null) return 50;
    double score = 0;
    int factors = 0;
    
    // Family plans compatibility
    if (user1.values!.familyPlans == user2.values!.familyPlans) score += 100;
    else if (_areFamilyPlansCompatible(user1.values!.familyPlans, user2.values!.familyPlans)) score += 60;
    else score += 20;
    factors++;
    
    // Religion compatibility
    if (user1.values!.religion == user2.values!.religion) score += 100;
    else if (user1.values!.religion.contains('nu prea') || user2.values!.religion.contains('nu prea')) score += 70;
    else score += 30;
    factors++;
    
    // Politics compatibility
    if (user1.values!.politics == user2.values!.politics) score += 100;
    else if (user1.values!.politics.contains('evităm') || user2.values!.politics.contains('evităm')) score += 80;
    else score += 50;
    factors++;
    
    // Money compatibility
    if (user1.values!.money == user2.values!.money) score += 100;
    else if (user1.values!.money.contains('echilibrat') || user2.values!.money.contains('echilibrat')) score += 80;
    else score += 40;
    factors++;
    
    // Career ambition compatibility
    if (user1.values!.careerAmbition == user2.values!.careerAmbition) score += 100;
    else if (user1.values!.careerAmbition.contains('echilibru') || user2.values!.careerAmbition.contains('echilibru')) score += 85;
    else score += 50;
    factors++;
    
    return score / factors;
  }
  
  bool _areFamilyPlansCompatible(String plan1, String plan2) {
    // If one is unsure, they're compatible with most
    if (plan1.contains('nu sunt sigur') || plan2.contains('nu sunt sigur')) return true;
    
    // Never want vs want = incompatible
    if ((plan1.contains('niciodată') && (plan2.contains('apropiat') || plan2.contains('târziu'))) ||
        (plan2.contains('niciodată') && (plan1.contains('apropiat') || plan1.contains('târziu')))) {
      return false;
    }
    
    return true;
  }
  
  bool _isSpiritualityCompatible(String spirit1, String spirit2) {
    // Deprecated but kept for compatibility
    return true;
  }
  
  double _calculateIntentionScore(UserProfile user1, UserProfile user2) {
    if (user1.intention == null || user2.intention == null) return 50;
    double score = 0;
    
    if (user1.intention!.relationshipGoal == user2.intention!.relationshipGoal) score += 100;
    else if (user1.intention!.relationshipGoal == 'nu știu încă' || user2.intention!.relationshipGoal == 'nu știu încă') score += 60;
    else score += 20;
    
    double emotionalScore = 0;
    if (user1.intention!.emotionalAvailability == 'complet disponibil' && user2.intention!.emotionalAvailability == 'complet disponibil') emotionalScore = 100;
    else if (user1.intention!.emotionalAvailability == 'complicat' || user2.intention!.emotionalAvailability == 'complicat') emotionalScore = 20;
    else emotionalScore = 60;
    
    return (score + emotionalScore) / 2;
  }
  
  double _calculatePersonalityScore(UserProfile user1, UserProfile user2) {
    if (user1.personality == null || user2.personality == null) return 50;
    double score = 0;
    int factors = 0;
    
    if (user1.personality!.socialType == user2.personality!.socialType) score += 100;
    else if (user1.personality!.socialType == 'ambivert' || user2.personality!.socialType == 'ambivert') score += 85;
    else score += 60;
    factors++;
    
    if (user1.personality!.conflictStyle == user2.personality!.conflictStyle) score += 100;
    else if (user1.personality!.conflictStyle == 'discut calm' || user2.personality!.conflictStyle == 'discut calm') score += 80;
    else score += 40;
    factors++;
    
    if (user1.personality!.emotionalPace == user2.personality!.emotionalPace) score += 100;
    else if (user1.personality!.emotionalPace == 'îmi iau timp' || user2.personality!.emotionalPace == 'îmi iau timp') score += 70;
    else score += 40;
    factors++;
    
    if (user1.personality!.personalSpace == user2.personality!.personalSpace) score += 100;
    else if (user1.personality!.personalSpace == 'balansat' || user2.personality!.personalSpace == 'balansat') score += 80;
    else score += 30;
    factors++;
    
    return score / factors;
  }
  
  double _calculateOthersScore(UserProfile user1, UserProfile user2) {
    if (user1.basicIdentity == null || user2.basicIdentity == null) return 50;
    double score = 0;
    int factors = 0;
    
    score += 70;
    factors++;
    
    if (user1.basicIdentity!.city == user2.basicIdentity!.city) score += 100;
    else score += 40;
    factors++;
    
    int ageDiff = (user1.basicIdentity!.age - user2.basicIdentity!.age).abs();
    if (ageDiff <= 3) score += 100;
    else if (ageDiff <= 7) score += 80;
    else if (ageDiff <= 12) score += 60;
    else score += 30;
    factors++;
    
    return score / factors;
  }
  
  String _generateSummary(double score, List<String> compatible, List<String> incompatible) {
    if (score >= 85) return 'Compatibilitate excepțională! ${compatible.join(", ")}';
    else if (score >= 70) return 'Compatibilitate foarte bună. ${compatible.join(", ")}';
    else if (score >= 55) return 'Compatibilitate bună, cu spațiu pentru compromis. ${compatible.isNotEmpty ? compatible.join(", ") : ""}';
    else if (score >= 40) return 'Compatibilitate moderată. Diferențe în: ${incompatible.join(", ")}';
    else return 'Compatibilitate scăzută. ${incompatible.join(", ")}';
  }
  
  void addMatch(CompatibilityResult result) {
    _matches.add(result);
    _matches.sort((a, b) => b.overallScore.compareTo(a.overallScore));
    notifyListeners();
  }
  
  void clearMatches() {
    _matches.clear();
    notifyListeners();
  }
}
