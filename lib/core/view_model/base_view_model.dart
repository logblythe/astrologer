import 'package:astrologer/core/enum/app_state.dart';
import 'package:flutter/material.dart';

class BaseViewModel extends ChangeNotifier {
  bool _isDisposed = false;
  AppState _appState = AppState.IDLE;

  bool get busy => _appState == AppState.BUSY;

  bool get hasError => _appState == AppState.ERROR;

  String _errorMsg;

  String get errorMessage => _errorMsg;

  void setBusy(bool value) {
    _appState = value ? AppState.BUSY : AppState.IDLE;
    if (!_isDisposed) notifyListeners();
  }

  void setError(String errorMsg) {
    _errorMsg = errorMsg;
    _appState = AppState.ERROR;
    print(errorMsg);
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
