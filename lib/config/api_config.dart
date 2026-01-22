class ApiConfig {
  // Local development - change to Railway URL after deployment
  static const String baseUrl = 'http://localhost:5000/api';
  
  // After Railway deploy, use: https://your-app.up.railway.app/api
  
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
