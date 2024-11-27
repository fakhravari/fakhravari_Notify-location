import 'package:fakhravari/DTO/LoginResult.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  Future<void> saveTokens(LoginDataToken tokenResponse, bool mobile) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mobileActive', mobile);
    await prefs.setString('token', tokenResponse.token!);
    await prefs.setString('tokenExpiresOn', tokenResponse.tokenExpiresOn!);
    await prefs.setString('refreshToken', tokenResponse.refreshToken!);
    await prefs.setString(
        'refreshTokenExpiresOn', tokenResponse.refreshTokenExpiresOn!);
  }

  Future<LoginDataToken?> getTokens() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? tokenExpiresOn = prefs.getString('tokenExpiresOn');
    String? refreshToken = prefs.getString('refreshToken');
    String? refreshTokenExpiresOn = prefs.getString('refreshTokenExpiresOn');

    if (token != null &&
        tokenExpiresOn != null &&
        refreshToken != null &&
        refreshTokenExpiresOn != null) {
      return LoginDataToken(
          token: token,
          tokenExpiresOn: tokenExpiresOn,
          refreshToken: refreshToken,
          refreshTokenExpiresOn: refreshTokenExpiresOn);
    }
    return null;
  }
}
