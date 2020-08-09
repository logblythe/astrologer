import 'package:astrologer/core/data_model/user_model.dart';

class LoginResponse {
  String error;
  String type;
  String token;
  bool firstLogin;
  List<String> welcomeMessageList;
  UserModel userDetails;

  LoginResponse.fromJsonMap(Map<String, dynamic> map)
      : type = map["type"],
        token = map["token"],
        firstLogin = map["firstLogin"],
        welcomeMessageList = List<String>.from(map["welcomeMessageList"] ?? []),
        error = map['token'] == null ? map['message'] : null,
        userDetails = map['token'] != null
            ? UserModel.fromJson(map["userDetails"])
            : null;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = type;
    data['token'] = token;
    data['firstLogin'] = firstLogin;
    data['welcomeMessageList'] = welcomeMessageList;
    data['userDetails'] = userDetails == null ? null : userDetails.toMapForDb();
    return data;
  }

  LoginResponse.withError(String error) : error = error;
}
