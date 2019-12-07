import 'package:astrologer/core/view_model/view/home_view_model.dart';
import 'package:astrologer/ui/view/ideas_view.dart';
import 'package:astrologer/ui/base_widget.dart';
import 'package:astrologer/ui/view/profile_view.dart';
import 'package:astrologer/ui/view/settings_view.dart';
import 'package:astrologer/ui/widgets/profile_dialog.dart';
import 'package:astrologer/ui/widgets/user_details.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:provider/provider.dart';

import 'astrologers_view.dart';
import 'dashboard_view.dart';

final List<Map<String, dynamic>> _children = [
  {
    'title': 'Dashboard',
    'action': Icons.person_pin,
  },
  {'title': 'Birth Profile'},
  {'title': 'Astrologers'},
  {'title': 'Ideas to ask'},
  {'title': 'Settings'},
];

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  PageController _pageController;
  static GlobalKey<UserDetailsState> _formKey = GlobalKey();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final FirebaseMessaging _fcm = FirebaseMessaging();
  HomeViewModel _homeViewModel;

  @override
  Widget build(BuildContext context) {
    return BaseWidget<HomeViewModel>(
      model: _homeViewModel,
      onModelReady: (_homeViewModel) async {
        await _homeViewModel.getFreeQuesCount();
        _homeViewModel.getLoggedInUser();
        _homeViewModel.fetchQuestionPrice();
      },
      builder: (context, HomeViewModel model, _) => Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        drawer: _buildDrawer(model),
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: Text(_children[model.index]['title']),
          actions: <Widget>[_buildIconButton(model)],
        ),
        body: _buildWillPopScope(model),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async =>
          _onNotificationReceived(message),
      onLaunch: (Map<String, dynamic> message) async =>
          _onNotificationReceived(message),
      onResume: (Map<String, dynamic> message) async =>
          _onNotificationReceived(message),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _homeViewModel = HomeViewModel(
      userService: Provider.of(context),
      homeService: Provider.of(context),
    );
    _initIAPs(_homeViewModel);
  }

  void _onNotificationReceived(Map<String, dynamic> message) async {
    _listKey.currentState.insertItem(0, duration: Duration(milliseconds: 500));
    await _homeViewModel.onNotificationReceived(message);
  }

  IconButton _buildIconButton(HomeViewModel model) {
    return IconButton(
      icon: Icon(_children[model.index]['action']),
      onPressed: () async {
        switch (model.index) {
          case 0:
            showDialog(
              context: context,
              builder: (context) => ProfileDialog(userModel: model.userModel),
            );
            break;
          case 1:
            if (await _formKey.currentState.updateUser()) {
              _onDrawerTap(model, 0, shouldPop: false);
            }
            break;
        }
      },
    );
  }

  WillPopScope _buildWillPopScope(HomeViewModel model) {
    return WillPopScope(
      onWillPop: () => _onWillPop(model),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: _pageViewChildren(model),
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }

  Future<bool> _onWillPop(HomeViewModel model) {
    if (model.index != 0) {
      model.index = 0;
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
                    model.showLocalNotification("title", "body");
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

  List<Widget> _pageViewChildren(HomeViewModel model) {
    return [
      DashboardView(listKey: _listKey),
      ProfileView(userDetailsKey: _formKey),
      AstrologersView(),
      IdeasView(onTap: () => _onDrawerTap(model, 0, shouldPop: false)),
      SettingsView(),
    ];
  }

  Drawer _buildDrawer(HomeViewModel model) {
    final freeCount = Provider.of<int>(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(height: 80, color: Theme.of(context).primaryColor),
          Container(
            color: Theme.of(context).primaryColor,
            child: ListTile(
              title:
                  Text('Free questions', style: TextStyle(color: Colors.white)),
              trailing: Text(freeCount?.toString(),
                  style: TextStyle(color: Colors.white)),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.grey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Question price',
                      style: TextStyle(color: Colors.white)),
                ),
                model.discountInPercentage == null
                    ? Container()
                    : model.discountInPercentage.toInt() > 0
                        ? RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                    text: '\$ ${model.priceAfterDiscount}\n',
                                    style: TextStyle(height: 1.5)),
                                TextSpan(
                                  text: ' \$ ${model.questionPrice} ',
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    height: 1.5,
                                  ),
                                ),
                                TextSpan(
                                    text:
                                        '  (${model.discountInPercentage}% off)  ',
                                    style: TextStyle(color: Colors.black45)),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('\$ ${model.priceAfterDiscount}'),
                          )
              ],
            ),
          ),
          ListTile(
              title: Text('About Astrology',
                  style: TextStyle(color: Theme.of(context).disabledColor))),
          ListTile(
            title: Text(
              'Dashboard',
              style: Theme.of(context).textTheme.body2,
            ),
            leading: Icon(Icons.developer_board),
            onTap: () => _onDrawerTap(model, 0),
          ),
          ListTile(
            title: Text(
              'Astrologers',
              style: Theme.of(context).textTheme.body2,
            ),
            leading: Icon(Icons.people),
            onTap: () => _onDrawerTap(model, 2),
          ),
          ListTile(
            title: Text(
              'What to ask?',
              style: Theme.of(context).textTheme.body2,
            ),
            leading: Icon(Icons.help),
            onTap: () => _onDrawerTap(model, 3),
          ),
          ListTile(
            title: Text(
              'Help &, Settings',
              style: TextStyle(color: Theme.of(context).disabledColor),
            ),
          ),
          ListTile(
              title: Text('Customer support'),
              leading: Icon(Icons.nature_people)),
          ListTile(
              title: Text('How Cosmos works?'),
              leading: Icon(Icons.business_center)),
          ListTile(title: Text('Terms & privacy'), leading: Icon(Icons.lock)),
          ListTile(
            title: Text('Settings'),
            leading: Icon(Icons.settings),
            onTap: () => _onDrawerTap(model, 4),
          ),
          ListTile(
              title: Text(
                  'Our mission is to make Cosmic astrology accssible to all people to help them attain positive changes in their lives.',
                  style: Theme.of(context).textTheme.body1)),
        ],
      ),
    );
  }

  void _onDrawerTap(HomeViewModel model, int index, {bool shouldPop = true}) {
    FocusScope.of(context).unfocus();
    model.index = index;
    _pageController.jumpToPage(model.index);
    if (shouldPop) {
      Navigator.pop(context);
    }
  }

  void _initIAPs(HomeViewModel model) async {
    print('Init iaps');
    var _purchaseInstance = FlutterInappPurchase.instance;
    var result = await _purchaseInstance.initConnection;
    print("Established IAP Connection..." + result);
    try {
      print('purchase instance');
      model.iaps = await _purchaseInstance.getProducts(["666"]);
      print('purchase instance ${model.iaps.length}');
      for (var i = 0; i < model.iaps.length; ++i) {
        print("the title ${model.iaps[i].title}");
        print("the price ${model.iaps[i].price}");
      }
    } catch (e) {
      print('we have error');
    }
  }
}
