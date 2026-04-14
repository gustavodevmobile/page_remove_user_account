// import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart' as http;

// class UserService {
//   final apiUrl = dotenv.env['API_URL'];

//   Future<http.Response> getDeleteAccountInfo({
//     required String nickname,
//     required String email,
//     required String password,
//   }) async {
//     try {
//   final url = Uri.parse('$apiUrl/users/get-delete-account');
//   final response = await http.post(
//     url,
//     headers: {'Content-Type': 'application/json'},
//     body: jsonEncode({
//       'nickname': nickname,
//       'email': email,
//       'password': password,
//     }),
//   );
//   return response;
// }catch (e) {
//   print('Error fetching delete account info: $e');
//   rethrow;
// }
//   }
// }
