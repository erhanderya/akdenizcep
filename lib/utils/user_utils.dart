import 'package:akdeniz_cep/models/user_model.dart';
import 'package:akdeniz_cep/services/auth_service.dart';

class UserUtils {
  static Future<List<UserModel>> fetchUsersByIds(List<String> userIds) async {
    final AuthService authService = AuthService();
    List<UserModel> users = [];
    for (final uid in userIds) {
      final user = await authService.getUserData(uid);
      if (user != null) {
        users.add(user);
      }
    }
    return users;
  }
}
