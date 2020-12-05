import 'package:astrologer/core/data_model/user_model.dart';
import 'package:astrologer/core/service/api.dart';
import 'package:astrologer/core/service/db_provider.dart';
import 'package:astrologer/core/utils/shared_pref_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class UserService {
  final Api _api;
  final DbProvider _db;
  final SharedPrefHelper _sharedPrefHelper;
  UserModel _user;
  String _fcmToken;
  int _userId;

  int get userId => _userId;

  UserModel get user => _user;

  set user(UserModel user) {
    _user = user;
  }

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

  Future<bool> userExists() => _db.userExists();

  Future<UserModel> getLoggedInUser() async {
    _user = await _db.getLoggedInUser();
    return _user;
  }

  Future<UserModel> register({UserModel user, String fcmToken}) async {
    UserModel userModel = await _api.registerUser(user);
    return userModel;
  }
}
