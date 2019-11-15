import 'package:astrologer/core/data_model/login_response.dart';
import 'package:astrologer/core/data_model/message_model.dart';
import 'package:astrologer/core/service/home_service.dart';
import 'package:astrologer/core/service/user_service.dart';
import 'package:astrologer/core/utils/shared_pref_helper.dart';
import 'package:astrologer/core/view_model/base_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:square_in_app_payments/in_app_payments.dart';
import 'package:square_in_app_payments/models.dart';
import 'package:square_in_app_payments/google_pay_constants.dart'
    as google_pay_constants;
import 'dart:io' show Platform;

class DashboardViewModel extends BaseViewModel {
  HomeService _homeService;
  UserService _userService;
  SharedPrefHelper _sharedPrefHelper;
  int userId;
  MessageModel _message;
  bool _googlePayEnabled = false;

  LoginResponse get loginResponse => _userService.loginResponse;

  List<MessageModel> get messages => _homeService.messages?.reversed?.toList();

  bool get googlePayEnabled => _googlePayEnabled;

  DashboardViewModel(
      {@required HomeService homeService,
      @required UserService userService,
      @required SharedPrefHelper sharedPrefHelper})
      : this._homeService = homeService,
        this._userService = userService,
        this._sharedPrefHelper = sharedPrefHelper;

  init() async {
    setBusy(true);
    userId = await _sharedPrefHelper.getInteger(KEY_USER_ID);
    await _homeService.init(
        welcomeMessage: loginResponse?.welcomeMessage, userId: userId);
    await _initGooglePayment();
    setBusy(false);
  }

  Future<void> addMessage(MessageModel message) async {
    setBusy(true);
    await _homeService.addMessage(message, userId);
    await onStartGooglePay(message);
    setBusy(false);
  }

  Future<void> _initGooglePayment() async {
    var canUseGooglePay = false;
    if (Platform.isAndroid) {
      await InAppPayments.initializeGooglePay(
          'VPH4T2AH120W5', google_pay_constants.environmentTest);
      canUseGooglePay = await InAppPayments.canUseGooglePay;
    }
    _googlePayEnabled = canUseGooglePay;
  }

  Future<Null> onStartGooglePay(MessageModel message) async {
    _message = message;
    try {
      InAppPayments.requestGooglePayNonce(
          priceStatus: 1,
          price: '1.00',
          currencyCode: 'USD',
          onGooglePayNonceRequestSuccess: onGooglePayNonceRequestSuccess,
          onGooglePayNonceRequestFailure: onGooglePayNonceRequestFailure,
          onGooglePayCanceled: onGooglePayCancel);
    } on InAppPaymentsException catch (ex) {
      print('failure onStartGooglePay exception $ex');
    }
    return;
  }

  /**
   * Callback when successfully get the card nonce details for processig
   * google pay sheet has been closed when this callback is invoked
   */
  void onGooglePayNonceRequestSuccess(CardDetails result) async {
    try {
      // take payment with the card nonce details
      // you can take a charge
      // await chargeCard(result);
      print('google pay onGooglePayNonceRequestSuccess');
      await _homeService.askQuestion(_message, userId);
      notifyListeners();
    } on Exception catch (ex) {
      // handle card nonce processing failure
      print('google pay onGooglePayNonceRequestSuccess exception $ex');
      await _homeService.askQuestion(_message, userId);
      notifyListeners();
    }
  }

  /**
   * Callback when google pay is canceled
   * google pay sheet has been closed when this callback is invoked
   */
  void onGooglePayCancel() async {
    print("google pay cancel");
    await _homeService.askQuestion(_message, userId);
    notifyListeners();
  }

  /**
   * Callback when failed to get the card nonce
   * google pay sheet has been closed when this callback is invoked
   */
  void onGooglePayNonceRequestFailure(ErrorInfo errorInfo) async {
    // handle google pay failure
    print('google pay onGooglePayNonceRequestFailure $errorInfo');
    await _homeService.askQuestion(_message, userId);
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _homeService.dispose();
  }
}
