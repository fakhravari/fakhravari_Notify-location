class LoginResult {
  String? message;
  LoginDataToken? data;

  LoginResult({this.message, this.data});

  LoginResult.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? LoginDataToken.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class LoginDataToken {
  String? token;
  String? tokenExpiresOn;
  String? refreshToken;
  String? refreshTokenExpiresOn;

  LoginDataToken(
      {this.token,
      this.tokenExpiresOn,
      this.refreshToken,
      this.refreshTokenExpiresOn});

  LoginDataToken.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    tokenExpiresOn = json['tokenExpiresOn'];
    refreshToken = json['refreshToken'];
    refreshTokenExpiresOn = json['refreshTokenExpiresOn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = this.token;
    data['tokenExpiresOn'] = this.tokenExpiresOn;
    data['refreshToken'] = this.refreshToken;
    data['refreshTokenExpiresOn'] = this.refreshTokenExpiresOn;
    return data;
  }
}
