import 'package:astrologer/core/constants/what_to_ask.dart';
import 'package:astrologer/core/data_model/astrologer_model.dart';
import 'package:astrologer/core/data_model/idea_model.dart';
import 'package:astrologer/core/data_model/message_model.dart';
import 'package:astrologer/core/service/api.dart';
import 'package:astrologer/core/service/db_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:rxdart/rxdart.dart';

class HomeService {
  final DbProvider _dbProvider;
  final Api _api;
  List<MessageModel> _messages;
  List<AstrologerModel> _astrologers;
  int _id;
  List<IAPItem> _iaps;
  FlutterInappPurchase _iap;
  List<IdeaModel> _ideas;

  PublishSubject<MessageAndUpdate> _newMessage = PublishSubject();

  Stream<MessageAndUpdate> get nStream => _newMessage.stream;

  FlutterInappPurchase get iap => _iap;

  List<IAPItem> get iaps => _iaps;

  get ideas => _ideas;

  set iaps(List<IAPItem> value) {
    _iaps = value;
  }

  addMsgToSink(String message, update) =>
      _newMessage.sink.add(MessageAndUpdate(message, update));

  HomeService({DbProvider db, Api api})
      : _dbProvider = db,
        _api = api;

  List<MessageModel> get messages => _messages;

  List<AstrologerModel> get astrologers => _astrologers;

  Future<void> fetchIdeas() async {
    if (_ideas == null) {
      _ideas = [];
      _ideas.addAll(ideaModelList);
    }
  }

  Future<void> init({String welcomeMessage, int userId}) async {
    _messages = [];
    _iap = FlutterInappPurchase.instance;
    if (welcomeMessage != null) {
      addMessage(MessageModel(message: welcomeMessage, sent: false), userId);
    } else {
      List<MessageModel> messagesFromDb = await _dbProvider.getAllMessages();
      messagesFromDb
          .forEach((msg) => print('message status ${msg.id} ${msg.status}'));
      _messages.addAll(messagesFromDb);
    }
  }

  Future<int> addMessage(MessageModel message, int userId) async {
    message.createdAt = DateTime.now().millisecondsSinceEpoch;
    _id = await _dbProvider.addMessage(message);
    message.id = _id;
    _messages.add(message);
    return _id;
  }

  Future<Null> askQuestion(
      MessageModel message, int userId, bool isFree, bool shouldCharge) async {
    //    int prevQuesId = await _db.getUnclearedQuestionId();
    if (!isFree && shouldCharge) await _purchase();
    print('After purchase');
    Map<String, dynamic> messageResponse = await _api.askQuestion(
      userId,
      message.message,
//      prevQuestionId: prevQuesId,
    );
    if (messageResponse == null) {
      print('message response error ');
      message.status = NOT_DELIVERED;
    } else {
      message.status = messageResponse['questionStatus'] ?? DELIVERED;
      message.questionId = messageResponse['engQuesId'];
      print('message response updated');
    }
    await _dbProvider.updateMessage(message, _id);
    return;
  }

  Future<void> updateQuestionStatusN(int questionId, String status) async {
    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i].questionId == questionId) {
        _messages[i].status = status;
        await _dbProvider.updateQuestionStatus(questionId, status);
      }
    }
  }

  Future<void> updateQuestionStatusById(int id, String status) async {
    print('Status $status $id');
    for (int i = 0; i < _messages.length; i++) {
      print('at $i ${_messages[i].toMapForDb()}');
      if (_messages[i].id == id) {
        print('inside $i ${_messages[i].toMapForDb()}');
        _messages[i].status = status;
        await _dbProvider.updateQuestionStatusById(id, status);
      }
    }
  }

  void dispose() {}

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
}

class MessageAndUpdate {
  String message;
  bool update;

  MessageAndUpdate(this.message, this.update);
}
