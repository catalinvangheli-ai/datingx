import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthUser {
  final String id;
  final String email;
  final String passwordHash;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  AuthUser({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
    this.lastLoginAt,
  });

  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool verifyPassword(String password) {
    return passwordHash == hashPassword(password);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'passwordHash': passwordHash,
    'createdAt': createdAt.toIso8601String(),
    'lastLoginAt': lastLoginAt?.toIso8601String(),
  };

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] ?? '',
    email: json['email'] ?? '',
    passwordHash: json['passwordHash'] ?? '',
    createdAt: DateTime.parse(json['createdAt']),
    lastLoginAt: json['lastLoginAt'] != null 
        ? DateTime.parse(json['lastLoginAt']) 
        : null,
  );

  AuthUser copyWith({
    String? id,
    String? email,
    String? passwordHash,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
