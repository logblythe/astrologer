import 'package:astrologer/core/data_model/login_response.dart';
import 'package:astrologer/core/service/home_service.dart';
import 'package:astrologer/core/service/navigation_service.dart';
import 'package:astrologer/core/service/user_service.dart';
import 'package:astrologer/core/view_model/base_view_model.dart';
import 'package:astrologer/ui/shared/route_paths.dart';
import 'package:flutter/material.dart';

class LoginViewModel extends BaseViewModel {
  UserService _userService;
  HomeService _homeService;
  NavigationService _navigationService;
  bool _obscureText = true;

  LoginViewModel({
    @required UserService userService,
    @required HomeService homeService,
    @required NavigationService navigationService,
  })  : this._userService = userService,
        this._homeService = homeService,
        this._navigationService = navigationService;

  get obscureText => _obscureText;

  Future<bool> userExists() => _userService.userExists();

  Future<LoginResponse> login(String email, String password) async {
    setBusy(true);
    var loginResponse = await _userService.performLogin(email, password);
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

  navigateToSignUp() {
    _navigationService.navigateTo(RoutePaths.signup);
  }
}
