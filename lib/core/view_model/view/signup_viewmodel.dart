import 'package:astrologer/core/data_model/user_model.dart';
import 'package:astrologer/core/enum/gender.dart';
import 'package:astrologer/core/service/navigation_service.dart';
import 'package:astrologer/core/service/user_service.dart';
import 'package:astrologer/core/view_model/base_view_model.dart';
import 'package:astrologer/ui/shared/route_paths.dart';
import 'package:flutter/material.dart';

class SignUpViewModel extends BaseViewModel {
  UserService _userService;
  bool _obscureText = true;

  SignUpViewModel({@required UserService userService})
      : this._userService = userService;

  get obscureText => _obscureText;

  toggleObscureText() {
    _obscureText = !_obscureText;
    notifyListeners();
  }

  Future<UserModel> register(
      String name, String lname, String email, String password,
      {Gender gender,
      String dob,
      String time,
      bool timeAccurate,
      String country,
      String location,
      String phone,
      String state,
      String fcmToken}) async {
    setBusy(true);
    var userModel = await _userService.register(
        gender,
        name,
        lname,
        dob,
        time,
        timeAccurate,
        country,
        location,
        email,
        password,
        phone,
        state,
        fcmToken);
    if (userModel.errorMessage != null) {
      setError(userModel.errorMessage);
    } else {
      var loginResponse = await _userService.performLogin(email, password);
      if (loginResponse.error != null) {
        setError(loginResponse.error);
      } else {
        navigatorKey.currentState.pushReplacementNamed(RoutePaths.home);
      }
    }
    setBusy(false);
    return userModel;
  }
}
