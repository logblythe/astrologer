import 'dart:convert';

import 'package:astrologer/core/data_model/user_model.dart';
import 'package:astrologer/core/service/api.dart';
import 'package:astrologer/core/service/db_provider.dart';

class ProfileService {
  final DbProvider _db;
  final Api _api;

  UserModel _user;

  UserModel get user => _user;

  ProfileService({DbProvider db, Api api})
      : this._db = db,
        this._api = api;

  Future<UserModel> getLoggedInUser() async {
    _user = await _db.getLoggedInUser();
    return _user;
  }

  Future<int> updateUser(UserModel user) async {
    print('the user model $jsonEncode(user)}');
    return await _db.updateUser(user);
  }
}
