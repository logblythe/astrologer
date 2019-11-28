import 'package:astrologer/core/data_model/astrologer_model.dart';
import 'package:astrologer/core/data_model/message_model.dart';
import 'package:astrologer/core/service/api.dart';
import 'package:astrologer/core/service/db_provider.dart';
import 'package:rxdart/rxdart.dart';

class HomeService {
  final DbProvider _dbProvider;
  final Api _api;
  List<MessageModel> _messages;
  List<AstrologerModel> _astrologers;
  int _id;

  PublishSubject<MessageAndUpdate> _newMessage = PublishSubject();

  Stream<MessageAndUpdate> get nStream => _newMessage.stream;

  addMsgToSink(String message, update) =>
      _newMessage.sink.add(MessageAndUpdate(message, update));

  HomeService({DbProvider db, Api api})
      : _dbProvider = db,
        _api = api;

  List<MessageModel> get messages =>
      _messages == null ? _messages : List.from(_messages);

  List<AstrologerModel> get astrologers => _astrologers;

  Future<void> init({String welcomeMessage, int userId}) async {
    _messages = [];
    if (welcomeMessage != null) {
      addMessage(MessageModel(message: welcomeMessage, sent: false), userId);
    } else {
      List<MessageModel> messagesFromDb = await _dbProvider.getAllMessages();
      messagesFromDb
          .forEach((msg) => print('message status ${msg.id} ${msg.status}'));
      _messages.addAll(messagesFromDb);
    }
  }

  Future<void> addMessage(MessageModel message, int userId) async {
    print('add new message');
    message.createdAt = DateTime.now().millisecondsSinceEpoch;
    _id = await _dbProvider.addMessage(message);
    print('newly inserted id is $_id');
    _messages.add(message);
  }

  Future<void> askQuestion(MessageModel message, int userId) async {
    print('lets ask now');
    //    int prevQuesId = await _db.getUnclearedQuestionId();
    Map<String, dynamic> messageResponse = await _api.askQuestion(
      userId,
      message.message,
//      prevQuestionId: prevQuesId,
    );
    if (messageResponse == null) {
      print('message response error ');
      message.status = NOT_DELIVERED;
    } else {
      message.status = messageResponse['questionStatus'];
      message.questionId = messageResponse['engQuesId'];
      print('message response updated');
    }
    await _dbProvider.updateMessage(message, _id);
  }

  Future<void> updateQuestionStatusN(int questionId, String status) async {
    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i].questionId == questionId) {
        _messages[i].status = status;
        await _dbProvider.updateQuestionStatus(questionId, status);
      }
    }
  }

  void dispose() {
    _newMessage.close();
  }

  fetchAstrologers() async {
    if (_astrologers == null) _astrologers = await _api.fetchAstrologers();
  }
}

class MessageAndUpdate {
  String message;
  bool update;

  MessageAndUpdate(this.message, this.update);
}
