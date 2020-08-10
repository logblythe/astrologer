import 'package:astrologer/core/constants/end_points.dart';
import 'package:astrologer/core/constants/what_to_ask.dart';
import 'package:astrologer/core/data_model/astrologer_model.dart';
import 'package:astrologer/core/data_model/idea_model.dart';
import 'package:astrologer/core/data_model/message_model.dart';
import 'package:astrologer/core/service/api.dart';
import 'package:astrologer/core/service/db_provider.dart';
import 'package:astrologer/core/utils/local_notification_helper.dart';
import 'package:astrologer/core/utils/shared_pref_helper.dart';
import 'package:astrologer/core/utils/purchase_helper.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class HomeService {
  final DbProvider _dbProvider;
  final Api _api;
  final SharedPrefHelper _sharedPrefHelper;
  final LocalNotificationHelper _localNotificationHelper;
  final PurchaseHelper _purchaseHelper;

  List<MessageModel> _messageList = [];
  List<AstrologerModel> _astrologers;
  int _id, _userId, _freeCount;
  List<IdeaModel> _ideas;

  double _priceAfterDiscount;
  double _questionPrice;
  double _discountInPercentage;

  PublishSubject<MessageAndUpdate> _newMessage = PublishSubject();
  PublishSubject<int> _freeCountStream = PublishSubject();

  Stream<MessageAndUpdate> get nStream => _newMessage.stream;

  get ideas => _ideas;

  Stream<int> get freeCountStream => _freeCountStream.stream;

  double get priceAfterDiscount => _priceAfterDiscount;

  double get questionPrice => _questionPrice;

  double get discountInPercentage => _discountInPercentage;

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
    @required PurchaseHelper purchaseHelper,
  })  : _dbProvider = db,
        _api = api,
        _sharedPrefHelper = sharedPrefHelper,
        _localNotificationHelper = localNotificationHelper,
        _purchaseHelper = purchaseHelper {
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

//  List<MessageModel> get messages => [MessageModel(sent: false,message: "This is the received message",createdAt: DateTime.now().millisecondsSinceEpoch),MessageModel(sent: true,message: "this is the sent message",createdAt: DateTime.now().millisecondsSinceEpoch)];

  List<AstrologerModel> get astrologers => _astrologers;

  Future<void> fetchIdeas() async {
    if (_ideas == null) {
      _ideas = [];
      _ideas.addAll(ideaModelList);
    }
  }

  Future getFreeQuesCount() async {
    _freeCount = await _sharedPrefHelper.getInteger(KEY_FREE_QUES_COUNT) ?? 0;
    addFreeCountToSink(_freeCount);
  }

  Future<void> init({List<String> welcomeMessage}) async {
    _userId = await _sharedPrefHelper.getInteger(KEY_USER_ID);
    if (welcomeMessage != null) {
      welcomeMessage.forEach((element) {
        addMessage(MessageModel(message: element, sent: false));
      });
    } else {
      List<MessageModel> messagesFromDb = await _dbProvider.getAllMessages();
      messagesFromDb.forEach((msg) =>
          print('message status ${msg.id} ${msg.status} ${msg.questionId}'));
      _messageList.addAll(messagesFromDb);
    }
  }

  Future<int> addMessage(MessageModel message) async {
    message.createdAt = DateTime.now().millisecondsSinceEpoch;
    _id = await _dbProvider.addMessage(message);
    message.id = _id;
    _messageList.add(message);
    return _id;
  }

  Future askQuestion(
      MessageModel message, bool shouldCharge, double questionPrice) async {
    //    int prevQuesId = await _db.getUnclearedQuestionId();
    print('free count $_freeCount');
//    if (_freeCount == 0 && shouldCharge) await _purchase();
    _purchase();
    print('After purchase');
    Map<String, dynamic> messageResponse = await _api.askQuestion(
      _userId,
      message.message,
      questionPrice,
//      prevQuestionId: prevQuesId,
    );
    if (messageResponse == null) {
      print('message response error ');
      message.status = NOT_DELIVERED;
    } else {
      message.status = messageResponse['questionStatus'] ?? DELIVERED;
      message.questionId = messageResponse['engQuesId'];
      if (_freeCount > 0) {
        int freeCount = _freeCount - 1;
        await _sharedPrefHelper.setInt(KEY_FREE_QUES_COUNT, freeCount);
        addFreeCountToSink(freeCount);
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
        if (status == QuestionStatus.UNCLEAR) {
          int freeCount =
              await _sharedPrefHelper.getInteger(KEY_FREE_QUES_COUNT) + 1;
          _sharedPrefHelper.setInt(KEY_FREE_QUES_COUNT, freeCount);
          addFreeCountToSink(freeCount);
        }
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
    _newMessage.close();
    _freeCountStream.close();
  }

  fetchAstrologers() async {
    if (_astrologers == null) _astrologers = await _api.fetchAstrologers();
  }

  Future<Null> _purchase() async {
    _purchaseHelper.purchase();
    return;
  }

  fetchQuestionPrice() async {
    var result = await _api.fetchQuestionPrice();
    if (result != null) {
      _questionPrice = result['questionPrice'] ?? 0;
      _discountInPercentage = result['discountInPercentage'] ?? 0;
      _priceAfterDiscount =
          (100 - _discountInPercentage) / 100 * _questionPrice;
    }
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
