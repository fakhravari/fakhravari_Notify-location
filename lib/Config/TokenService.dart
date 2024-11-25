import 'package:fakhravari/DTO/TokenResponse.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  Future<void> saveTokens(TokenResponse tokenResponse) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', tokenResponse.token);
    await prefs.setString('tokenExpiresOn', tokenResponse.tokenExpiresOn);
    await prefs.setString('refreshToken', tokenResponse.refreshToken);
    await prefs.setString(
        'refreshTokenExpiresOn', tokenResponse.refreshTokenExpiresOn);
  }

  Future<TokenResponse?> getTokens() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? tokenExpiresOn = prefs.getString('tokenExpiresOn');
    String? refreshToken = prefs.getString('refreshToken');
    String? refreshTokenExpiresOn = prefs.getString('refreshTokenExpiresOn');

    if (token != null &&
        tokenExpiresOn != null &&
        refreshToken != null &&
        refreshTokenExpiresOn != null) {
      return TokenResponse(
        token: token,
        tokenExpiresOn: tokenExpiresOn,
        refreshToken: refreshToken,
        refreshTokenExpiresOn: refreshTokenExpiresOn,
      );
    }
    return null;
  }
}
