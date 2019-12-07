import 'package:astrologer/core/service/home_service.dart';
import 'package:astrologer/core/service/settings_service.dart';
import 'package:astrologer/core/view_model/base_view_model.dart';
import 'package:flutter/cupertino.dart';

class SettingsViewModel extends BaseViewModel {
  SettingsService _settingsService;
  HomeService _homeService;

  bool get darkModeEnabled => _settingsService.darkModeEnabled;

  SettingsViewModel({
    @required SettingsService settingsService,
    @required HomeService homeService,
  }) {
    this._settingsService = settingsService;
    this._homeService = homeService;
  }

  toggleDarkMode(bool enable) async =>
      await _settingsService.toggleDarkMode(enable);

  Future logout() async {
    await _settingsService.logout();
    _homeService.dispose();
  }
}
