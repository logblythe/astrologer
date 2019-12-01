import 'package:astrologer/core/data_model/message_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageItem extends StatelessWidget {
  const MessageItem(
      {Key key,
      @required this.animation,
      this.onTap,
      @required this.item,
      this.selected: false,
      @required this.message})
      : assert(animation != null),
        assert(item != null && item >= 0),
        assert(selected != null),
        super(key: key);

  final Animation<double> animation;
  final VoidCallback onTap;
  final int item;
  final bool selected;
  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.display1;
    if (selected)
      textStyle = textStyle.copyWith(color: Colors.lightGreenAccent[400]);
    return Padding(
      padding: EdgeInsets.only(top: message.sent ? 0 : 32),
      child: Stack(
        overflow: Overflow.visible,
        fit: StackFit.loose,
        alignment: message.sent ? Alignment.centerRight : Alignment.centerLeft,
        children: [
          message.sent
              ? SizedBox.shrink()
              : Positioned(
                  bottom: 60,
                  child: CircleAvatar(
                    child: Text('A'),
                  ),
                ),
          Container(
            margin: message.sent
                ? EdgeInsets.only(left: 24)
                : EdgeInsets.only(left: 24, right: 24),
            child: Column(
              children: <Widget>[
//                _buildQuestionId(),
                _buildMessageColumn(context),
                _buildStatus()
              ],
              crossAxisAlignment: message.sent
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
            ),
          ),
        ],
      ),
    );
  }

  FadeTransition _buildMessageColumn(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.only(
          bottom: 2,
          top: 8,
          left: message.sent ? 32 : 0,
          right: message.sent ? 0 : 24,
        ),
        decoration: BoxDecoration(
          /* border: Border.all(
                      color: message.sent
                          ? Theme.of(context).primaryColor
                          : Colors.grey),*/
          color: message.sent ? Theme.of(context).primaryColor : Colors.grey,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(message.sent ? 24 : 0),
              topRight: Radius.circular(message.sent ? 0 : 24),
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
                DateFormat("MMM d, yyyy hh:mm a").format(
                    DateTime.fromMillisecondsSinceEpoch(message.createdAt)),
                style: TextStyle(color: Colors.white, fontSize: 10)),
            SizedBox(height: 8),
            Text(message.message, style: TextStyle(color: Colors.white))
          ],
        ),
      ),
    );
  }

  FadeTransition _buildQuestionId() {
    return FadeTransition(
        opacity: animation,
        child: (message.sent)
            ? Text(message.questionId?.toString() ?? 'No question id',
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold))
            : SizedBox.shrink());
  }

  FadeTransition _buildStatus() {
    return FadeTransition(
        opacity: animation,
        child: (message.sent)
            ? message.status == null
                ? SizedBox(
                    height: 8,
                    width: 8,
                    child: CircularProgressIndicator(strokeWidth: 1.0),
                  )
                : _getStatusWidget()
            : SizedBox.shrink());
  }

  Wrap _getStatusWidget() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      direction: Axis.vertical,
      children: <Widget>[
        _getStatusIcon(),
        Text(message.status,
            style: TextStyle(
                color: message.status == NOT_DELIVERED
                    ? Colors.red
                    : Colors.black87,
                fontSize: 8,
                fontWeight: FontWeight.bold))
      ],
    );
  }

  Widget _getStatusIcon() {
    switch (message.status) {
      case NOT_DELIVERED:
        return Icon(Icons.warning, color: Colors.redAccent);
      case DELIVERED:
        return Icon(Icons.check_circle, color: Colors.greenAccent);
      default:
        return SizedBox.shrink();
    }
  }
}
