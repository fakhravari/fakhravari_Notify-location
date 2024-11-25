class CaptchaResponse {
  final String message;
  final String? captchaImage;
  final String? captchaSecret;

  CaptchaResponse({
    required this.message,
    required this.captchaImage,
    required this.captchaSecret,
  });

  factory CaptchaResponse.fromJson(Map<String, dynamic> json) {
    return CaptchaResponse(
      message: json['message'] as String,
      captchaImage: json['data']?['captchaImage'] as String?,
      captchaSecret: json['data']?['captchaSecret'] as String?,
    );
  }
}
