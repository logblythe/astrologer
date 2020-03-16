import 'package:astrologer/core/data_model/message_model.dart';
import 'package:astrologer/core/data_model/notification_model.dart';
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
  bool _internetConnection = true;

  bool get internetConnection => _internetConnection;

  set internetConnection(bool value) {
    _internetConnection = value;
    notifyListeners();
  }

  double get priceAfterDiscount => _homeService.priceAfterDiscount;

  double get questionPrice => _homeService.questionPrice;

  double get discountInPercentage => _homeService.discountInPercentage;

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

  Future<void> onNotificationReceived(NotificationModel answer) async {
    await updateQuestionStatusN(answer);
    if (answer.data.message != null) {
      await addMessage(answer);
    }
  }

  Future getFreeQuesCount() async => await _homeService.getFreeQuesCount();

  Future<void> updateQuestionStatusN(NotificationModel message) async {
    setBusy(true);
    await _homeService.updateQuestionStatusN(
        int.parse(message.data.engQuestionId), message.data.status);
    setBusy(false);
  }

  Future<void> addMessage(NotificationModel message) async {
    setBusy(true);
    await _homeService.addMessage(MessageModel(
        sent: false,
        status: message.data.status,
        message: message.data.message,
        questionId: int.parse(message.data.engQuestionId),
        astrologer: message.data.repliedBy));
    setBusy(false);
  }

  fetchQuestionPrice() async {
    setBusy(true);
    await _homeService.fetchQuestionPrice();
    setBusy(false);
  }

  showLocalNotification(String title, String body) async =>
      await _homeService.showLocalNotification(title, body);
}
