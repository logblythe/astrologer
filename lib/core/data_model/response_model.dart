class ResponseModel {
  String message;
  String error;
  List<dynamic> mapList;
  Map<String, dynamic> map;

  ResponseModel({this.message, this.error, this.mapList, this.map});

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      message: json['message'],
      error: json['error'],
      mapList: json['data'],
    );
  }

  factory ResponseModel.fromJsonWithoutDataList(Map<String, dynamic> json) {
    return ResponseModel(
      message: json['message'],
      error: json['error'],
      map: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'error': error, 'mapList': mapList, 'map': map};
  }

  factory ResponseModel.withError(String error) => ResponseModel(error: error);
}
