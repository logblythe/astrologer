import 'package:astrologer/core/data_model/login_response.dart';
import 'package:astrologer/core/service/home_service.dart';
import 'package:astrologer/core/service/user_service.dart';
import 'package:astrologer/core/view_model/base_view_model.dart';
import 'package:flutter/material.dart';

class LoginViewModel extends BaseViewModel {
  UserService _userService;
  HomeService _homeService;
  bool _obscureText = true;

  LoginViewModel({
    @required UserService userService,
    @required HomeService homeService,
  })  : this._userService = userService,
        this._homeService = homeService;

  get obscureText => _obscureText;

  Future<bool> userExists() => _userService.userExists();

  Future<LoginResponse> login(String email, String password) async {
    setBusy(true);
    var loginResponse = await _userService.performLogin(email, password);
    if (loginResponse.error != null) {
      setError(loginResponse.error);
    } else {
      _homeService.addFreeCountToSink(1);
      setBusy(false);
    }
    return loginResponse;
  }

  void toggleObscureText() {
    _obscureText = !_obscureText;
    notifyListeners();
  }
}
