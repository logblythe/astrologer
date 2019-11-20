import 'package:astrologer/core/data_model/message_model.dart';
import 'package:astrologer/core/view_model/view/dashboard_view_model.dart';
import 'package:astrologer/ui/widgets/cart_item.dart';
import 'package:astrologer/ui/base_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardView extends StatefulWidget {
  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with AutomaticKeepAliveClientMixin {
  bool isShowSticker = false;
  TextEditingController _messageController;
  FocusNode _messageFocusNode;
  DashboardViewModel _dashboardViewModel;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dashboardViewModel = DashboardViewModel(
      homeService: Provider.of(context),
      userService: Provider.of(context),
      sharedPrefHelper: Provider.of(context),
    );
    _messageController = TextEditingController();
  }

  @override
  void initState() {
    super.initState();
    _messageFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BaseWidget(
      model: _dashboardViewModel,
      onModelReady: (DashboardViewModel model) => model.init(),
      builder: (context, DashboardViewModel model, child) {
        _messageController
          ..text = model.messageBox
          ..selection =
              TextSelection.collapsed(offset: _messageController.text.length);
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32))),
            child: model.messages == null
                ? const Center(child: const CircularProgressIndicator())
                : Column(
                    children: <Widget>[
                      buildListMessage(model),
                      buildInput(model),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget buildListMessage(DashboardViewModel model) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        child: AnimatedList(
          key: _listKey,
          initialItemCount: model.messages.length,
          reverse: true,
          shrinkWrap: true,
          padding: EdgeInsets.all(8.0),
          itemBuilder: (context, index, animation) {
            MessageModel _message = model.messages[index];
            return CardItem(
              message: _message,
              animation: animation,
              item: index,
              onTap: () {},
            );
          },
        ),
      ),
    );
  }

  buildInput(DashboardViewModel model) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.all(8.0),
        child: Row(children: [
          Expanded(
            child: TextField(
              onChanged: (text) {
                model.addMsgToSink(text, false);
              },
              focusNode: _messageFocusNode,
              controller: _messageController,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(12),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(25.0)),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.circular(25.0)),
                  border: InputBorder.none,
                  hintText: 'Type message...'),
            ),
          ),
          IconButton(
              icon: Icon(
                Icons.send,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () => addMessage(model)),
        ]),
      ),
    );
  }

  void addMessage(DashboardViewModel model) async {
    if (model.googlePayEnabled) {
      _listKey.currentState
          .insertItem(0, duration: Duration(milliseconds: 500));
      await model.addMessage(
          MessageModel(message: _messageController.text, sent: true));
      _messageController.clear();
    } else {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text("Google pay is not available")));
    }
  }

  @override
// TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
