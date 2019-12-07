import 'package:astrologer/core/service/db_provider.dart';
import 'package:astrologer/core/utils/shared_pref_helper.dart';
import 'package:astrologer/ui/shared/theme_stream.dart';
import 'package:flutter/cupertino.dart';

class SettingsService {
  DbProvider _dbProvider;
  SharedPrefHelper _sharedPrefHelper;
  bool _darkModeEnabled;

  SettingsService({
    @required DbProvider dbProvider,
    @required SharedPrefHelper sharedPrefHelper,
  }) {
    _dbProvider = dbProvider;
    _sharedPrefHelper = sharedPrefHelper;
    _init();
  }

  bool get darkModeEnabled => _darkModeEnabled;

  _init() async {
    _darkModeEnabled =
        await _sharedPrefHelper.getBool(KEY_DARK_MODE_ENABLED) ?? false;
  }

  Future<void> toggleDarkMode(bool enable) async {
    _darkModeEnabled = enable;
    _sharedPrefHelper.setBool(KEY_DARK_MODE_ENABLED, enable);
    theme.changeValue(enable);
  }

  Future<void> logout() async {
    await _dbProvider.deleteAllTables();
    _sharedPrefHelper.clear();
  }
}
