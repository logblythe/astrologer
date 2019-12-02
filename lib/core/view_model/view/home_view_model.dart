import 'package:astrologer/core/data_model/message_model.dart';
import 'package:astrologer/core/data_model/user_model.dart';
import 'package:astrologer/core/service/home_service.dart';
import 'package:astrologer/core/service/user_service.dart';
import 'package:astrologer/core/utils/shared_pref_helper.dart';
import 'package:astrologer/core/view_model/base_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

class HomeViewModel extends BaseViewModel {
  final HomeService _homeService;
  final UserService _userService;
  SharedPrefHelper _sharedPrefHelper;
  int userId;
  int _index = 0;

  int get index => _index;

  UserModel get userModel => _userService.user;

  set index(int value) {
    _index = value;
    notifyListeners();
  }

  List<IAPItem> get iaps => _homeService.iaps;

  set iaps(List<IAPItem> value) {
    _homeService.iaps = value;
  }

  HomeViewModel(
      {@required HomeService homeService,
      @required UserService userService,
      @required SharedPrefHelper sharedPrefHelper})
      : _homeService = homeService,
        _userService = userService,
        _sharedPrefHelper = sharedPrefHelper;

  Future<int> getUserId() async {
    if (userId == null) {
      userId = await _sharedPrefHelper.getInteger(KEY_USER_ID);
    }
    return userId;
  }

  getLoggedInUser() => _userService.getLoggedInUser();

  Future<void> onNotificationReceived(Map<String, dynamic> message) async {
    updateQuestionStatusN(message);
    if (message['data']['message'] != null) {
      await addMessage(message);
    }
  }

  Future<void> updateQuestionStatusN(Map<String, dynamic> message) async {
    setBusy(true);
    await _homeService.updateQuestionStatusN(
        int.parse(message['data']['questionId']), message['data']['status']);
    setBusy(false);
  }

  Future<void> addMessage(Map<String, dynamic> message) async {
    print('add message homeviewmodel');
    setBusy(true);
    userId = await getUserId();
    await _homeService.addMessage(
        MessageModel(
          sent: false,
          status: message['data']['status'],
          message: message['data']['message'],
          questionId: int.parse(message['data']['questionId']),
        ),
        userId);
    setBusy(false);
  }
}
