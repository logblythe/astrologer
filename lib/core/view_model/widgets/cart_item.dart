import 'package:astrologer/core/data_model/message_model.dart';
import 'package:flutter/material.dart';

class CardItem extends StatelessWidget {
  const CardItem(
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
    return Container(
      margin: EdgeInsets.only(top: 12),
      child: Column(
        children: <Widget>[
          FadeTransition(
            opacity: animation,
            child: (message.sent)
                ? Text(message.questionId?.toString() ?? 'No question id',
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold))
                : SizedBox.shrink(),
          ),
          FadeTransition(
            opacity: animation,
            child: Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(
                  bottom: 4,
                  left: message.sent ? 24 : 0,
                  right: message.sent ? 0 : 24),
              decoration: BoxDecoration(
                  color: message.sent
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(25)),
              child:
                  Text(message.message, style: TextStyle(color: Colors.white)),
            ),
          ),
          FadeTransition(
            opacity: animation,
            child: (message.sent)
                ? Text(message.status ?? 'No status',
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold))
                : SizedBox.shrink(),
          ),
        ],
        crossAxisAlignment:
            message.sent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      ),
    );
  }
}
