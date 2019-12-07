import 'package:astrologer/core/data_model/message_model.dart';
import 'package:astrologer/core/data_model/user_model.dart';
import 'package:astrologer/core/service/home_service.dart';
import 'package:astrologer/core/service/user_service.dart';
import 'package:astrologer/core/view_model/base_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

class HomeViewModel extends BaseViewModel {
  final HomeService _homeService;
  final UserService _userService;
  int _index = 0;
  double priceAfterDiscount;
  double questionPrice;
  double discountInPercentage;

  HomeViewModel(
      {@required HomeService homeService, @required UserService userService})
      : _homeService = homeService,
        _userService = userService;

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

  getLoggedInUser() => _userService.getLoggedInUser();

  Future<void> onNotificationReceived(Map<String, dynamic> message) async {
    updateQuestionStatusN(message);
    if (message['data']['message'] != null) {
      await addMessage(message);
    }
  }

  Future getFreeQuesCount() async => await _homeService.getFreeQuesCount();

  Future<void> updateQuestionStatusN(Map<String, dynamic> message) async {
    setBusy(true);
    await _homeService.updateQuestionStatusN(
        int.parse(message['data']['questionId']), message['data']['status']);
    setBusy(false);
  }

  Future<void> addMessage(Map<String, dynamic> message) async {
    print('add message homeviewmodel');
    setBusy(true);
    var id = await _homeService.addMessage(MessageModel(
      sent: false,
      status: message['data']['status'],
      message: message['data']['message'],
      questionId: int.parse(message['data']['questionId']),
    ));
    print('newly added id is $id');
    setBusy(false);
  }

  fetchQuestionPrice() async {
    setBusy(true);
    var result = await _homeService.fetchQuestionPrice();
    if (result != null) {
      questionPrice = result['questionPrice'] ?? 0;
      discountInPercentage = result['discountInPercentage'] ?? 0;
      priceAfterDiscount = (100 - discountInPercentage) / 100 * questionPrice;
    }
    setBusy(false);
  }

  showLocalNotification(String title, String body) async =>
      await _homeService.showLocalNotification(title, body);
}
