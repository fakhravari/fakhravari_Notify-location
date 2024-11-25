class TokenResponse {
  String token;
  String tokenExpiresOn;
  String refreshToken;
  String refreshTokenExpiresOn;

  TokenResponse({
    required this.token,
    required this.tokenExpiresOn,
    required this.refreshToken,
    required this.refreshTokenExpiresOn,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      token: json['token'],
      tokenExpiresOn: json['tokenExpiresOn'],
      refreshToken: json['refreshToken'],
      refreshTokenExpiresOn: json['refreshTokenExpiresOn'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'tokenExpiresOn': tokenExpiresOn,
      'refreshToken': refreshToken,
      'refreshTokenExpiresOn': refreshTokenExpiresOn,
    };
  }
}
