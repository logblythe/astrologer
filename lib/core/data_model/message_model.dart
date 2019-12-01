const String UNCLEAR = "unclear";
const String CLEAR = "clear";
const String UNASSIGNED = "unassigned";
const String NOT_DELIVERED = "Not delivered";
const String DELIVERED = "Delivered";

const String ID = "id";
const String MESSAGE = "message";
const String STATUS = "status";
const String SENT = "sent";
const String QUESTION_ID = "questionId";
const String CREATED_AT = "createdAt";
const String DELETED_AT = "deletedAt";
const String UPDATED_AT = "updatedAt";
const String ASTROLOGER_ID = "astrologerId";

class MessageModel {
  int id;
  String message;
  bool sent;
  String status;
  int questionId;
  String error;
  int createdAt;
  int updatedAt;
  int astrologerId;

  MessageModel(
      {this.id,
      this.message,
      this.sent,
      this.status,
      this.questionId,
      this.error,
      this.createdAt,
      this.updatedAt,
      this.astrologerId});

  MessageModel.fromJson(Map<String, dynamic> json)
      : message = json[MESSAGE],
        sent = json[SENT],
        status = json[STATUS] ?? "",
        questionId = json[QUESTION_ID],
        error = json["error"],
        astrologerId = json[ASTROLOGER_ID];

  MessageModel.fromNotification(Map<String, dynamic> json)
      : message = json[MESSAGE],
        sent = false,
        status = json[STATUS] ?? "",
        questionId = json[QUESTION_ID],
        astrologerId = json[ASTROLOGER_ID];

  Map<String, dynamic> toMapForDb() => {
        MESSAGE: message,
        SENT: sent ? 1 : 0,
        STATUS: status,
        QUESTION_ID: questionId,
        CREATED_AT: createdAt,
        ASTROLOGER_ID: astrologerId,
        ID: id,
      };

  MessageModel.fromDb(Map<String, dynamic> json)
      : id = json[ID],
        message = json[MESSAGE],
        status = json[STATUS],
        sent = json[SENT] == 1,
        questionId = json[QUESTION_ID],
        astrologerId = json[ASTROLOGER_ID],
        createdAt = json[CREATED_AT];

  @override
  String toString() {
    return toMapForDb().toString();
  }

  MessageModel.withError(String error) : error = error;
}
