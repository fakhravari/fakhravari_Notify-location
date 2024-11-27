class ModelResult {
  String? title;
  String? message;
  bool? status;

  ModelResult({this.title, this.message, this.status});

  ModelResult.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    message = json['message'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['message'] = message;
    data['status'] = status;

    return data;
  }
}

class ModelResult2 {
  String? title;
  String? message;

  ModelResult2({this.title, this.message});

  ModelResult2.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    message = json['message'];
  }
}
