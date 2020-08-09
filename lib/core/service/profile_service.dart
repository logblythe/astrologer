import 'dart:async';
import 'dart:convert';
import 'package:astrologer/core/data_model/image_model.dart';
import 'package:astrologer/core/data_model/user_model.dart';
import 'package:astrologer/core/service/api.dart';
import 'package:astrologer/core/service/db_provider.dart';
import 'package:astrologer/core/utils/shared_pref_helper.dart';
import 'package:flutter/material.dart';

class ProfileService {
  final DbProvider _db;
  final Api _api;
  final SharedPrefHelper _prefHelper;
  final StreamController _streamController = StreamController<String>();

  UserModel _user;

  UserModel get user => _user;

  Stream<String> get profilePic => _streamController.stream;

  ProfileService(
      {@required DbProvider db,
      @required Api api,
      @required SharedPrefHelper prefHelper})
      : this._db = db,
        this._api = api,
        this._prefHelper = prefHelper;

//  imageUrl() async => _prefHelper.getString(KEY_IMAGE_URL);

  Future<UserModel> getLoggedInUser() async {
    _user = await _db.getLoggedInUser();
    print('User from db${jsonEncode(_user.toMapForDb())}');
    return _user;
  }

  Future<UserModel> updateUser(UserModel user) async {
    UserModel userModel = await _api.updateProfile(user);
    if (userModel.errorMessage == null) {
      _db.updateUser(userModel);
    }
    return userModel;
  }

  Future<ImageModel> upload(imageFile) async {
    ImageModel model = await _api.upload(imageFile);
    if (model != null) {
      _prefHelper.setString(KEY_IMAGE_URL, model.fileDownloadUri);
      _streamController.sink.add(model.fileDownloadUri);
    }
    return model;
  }

  void dispose() {
    _streamController.close();
  }
}
