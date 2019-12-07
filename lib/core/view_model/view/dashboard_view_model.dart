import 'package:astrologer/core/data_model/login_response.dart';
import 'package:astrologer/core/data_model/message_model.dart';
import 'package:astrologer/core/service/home_service.dart';
import 'package:astrologer/core/service/settings_service.dart';
import 'package:astrologer/core/service/user_service.dart';
import 'package:astrologer/core/view_model/base_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

class DashboardViewModel extends BaseViewModel {
  HomeService _homeService;
  UserService _userService;
  SettingsService _settingsService;

  int _messageId;
  MessageModel _message;
  String _messageBox;
  bool _showSendBtn = false;

  DashboardViewModel({
    @required HomeService homeService,
    @required UserService userService,
    @required SettingsService settingsService,
  })  : this._homeService = homeService,
        this._userService = userService,
        this._settingsService = settingsService;

  bool get showSendBtn => _showSendBtn;

  bool get darkModeEnabled => _settingsService.darkModeEnabled;

  set showSendBtn(bool value) {
    _showSendBtn = value;
    notifyListeners();
  }

  String get messageBox => _messageBox;

  Stream<MessageAndUpdate> get nMsgStream => _homeService.nStream;

  void addMsgToSink(message, update) =>
      _homeService.addMsgToSink(message, update);

  LoginResponse get loginResponse => _userService.loginResponse;

  List<MessageModel> get messages => _homeService.messages?.reversed?.toList();

  init() async {
    setBusy(true);
    await _homeService.init(welcomeMessage: loginResponse?.welcomeMessage);
    setupListeners();
    setBusy(false);
  }

  void setupListeners() {
    nMsgStream.listen((MessageAndUpdate data) {
      _messageBox = data.message;
      if (data.update) notifyListeners();
    });
    FlutterInappPurchase.purchaseError.listen((PurchaseResult event) async {
      print("purchase error ${event.message}");
      await updateQuestionStatusById(NOT_DELIVERED);
    });
    FlutterInappPurchase.purchaseUpdated.listen((PurchasedItem item) async {
      var result =
          await _homeService.iap.consumePurchaseAndroid(item.purchaseToken);
      print('purchase listener $result');
      await askQuestion(_message, shouldCharge: false);
    });
  }

  Future<void> addMessage(MessageModel message) async {
    setBusy(true);
    _homeService.addMsgToSink("", true);
    _messageId = await _homeService.addMessage(message);
    setBusy(false);
  }

  Future<void> askQuestion(MessageModel message,
      {bool shouldCharge = true}) async {
    setBusy(true);
    _message = message;
    await _homeService.askQuestion(_message, shouldCharge);
    setBusy(false);
  }

  updateQuestionStatusById(String status) async {
    setBusy(true);
    await _homeService.updateQuestionStatusById(_messageId, status);
    setBusy(false);
  }
}
