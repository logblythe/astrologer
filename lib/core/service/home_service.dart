import 'package:astrologer/core/constants/what_to_ask.dart';
import 'package:astrologer/core/data_model/astrologer_model.dart';
import 'package:astrologer/core/data_model/idea_model.dart';
import 'package:astrologer/core/data_model/message_model.dart';
import 'package:astrologer/core/service/api.dart';
import 'package:astrologer/core/service/db_provider.dart';
import 'package:astrologer/core/utils/local_notification_helper.dart';
import 'package:astrologer/core/utils/shared_pref_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:rxdart/rxdart.dart';

class HomeService {
  final DbProvider _dbProvider;
  final Api _api;
  final SharedPrefHelper _sharedPrefHelper;
  final LocalNotificationHelper _localNotificationHelper;

  List<MessageModel> _messageList;

  List<AstrologerModel> _astrologers;
  int _id, _userId, _freeCount;
  List<IAPItem> _iaps;
  FlutterInappPurchase _iap;
  List<IdeaModel> _ideas;

  PublishSubject<MessageAndUpdate> _newMessage = PublishSubject();
  PublishSubject<int> _freeCountStream = PublishSubject();

  Stream<MessageAndUpdate> get nStream => _newMessage.stream;

  FlutterInappPurchase get iap => _iap;

  List<IAPItem> get iaps => _iaps;

  get ideas => _ideas;

  Stream<int> get freeCountStream => _freeCountStream.stream;

  set iaps(List<IAPItem> value) {
    _iaps = value;
  }

  addMsgToSink(String message, update) {
    _newMessage.sink.add(MessageAndUpdate(message, update));
  }

  addFreeCountToSink(int freeCount) {
    _freeCountStream.sink.add(freeCount);
  }

  HomeService({
    @required DbProvider db,
    @required Api api,
    @required SharedPrefHelper sharedPrefHelper,
    @required LocalNotificationHelper localNotificationHelper,
  })  : _dbProvider = db,
        _api = api,
        _sharedPrefHelper = sharedPrefHelper,
        _localNotificationHelper = localNotificationHelper {
    {
      _localNotificationHelper.onSelectionNotification = (payload) {
        print('hello world');
      };
      _localNotificationHelper.onReceiveLocalNotification =
          (id, title, body, payload) {
        print("hello world 2");
      };
    }
  }

  List<MessageModel> get messages => _messageList;

  List<AstrologerModel> get astrologers => _astrologers;

  Future<void> fetchIdeas() async {
    if (_ideas == null) {
      _ideas = [];
      _ideas.addAll(ideaModelList);
    }
  }

  Future<void> init({String welcomeMessage}) async {
    _messageList = [];
    _iap = FlutterInappPurchase.instance;
    _userId = await _sharedPrefHelper.getInteger(KEY_USER_ID);
    if (welcomeMessage != null) {
      addMessage(MessageModel(message: welcomeMessage, sent: false));
    } else {
      List<MessageModel> messagesFromDb = await _dbProvider.getAllMessages();
      messagesFromDb.forEach((msg) =>
          print('message status ${msg.id} ${msg.status} ${msg.questionId}'));
      _messageList.addAll(messagesFromDb);
    }
  }

  Future getFreeQuesCount() async {
    _freeCount = await _sharedPrefHelper.getInteger(KEY_FREE_QUES_COUNT) ?? 0;
    addFreeCountToSink(_freeCount);
  }

  Future<int> addMessage(MessageModel message) async {
    message.createdAt = DateTime.now().millisecondsSinceEpoch;
    _id = await _dbProvider.addMessage(message);
    message.id = _id;
    _messageList.add(message);
    return _id;
  }

  Future<Null> askQuestion(MessageModel message, bool shouldCharge) async {
    //    int prevQuesId = await _db.getUnclearedQuestionId();
    print('free count $_freeCount');
    /*if (_freeCount==0 && shouldCharge) await _purchase();
    print('After purchase');*/
    Map<String, dynamic> messageResponse = await _api.askQuestion(
      _userId,
      message.message,
//      prevQuestionId: prevQuesId,
    );
    if (messageResponse == null) {
      print('message response error ');
      message.status = NOT_DELIVERED;
    } else {
      message.status = messageResponse['questionStatus'] ?? DELIVERED;
      message.questionId = messageResponse['engQuesId'];
      if (_freeCount > 0) {
        _freeCount = --_freeCount;
        await _sharedPrefHelper.setInt(KEY_FREE_QUES_COUNT, _freeCount);
        addFreeCountToSink(_freeCount);
      }
      print('message response updated');
    }
    await _dbProvider.updateMessage(message, _id);
    return;
  }

  Future<void> updateQuestionStatusN(int questionId, String status) async {
    for (int i = 0; i < _messageList.length; i++) {
      if (_messageList[i].questionId == questionId) {
        _messageList[i].status = status;
        await _dbProvider.updateQuestionStatus(questionId, status);
      }
    }
  }

  Future<void> updateQuestionStatusById(int id, String status) async {
    print('Status $status $id');
    for (int i = 0; i < _messageList.length; i++) {
      print('at $i ${_messageList[i].toMapForDb()}');
      if (_messageList[i].id == id) {
        print('inside $i ${_messageList[i].toMapForDb()}');
        _messageList[i].status = status;
        await _dbProvider.updateQuestionStatusById(id, status);
      }
    }
  }

  void dispose() {
    _messageList.clear();
  }

  fetchAstrologers() async {
    if (_astrologers == null) _astrologers = await _api.fetchAstrologers();
  }

  Future<Null> _purchase() async {
    PurchasedItem _purchasedItem;
    print('the product id is ${_iaps[0].productId}');
    try {
      _purchasedItem = await _iap.requestPurchase(_iaps[0].productId);
      _iap.consumePurchaseAndroid(_purchasedItem.purchaseToken);
    } catch (e) {
      PlatformException p = e as PlatformException;
      print("exception ${p.code}");
      print("exception ${p.message}");
      print("exception ${p.details}");
    }
    print('Purchase success ${_purchasedItem.productId}');
    return;
  }

  Future<Map<String, dynamic>> fetchQuestionPrice() async {
    return await _api.fetchQuestionPrice();
  }

  showLocalNotification(String title, String body) async {
    await _localNotificationHelper.showNotification(title: title, body: body);
  }
}

class MessageAndUpdate {
  String message;
  bool update;

  MessageAndUpdate(this.message, this.update);
}
