class ErrorModel {
  String? status;
  String? response;

  ErrorModel({this.status, this.response});

  ErrorModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    response = json['response'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['status'] = status;
    data['response'] = response;
    return data;
  }
}
