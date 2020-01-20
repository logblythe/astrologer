import 'package:astrologer/core/data_model/user_model.dart';
import 'package:astrologer/ui/shared/ui_helpers.dart';
import 'package:astrologer/ui/widgets/circular_image.dart';
import 'package:flutter/material.dart';

class ProfileDialog extends StatelessWidget {
  final UserModel userModel;

  const ProfileDialog({Key key, this.userModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            UIHelper.verticalSpaceSmall,
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.close),
                splashColor: Colors.redAccent,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Material(
              type: MaterialType.circle,
              color: Colors.white,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: CircularImage(),
              ),
            ),
            UIHelper.verticalSpaceMedium,
            Text(
              userModel.firstName,
              style:
                  Theme.of(context).textTheme.headline.copyWith(fontSize: 20),
            ),
            UIHelper.verticalSpaceMedium,
            Divider(),
            UIHelper.verticalSpaceMedium,
            _buildProfileItem(context,
                title: "PHONE NUMBER",
                subtitle: userModel.phoneNumber,
                iconData: Icons.phone),
            _buildProfileItem(context,
                title: "EMAIL",
                subtitle: userModel.email,
                iconData: Icons.mail),
            _buildProfileItem(context,
                title: "ADDRESS",
                subtitle: "${userModel.city}, ${userModel.country}",
                iconData: Icons.place),
            UIHelper.verticalSpaceMedium,
            MaterialButton(
              padding: EdgeInsets.all(16),
              minWidth: MediaQuery.of(context).size.width / 1.4,
              color: Theme.of(context).primaryColor,
              highlightColor: Colors.green,
              child: Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
              splashColor: Colors.green,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context,
      {String title, String subtitle, IconData iconData}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).disabledColor),
          ),
          Container(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                iconData,
                color: Colors.redAccent,
              ),
              UIHelper.horizontalSpaceSmall,
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
