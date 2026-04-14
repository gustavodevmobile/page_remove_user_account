import 'package:memon_url_delete_user/Service/service.dart';

class Controller {
  static UserService service = UserService();

 static Future<String> fetchDeleteAccountInfo({
    required String nickname,
    required String email,
    required String password,
  }) async {
    try {
      final response = await service.getDeleteAccountInfo(
        nickname: nickname,
        email: email,
        password: password,
      );
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to fetch delete account info');
      }
    } catch (e) {
      print('Error in Controller: $e');
      rethrow;
    }
  }
}
