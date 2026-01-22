import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  static String? _token;
  
  static void setToken(String? token) {
    _token = token;
  }
  
  static String? getToken() => _token;
  
  static Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }
  
  // Auth endpoints
  static Future<Map<String, dynamic>> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authRegister}'),
      headers: _getHeaders(includeAuth: false),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    
    return _handleResponse(response);
  }
  
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authLogin}'),
      headers: _getHeaders(includeAuth: false),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    
    return _handleResponse(response);
  }
  
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authMe}'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response);
  }
  
  static Future<Map<String, dynamic>> deleteAccount() async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authDeleteAccount}'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response);
  }
  
  // Profile endpoints
  static Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.profile}'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response);
  }
  
  static Future<Map<String, dynamic>> saveProfile(Map<String, dynamic> profileData) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.profile}'),
      headers: _getHeaders(),
      body: jsonEncode(profileData),
    );
    
    return _handleResponse(response);
  }
  
  static Future<Map<String, dynamic>> deleteProfile() async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.profile}'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response);
  }
  
  static Future<Map<String, dynamic>> getMatches() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.profileMatches}'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response);
  }
  
  // Photo endpoints
  static Future<Map<String, dynamic>> uploadPhoto(List<int> imageBytes, String fileName) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.photoUpload}'),
    );
    
    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }
    
    request.files.add(
      http.MultipartFile.fromBytes(
        'photo',
        imageBytes,
        filename: fileName,
      ),
    );
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    return _handleResponse(response);
  }
  
  static Future<Map<String, dynamic>> deletePhoto(String cloudinaryId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.photoDelete(cloudinaryId)}'),
      headers: _getHeaders(),
    );
    
    return _handleResponse(response);
  }
  
  // Response handler
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Eroare la comunicarea cu serverul');
    }
  }
}
