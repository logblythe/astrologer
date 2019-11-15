import 'package:astrologer/core/view_model/view/home_view_model.dart';
import 'package:astrologer/ui/base_widget.dart';
import 'package:astrologer/ui/shared/route_paths.dart';
import 'package:astrologer/ui/shared/theme_stream.dart';
import 'package:astrologer/ui/view/profile_view.dart';
import 'package:astrologer/ui/widgets/user_details.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import 'astrologers_view.dart';
import 'dashboard_view.dart';

class HomeView extends StatefulWidget {
  final ThemeStream themeStream;

  const HomeView({Key key, this.themeStream}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String fcmToken;
  int _index = 0;
  PageController _pageController;
  static GlobalKey<UserDetailsState> _formKey = GlobalKey();
  final FirebaseMessaging _fcm = FirebaseMessaging();
  HomeViewModel _homeViewModel;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  final List<Map<String, dynamic>> _children = [
    {
      'title': 'Dashboard',
      'action': Icons.person_pin,
    },
    {
      'title': 'Birth Profile',
      'action': Icons.check_circle,
    },
    {
      'title': 'Astrologers',
    },
  ];

  void _getToken() async {
    fcmToken = await _fcm.getToken();
    print('the token is $fcmToken');
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _getToken();
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async =>
           _onNotificationReceived(message),
      onLaunch: (Map<String, dynamic> message) async =>
          _onNotificationReceived(message),
      onResume: (Map<String, dynamic> message) async =>
          _onNotificationReceived(message),
    );
  }

  void _onNotificationReceived(Map<String, dynamic> message) async {
    await _homeViewModel.onNotificationReceived(message);
    /* showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: ListTile(
            title: Text(message['data']['title']),
            subtitle: Text(message['data']['body']),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ));*/
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    _homeViewModel = HomeViewModel(
      homeService: Provider.of(context),
      sharedPrefHelper: Provider.of(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget<HomeViewModel>(
        model: _homeViewModel,
        onModelReady: (model) {},
        builder: (context, model, _) {
          return Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              drawer: _buildDrawer(),
              appBar: AppBar(
                centerTitle: true,
                elevation: 0,
                title: Text(_children[_index]['title']),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(_children[_index]['action']),
                    onPressed: () async {
                      switch (_index) {
                        case 0:
                          _pageController.jumpToPage(1);
                          break;

                        case 1:
                          if (await _formKey.currentState.updateUser()) {
                            _pageController.jumpToPage(0);
                          }
                          break;
                      }
                    },
                  )
                ],
              ),
              body: WillPopScope(
                child: PageView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  children: [
                    DashboardView(),
                    ProfileView(
                      userDetailsKey: _formKey,
                      themeStream: widget.themeStream,
                    ),
                    AstrologersView()
                  ],
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (page) {
                    setState(() {
                      _index = page;
                    });
                  },
                ),
                onWillPop: _onWillPop,
              ));
        });
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(height: 80, color: Theme.of(context).primaryColor),
          Container(
              color: Theme.of(context).primaryColor,
              child: ListTile(
                  title: Text(
                    'Free questions',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Text(
                    '0',
                    style: TextStyle(color: Colors.white),
                  ))),
          Container(
              color: Colors.grey,
              child: ListTile(
                  title: Text(
                    'Question price',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Text(
                    '\$0.99',
                    style: TextStyle(color: Colors.white),
                  ))),
          ListTile(
              title: Text('About Astrology',
                  style: TextStyle(color: Theme.of(context).disabledColor))),
          ListTile(
            title: Text(
              'Dashboard',
              style: Theme.of(context).textTheme.body2,
            ),
            leading: Icon(Icons.message),
            onTap: () {
              _pageController.jumpToPage(0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text(
              'Astrologers',
              style: Theme.of(context).textTheme.body2,
            ),
            leading: Icon(Icons.people),
            onTap: () {
              _pageController.jumpToPage(2);
              Navigator.pop(context);
            },
          ),
          ListTile(
              title: Text('Question price',
                  style: Theme.of(context).textTheme.body2),
              leading: Icon(Icons.check_circle)),
          ListTile(
              title: Text('Help &, Settings',
                  style: TextStyle(color: Theme.of(context).disabledColor))),
          ListTile(
              title: Text('Customer support'), leading: Icon(Icons.people)),
          ListTile(title: Text('How yodha works'), leading: Icon(Icons.people)),
          ListTile(title: Text('Terms & privacy'), leading: Icon(Icons.people)),
          ListTile(
            title: Text('Logout'),
            leading: Icon(Icons.swap_horiz),
            onTap: () {
              Navigator.pop(context);
              Navigator.popAndPushNamed(context, RoutePaths.login);
            },
          ),
          ListTile(
              title: Text(
                  'Our mission is to make Vedic astrology accssible to all people to help them attain positive changes in their lives.',
                  style: Theme.of(context).textTheme.body1)),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() {
    if (_index != 0) {
      _pageController.jumpTo(0);
      return null;
    } else {
      return showDialog(
            context: context,
            builder: (context) => new AlertDialog(
              title: new Text('Are you sure?'),
              content: new Text('Do you want to exit an App'),
              actions: <Widget>[
                new FlatButton(
                  onPressed: () async {
                    Navigator.of(context).pop(false);
                    var androidPlatformChannelSpecifics =
                        AndroidNotificationDetails('your channel id',
                            'your channel name', 'your channel description',
                            importance: Importance.Max,
                            priority: Priority.High,
                            ticker: 'ticker');
                    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
                    var platformChannelSpecifics = NotificationDetails(
                        androidPlatformChannelSpecifics,
                        iOSPlatformChannelSpecifics);
                    await flutterLocalNotificationsPlugin.show(0, 'plain title',
                        'plain body', platformChannelSpecifics,
                        payload: 'item x');
                  },
                  child: new Text('No'),
                ),
                new FlatButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: new Text('Yes'),
                ),
              ],
            ),
          ) ??
          false;
    }
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    debugPrint('notification selected');
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => new CupertinoAlertDialog(
        title: new Text(title),
        content: new Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: new Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              debugPrint('notification selected');
            },
          )
        ],
      ),
    );
  }
}
