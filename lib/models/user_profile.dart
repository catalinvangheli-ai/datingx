class BasicIdentity {
  final String gender;
  final int age;
  final String country;
  final String city;
  final int height;
  final String occupation;

  BasicIdentity({
    required this.gender,
    required this.age,
    required this.country,
    required this.city,
    required this.height,
    required this.occupation,
  });

  bool isComplete() {
    return gender.isNotEmpty && 
           age > 0 && 
           country.isNotEmpty &&
           city.isNotEmpty && 
           height > 0 && 
           occupation.isNotEmpty;
  }

  Map<String, dynamic> toJson() => {
    'gender': gender,
    'age': age,
    'country': country,
    'city': city,
    'height': height,
    'occupation': occupation,
  };

  factory BasicIdentity.fromJson(Map<String, dynamic> json) => BasicIdentity(
    gender: json['gender'] ?? '',
    age: json['age'] ?? 0,
    country: json['country'] ?? '',
    city: json['city'] ?? '',
    height: json['height'] ?? 0,
    occupation: json['occupation'] ?? '',
  );
}

class Lifestyle {
  final String schedule;
  final String smoking;
  final String alcohol;
  final String exercise;
  final String diet;
  final String pets;

  Lifestyle({
    required this.schedule,
    required this.smoking,
    required this.alcohol,
    required this.exercise,
    required this.diet,
    required this.pets,
  });

  bool isComplete() {
    return schedule.isNotEmpty && 
           smoking.isNotEmpty && 
           alcohol.isNotEmpty && 
           exercise.isNotEmpty && 
           diet.isNotEmpty && 
           pets.isNotEmpty;
  }

  Map<String, dynamic> toJson() => {
    'schedule': schedule,
    'smoking': smoking,
    'alcohol': alcohol,
    'exercise': exercise,
    'diet': diet,
    'pets': pets,
  };

  factory Lifestyle.fromJson(Map<String, dynamic> json) => Lifestyle(
    schedule: json['schedule'] ?? '',
    smoking: json['smoking'] ?? '',
    alcohol: json['alcohol'] ?? '',
    exercise: json['exercise'] ?? '',
    diet: json['diet'] ?? '',
    pets: json['pets'] ?? '',
  );
}

class Personality {
  final String socialType;
  final String conflictStyle;
  final String emotionalPace;
  final String personalSpace;

  Personality({
    required this.socialType,
    required this.conflictStyle,
    required this.emotionalPace,
    required this.personalSpace,
  });

  bool isComplete() {
    return socialType.isNotEmpty && 
           conflictStyle.isNotEmpty && 
           emotionalPace.isNotEmpty && 
           personalSpace.isNotEmpty;
  }

  Map<String, dynamic> toJson() => {
    'socialType': socialType,
    'conflictStyle': conflictStyle,
    'emotionalPace': emotionalPace,
    'personalSpace': personalSpace,
  };

  factory Personality.fromJson(Map<String, dynamic> json) => Personality(
    socialType: json['socialType'] ?? '',
    conflictStyle: json['conflictStyle'] ?? '',
    emotionalPace: json['emotionalPace'] ?? '',
    personalSpace: json['personalSpace'] ?? '',
  );
}

class Values {
  final String familyPlans;
  final String religion;
  final String politics;
  final String money;
  final String careerAmbition;

  Values({
    required this.familyPlans,
    required this.religion,
    required this.politics,
    required this.money,
    required this.careerAmbition,
  });

  bool isComplete() {
    return familyPlans.isNotEmpty && 
           religion.isNotEmpty && 
           politics.isNotEmpty && 
           money.isNotEmpty && 
           careerAmbition.isNotEmpty;
  }

  Map<String, dynamic> toJson() => {
    'familyPlans': familyPlans,
    'religion': religion,
    'politics': politics,
    'money': money,
    'careerAmbition': careerAmbition,
  };

  factory Values.fromJson(Map<String, dynamic> json) => Values(
    familyPlans: json['familyPlans'] ?? '',
    religion: json['religion'] ?? '',
    politics: json['politics'] ?? '',
    money: json['money'] ?? '',
    careerAmbition: json['careerAmbition'] ?? '',
  );
}

class RelationshipIntention {
  final String relationshipGoal;
  final String emotionalAvailability;

  RelationshipIntention({
    required this.relationshipGoal,
    required this.emotionalAvailability,
  });

  bool isComplete() {
    return relationshipGoal.isNotEmpty && 
           emotionalAvailability.isNotEmpty;
  }

  Map<String, dynamic> toJson() => {
    'relationshipGoal': relationshipGoal,
    'emotionalAvailability': emotionalAvailability,
  };

  factory RelationshipIntention.fromJson(Map<String, dynamic> json) => RelationshipIntention(
    relationshipGoal: json['relationshipGoal'] ?? '',
    emotionalAvailability: json['emotionalAvailability'] ?? '',
  );
}

class WhatIOffer {
  final List<String> qualities;

  WhatIOffer({
    required this.qualities,
  });

  bool isComplete() {
    return qualities.isNotEmpty;
  }

  Map<String, dynamic> toJson() => {
    'qualities': qualities,
  };

  factory WhatIOffer.fromJson(Map<String, dynamic> json) => WhatIOffer(
    qualities: List<String>.from(json['qualities'] ?? []),
  );
}

class WhatIDontWant {
  final List<String> dealbreakers;

  WhatIDontWant({
    required this.dealbreakers,
  });

  bool isComplete() {
    return dealbreakers.isNotEmpty;
  }

  Map<String, dynamic> toJson() => {
    'dealbreakers': dealbreakers,
  };

  factory WhatIDontWant.fromJson(Map<String, dynamic> json) => WhatIDontWant(
    dealbreakers: List<String>.from(json['dealbreakers'] ?? []),
  );
}

class Interests {
  final List<String> hobbies;
  final List<String> musicTaste;
  final String travelAttitude;

  Interests({
    required this.hobbies,
    required this.musicTaste,
    required this.travelAttitude,
  });

  bool isComplete() {
    return hobbies.length >= 3 && 
           musicTaste.isNotEmpty && 
           travelAttitude.isNotEmpty;
  }

  Map<String, dynamic> toJson() => {
    'hobbies': hobbies,
    'musicTaste': musicTaste,
    'travelAttitude': travelAttitude,
  };

  factory Interests.fromJson(Map<String, dynamic> json) => Interests(
    hobbies: List<String>.from(json['hobbies'] ?? []),
    musicTaste: List<String>.from(json['musicTaste'] ?? []),
    travelAttitude: json['travelAttitude'] ?? '',
  );
}

class Photos {
  final List<String> photoUrls;
  final String bio;

  Photos({
    required this.photoUrls,
    required this.bio,
  });

  bool isComplete() {
    return photoUrls.isNotEmpty && bio.length >= 50;
  }

  Map<String, dynamic> toJson() => {
    'photoUrls': photoUrls,
    'bio': bio,
  };

  factory Photos.fromJson(Map<String, dynamic> json) => Photos(
    photoUrls: List<String>.from(json['photoUrls'] ?? []),
    bio: json['bio'] ?? '',
  );
}

class PartnerCriteria {
  final String ageRange;
  final int maxDistance;
  final List<String> dealBreakers;
  final List<String> mustHaves;

  PartnerCriteria({
    required this.ageRange,
    required this.maxDistance,
    required this.dealBreakers,
    required this.mustHaves,
  });

  bool isComplete() {
    return ageRange.isNotEmpty && 
           maxDistance > 0 && 
           (dealBreakers.isNotEmpty || mustHaves.isNotEmpty);
  }

  Map<String, dynamic> toJson() => {
    'ageRange': ageRange,
    'maxDistance': maxDistance,
    'dealBreakers': dealBreakers,
    'mustHaves': mustHaves,
  };

  factory PartnerCriteria.fromJson(Map<String, dynamic> json) => PartnerCriteria(
    ageRange: json['ageRange'] ?? '',
    maxDistance: json['maxDistance'] ?? 0,
    dealBreakers: List<String>.from(json['dealBreakers'] ?? []),
    mustHaves: List<String>.from(json['mustHaves'] ?? []),
  );
}


class UserProfile {
  final String userId;
  final BasicIdentity? basicIdentity;
  final Lifestyle? lifestyle;
  final Personality? personality;
  final Values? values;
  final Interests? interests;
  final Photos? photos;
  final PartnerCriteria? partnerCriteria;
  final RelationshipIntention? intention;
  final WhatIOffer? whatIOffer;
  final WhatIDontWant? whatIDontWant;
  
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.userId,
    this.basicIdentity,
    this.lifestyle,
    this.personality,
    this.values,
    this.interests,
    this.photos,
    this.partnerCriteria,
    this.intention,
    this.whatIOffer,
    this.whatIDontWant,
    required this.createdAt,
    required this.updatedAt,
  });

  int completionPercentage() {
    int completed = 0;
    int total = 7;

    if (basicIdentity?.isComplete() ?? false) completed++;
    if (lifestyle?.isComplete() ?? false) completed++;
    if (personality?.isComplete() ?? false) completed++;
    if (values?.isComplete() ?? false) completed++;
    if (interests?.isComplete() ?? false) completed++;
    if (photos?.isComplete() ?? false) completed++;
    if (partnerCriteria?.isComplete() ?? false) completed++;

    return ((completed / total) * 100).round();
  }

  bool isVisible() {
    return completionPercentage() >= 80;
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'basicIdentity': basicIdentity?.toJson(),
    'lifestyle': lifestyle?.toJson(),
    'personality': personality?.toJson(),
    'values': values?.toJson(),
    'interests': interests?.toJson(),
    'photos': photos?.toJson(),
    'partnerCriteria': partnerCriteria?.toJson(),
    'intention': intention?.toJson(),
    'whatIOffer': whatIOffer?.toJson(),
    'whatIDontWant': whatIDontWant?.toJson(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    userId: json['userId'] ?? '',
    basicIdentity: json['basicIdentity'] != null 
        ? BasicIdentity.fromJson(json['basicIdentity']) 
        : null,
    lifestyle: json['lifestyle'] != null 
        ? Lifestyle.fromJson(json['lifestyle']) 
        : null,
    personality: json['personality'] != null 
        ? Personality.fromJson(json['personality']) 
        : null,
    values: json['values'] != null 
        ? Values.fromJson(json['values']) 
        : null,
    interests: json['interests'] != null 
        ? Interests.fromJson(json['interests']) 
        : null,
    photos: json['photos'] != null 
        ? Photos.fromJson(json['photos']) 
        : null,
    partnerCriteria: json['partnerCriteria'] != null 
        ? PartnerCriteria.fromJson(json['partnerCriteria']) 
        : null,
    intention: json['intention'] != null 
        ? RelationshipIntention.fromJson(json['intention']) 
        : null,
    whatIOffer: json['whatIOffer'] != null 
        ? WhatIOffer.fromJson(json['whatIOffer']) 
        : null,
    whatIDontWant: json['whatIDontWant'] != null 
        ? WhatIDontWant.fromJson(json['whatIDontWant']) 
        : null,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );

  UserProfile copyWith({
    String? userId,
    BasicIdentity? basicIdentity,
    Lifestyle? lifestyle,
    Personality? personality,
    Values? values,
    Interests? interests,
    Photos? photos,
    PartnerCriteria? partnerCriteria,
    RelationshipIntention? intention,
    WhatIOffer? whatIOffer,
    WhatIDontWant? whatIDontWant,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      basicIdentity: basicIdentity ?? this.basicIdentity,
      lifestyle: lifestyle ?? this.lifestyle,
      personality: personality ?? this.personality,
      values: values ?? this.values,
      interests: interests ?? this.interests,
      photos: photos ?? this.photos,
      partnerCriteria: partnerCriteria ?? this.partnerCriteria,
      intention: intention ?? this.intention,
      whatIOffer: whatIOffer ?? this.whatIOffer,
      whatIDontWant: whatIDontWant ?? this.whatIDontWant,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
