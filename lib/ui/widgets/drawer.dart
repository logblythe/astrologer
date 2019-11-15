/*
import 'package:flutter/material.dart';

class Drawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
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
        ListTile(title: Text('Customer support'), leading: Icon(Icons.people)),
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
    );
  }
}
*/
