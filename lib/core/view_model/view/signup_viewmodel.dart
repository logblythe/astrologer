import 'package:astrologer/core/data_model/user_model.dart';
import 'package:astrologer/core/service/navigation_service.dart';
import 'package:astrologer/core/service/user_service.dart';
import 'package:astrologer/core/view_model/base_view_model.dart';
import 'package:flutter/material.dart';

class SignUpViewModel extends BaseViewModel {
  NavigationService _navigationService;
  UserService _userService;
  bool _obscureText = true;

  SignUpViewModel(
      {@required UserService userService,
      @required NavigationService navigationService})
      : this._userService = userService,
        this._navigationService = navigationService;

  get obscureText => _obscureText;

  toggleObscureText() {
    _obscureText = !_obscureText;
    notifyListeners();
  }

  Future<UserModel> register({UserModel user, String fcmToken}) async {
    setBusy(true);
    var userModel = await _userService.register(
      user: user,
      fcmToken: fcmToken,
    );
    if (userModel.errorMessage != null) {
      setError(userModel.errorMessage);
    }
    setBusy(false);
    return userModel;
  }
}
