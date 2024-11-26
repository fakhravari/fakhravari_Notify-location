class RegisterUserStep1 {
  String? message;
  bool? status;

  RegisterUserStep1({this.message, this.status});

  RegisterUserStep1.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['status'] = status;

    return data;
  }
}
