const String UNCLEAR = "unclear";
const String CLEAR = "clear";
const String UNASSIGNED = "unassigned";

class MessageModel {
  int id;
  String message;
  bool sent;
  String status;
  int questionId;
  String error;

  MessageModel(
      {this.id,
      this.message,
      this.sent,
      this.status,
      this.questionId,
      this.error});

  MessageModel.fromJson(Map<String, dynamic> json)
      : message = json['message'],
        sent = json['sent'],
        status = json["questionStatus"] ?? "",
        questionId = json["engQuesId"],
        error = json["error"];

  MessageModel.fromNotification(Map<String, dynamic> json)
      : message = json['message'],
        sent = false,
        status = json["questionStatus"] ?? "",
        questionId = json["engQuesId"];

  Map<String, dynamic> toMapForDb() => {
        "message": message,
        "sent": sent ? 1 : 0,
        "status": status,
        "questionId": questionId,
      };

  MessageModel.fromDb(Map<String, dynamic> json)
      : id = json['id'],
        message = json['message'],
        status = json['status'],
        sent = json['sent'] == 1,
        questionId = json["questionId"];

  @override
  String toString() {
    return toMapForDb().toString();
  }

  MessageModel.withError(String error) : error = error;
}
