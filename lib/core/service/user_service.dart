import 'package:astrologer/core/enum/gender.dart';
import 'package:astrologer/core/data_model/login_response.dart';
import 'package:astrologer/core/data_model/user_model.dart';
import 'package:astrologer/core/service/api.dart';
import 'package:astrologer/core/service/db_provider.dart';
import 'package:astrologer/core/utils/shared_pref_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final Api _api;
  final DbProvider _db;
  LoginResponse _loginResponse;
  String fcmToken;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  LoginResponse get loginResponse => _loginResponse;

  UserService({Api api, DbProvider dbProvider})
      : _api = api,
        _db = dbProvider {
    _getFcmToken();
  }

  void _getFcmToken() async {
    fcmToken = await _fcm.getToken();
    print('FCM TOKEN $fcmToken');
  }

  Future<LoginResponse> performLogin(String email, String password) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _loginResponse = await _api.performLogin(email, password, fcmToken);
    if (_loginResponse.error == null) {
      await _db.addUser(_loginResponse.user);
      await sharedPreferences.setString(KEY_TOKEN, _loginResponse.token);
      await sharedPreferences.setInt(KEY_USER_ID, _loginResponse.user.userId);
    }
    return _loginResponse;
  }

  Future<bool> userExists() => _db.userExists();

  Future<UserModel> register(
      Gender gender,
      String name,
      String lname,
      String dob,
      String time,
      bool timeAccurate,
      String country,
      String location,
      String email,
      String password,
      String phone,
      String state,
      String fcmToken) async {
    print('time and date $time $dob');
    var userModel = await _api.registerUser(
      gender,
      name,
      lname,
      email,
      password,
      phone,
      location,
      state,
      country,
      dob,
      time,
      timeAccurate,
    );
    await performLogin(email, password);
    return userModel;
  }
}
