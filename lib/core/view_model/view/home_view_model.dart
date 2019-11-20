import 'package:astrologer/core/data_model/message_model.dart';
import 'package:astrologer/core/service/home_service.dart';
import 'package:astrologer/core/utils/shared_pref_helper.dart';
import 'package:astrologer/core/view_model/base_view_model.dart';
import 'package:flutter/material.dart';

class HomeViewModel extends BaseViewModel {
  final HomeService _homeService;
  SharedPrefHelper _sharedPrefHelper;
  int userId;

  HomeViewModel(
      {@required HomeService homeService,
      @required SharedPrefHelper sharedPrefHelper})
      : _homeService = homeService,
        _sharedPrefHelper = sharedPrefHelper;

  Future<int> getUserId() async {
    if (userId == null) {
      userId = await _sharedPrefHelper.getInteger(KEY_USER_ID);
    }
    return userId;
  }

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
