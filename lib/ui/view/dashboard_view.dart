import 'package:astrologer/core/data_model/message_model.dart';
import 'package:astrologer/core/view_model/view/dashboard_view_model.dart';
import 'package:astrologer/ui/base_widget.dart';
import 'package:astrologer/ui/shared/route_paths.dart';
import 'package:astrologer/ui/widgets/message_item.dart';
import 'package:astrologer/ui/widgets/no_message.dart';
import 'package:astrologer/ui/widgets/no_user_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardView extends StatefulWidget {
  final GlobalKey<AnimatedListState> listKey;

  const DashboardView({Key key, this.listKey}) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with AutomaticKeepAliveClientMixin {
  TextEditingController _messageController;
  FocusNode _messageFocusNode;
  DashboardViewModel _dashboardViewModel;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BaseWidget(
      model: _dashboardViewModel,
      onModelReady: (DashboardViewModel model) => model.init(),
      builder: (context, DashboardViewModel model, child) {
        if (model.messageBox != null) {
          FocusScope.of(context).requestFocus(_messageFocusNode);
        }
        _messageController
          ..text = model.messageBox
          ..selection =
              TextSelection.collapsed(offset: _messageController.text.length);
        return GestureDetector(
          onTap: () => _messageFocusNode.unfocus(),
          child: Stack(
            children: <Widget>[
              Image.asset(
                "assets/images/background.png",
                fit: BoxFit.fill,
                width: MediaQuery.of(context).size.width,
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                child: Column(
                  children: <Widget>[
                    buildListMessage(model),
                    buildInput(model),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildListMessage(DashboardViewModel model) {
    return Expanded(
      child: model.fetchingList
          ? const Center(child: CircularProgressIndicator())
          : model.messages == null || model.messages.length == 0
              ? Center(
                  child: model.user == null
                      ? NoMessageWidget(
                          buttonTitle: "Ok! Let me login",
                          buttonTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                                context,
                                RoutePaths.login,
                                ModalRoute.withName(RoutePaths.home));
                          },
                        )
                      : NoMessageWidget(
                          buttonTitle: "Ok! Lets chat",
                          buttonTap: () {
                            FocusScope.of(context)
                                .requestFocus(_messageFocusNode);
                          },
                        ),
                )
              : AnimatedList(
                  key: widget.listKey,
                  initialItemCount: model.messages?.length,
                  reverse: true,
                  shrinkWrap: true,
                  padding: EdgeInsets.all(8.0),
                  itemBuilder: (context, index, animation) {
                    MessageModel _message = model.messages[index];
                    return MessageItem(
                      darkMode: model.darkModeEnabled,
                      message: _message,
                      animation: animation,
                      item: index,
                      onTap: () {},
                    );
                  },
                ),
    );
  }

  buildInput(DashboardViewModel model) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.white.withOpacity(.6),
        padding: const EdgeInsets.all(8.0),
        child: Row(children: [
          Expanded(
            child: TextField(
              onChanged: (text) => model.addMsgToSink(text, false),
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
          AnimatedCrossFade(
            firstChild: IconButton(
                icon: Icon(
                  Icons.send,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () => addMessage(model)),
            secondChild: Container(),
            duration: Duration(milliseconds: 200),
            crossFadeState: _dashboardViewModel.showSendBtn
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            sizeCurve: Curves.easeOutSine,
            firstCurve: Curves.easeOutSine,
            secondCurve: Curves.easeOutSine,
          ),
        ]),
      ),
    );
  }

  void addMessage(DashboardViewModel model) async {
    if (model.user == null) {
      showDialog(
          context: context,
          builder: (context) {
            return NoUserDialog();
          });
    } else {
      if (_messageController.text != "") {
        var _message =
            MessageModel(message: _messageController.text, sent: true);
        final _listState = widget.listKey.currentState;
        if (_listState != null)
          _listState.insertItem(0, duration: Duration(milliseconds: 500));
        await model.addMessage(_message);
        await model.askQuestion(_message);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dashboardViewModel = DashboardViewModel(
      homeService: Provider.of(context),
      userService: Provider.of(context),
      settingsService: Provider.of(context),
    );
  }

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _messageFocusNode = FocusNode()
      ..addListener(() {
        if (_messageFocusNode.hasFocus) {
          _dashboardViewModel.showSendBtn = true;
        } else {
          _dashboardViewModel.showSendBtn = false;
        }
      });
  }

  @override
  bool get wantKeepAlive => true;
}
