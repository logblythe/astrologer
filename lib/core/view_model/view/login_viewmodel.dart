import 'package:astrologer/core/data_model/login_response.dart';
import 'package:astrologer/core/service/user_service.dart';
import 'package:astrologer/core/view_model/base_view_model.dart';
import 'package:flutter/material.dart';

class LoginViewModel extends BaseViewModel {
  UserService _userService;
  bool _obscureText = true;

  LoginViewModel({@required UserService userService})
      : this._userService = userService;

  get obscureText => _obscureText;

  Future<bool> userExists() => _userService.userExists();

  Future<LoginResponse> login(String email, String password) async {
    setBusy(true);
    var loginResponse =
        await _userService.performLogin(email, password);
    if (loginResponse.error != null) {
      setError(loginResponse.error);
    } else {
      setBusy(false);
    }
    return loginResponse;
  }

  void toggleObscureText() {
    _obscureText = !_obscureText;
    notifyListeners();
  }
}
