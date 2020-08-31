import 'package:astrologer/core/service/home_service.dart';
import 'package:astrologer/core/service/settings_service.dart';
import 'package:astrologer/core/service/user_service.dart';
import 'package:astrologer/core/view_model/base_view_model.dart';
import 'package:flutter/cupertino.dart';

class SettingsViewModel extends BaseViewModel {
  UserService _userService;
  SettingsService _settingsService;
  HomeService _homeService;

  bool get darkModeEnabled => _settingsService.darkModeEnabled;

  SettingsViewModel({
    @required UserService userService,
    @required SettingsService settingsService,
    @required HomeService homeService,
  }) {
    this._userService = userService;
    this._settingsService = settingsService;
    this._homeService = homeService;
  }

  toggleDarkMode(bool enable) async =>
      await _settingsService.toggleDarkMode(enable);

  changePassword(String oldPassword, String newPassword) async {
    setBusy(true);
    var result;
    try {
      result = await await _userService.changePassword(
          {"oldPassword": oldPassword, "newPassword": newPassword});
      if (result.status != "Ok") {
        setError(result.message);
      }
      return result;
    } catch (e) {
      setError(e.toString());
    }
  }

  Future logout() async {
    await _settingsService.logout();
    _homeService.dispose();
  }
}
