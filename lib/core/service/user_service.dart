import 'package:astrologer/core/enum/gender.dart';
import 'package:astrologer/core/data_model/login_response.dart';
import 'package:astrologer/core/data_model/user_model.dart';
import 'package:astrologer/core/service/api.dart';
import 'package:astrologer/core/service/db_provider.dart';
import 'package:astrologer/core/utils/shared_pref_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

class UserService {
  final Api _api;
  final DbProvider _db;
  final SharedPrefHelper _sharedPrefHelper;
  LoginResponse _loginResponse;
  UserModel _user;
  String _fcmToken;
  int _userId;

  int get userId => _userId;

  LoginResponse get loginResponse => _loginResponse;

  UserModel get user => _user;

  UserService({
    @required Api api,
    @required DbProvider dbProvider,
    @required SharedPrefHelper sharedPrefHelper,
  })  : _api = api,
        _db = dbProvider,
        _sharedPrefHelper = sharedPrefHelper {
    init();
  }

  init() async {
    _userId = await _sharedPrefHelper.getInteger(KEY_USER_ID);
    _getFcmToken();
  }

  Future<String> _getFcmToken() async {
    if (_fcmToken == null) {
      _fcmToken = await FirebaseMessaging().getToken();
    }
    print('FCM TOKEN $_fcmToken');
    return _fcmToken;
  }

  Future<LoginResponse> performLogin(String email, String password) async {
    String fcmToken = await _getFcmToken();
    LoginResponse _loginResponse =
        await _api.performLogin(email, password, fcmToken);
    if (_loginResponse.error == null) {
      await _db.addUser(_loginResponse.userDetails);
      await _sharedPrefHelper.setString(KEY_TOKEN, _loginResponse.token);
      await _sharedPrefHelper.setInt(KEY_USER_ID, _loginResponse.userDetails.userId);
      if (_loginResponse.firstLogin) {
        await _sharedPrefHelper.setInt(KEY_FREE_QUES_COUNT, 1);
      }
    }
    return _loginResponse;
  }

  Future<bool> userExists() => _db.userExists();

  Future<UserModel> getLoggedInUser() async {
    _user = await _db.getLoggedInUser();
    return _user;
  }

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
    UserModel userModel = await _api.registerUser(
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
    if (userModel.errorMessage == null) {
      await performLogin(email, password);
    }
    return userModel;
  }
}
