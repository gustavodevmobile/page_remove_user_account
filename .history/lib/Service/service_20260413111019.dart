import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl = 

  

  Future<http.Response> getDeleteAccountInfo({
    required String nickname,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/users/get-delete-account');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nickname': nickname,
        'email': email,
        'password': password,
      }),
    );
    return response;
  }
}