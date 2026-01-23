class ApiConfig {
  // Production backend on Railway
  static const String baseUrl = 'https://datingx-production.up.railway.app/api';
  
  // For local development, use: http://localhost:5000/api
  
  // Endpoints
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authMe = '/auth/me';
  static const String authDeleteAccount = '/auth/account';
  
  static const String profile = '/profile';
  static const String profileMatches = '/profile/matches';
  
  static const String photoUpload = '/photo/upload';
  static String photoDelete(String cloudinaryId) => '/photo/$cloudinaryId';
}
