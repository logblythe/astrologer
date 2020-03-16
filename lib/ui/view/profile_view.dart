import 'package:astrologer/core/view_model/view/profile_view_model.dart';
import 'package:astrologer/ui/base_widget.dart';
import 'package:astrologer/ui/widgets/circular_image.dart';
import 'package:astrologer/ui/widgets/user_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatefulWidget {
  final GlobalKey<UserDetailsState> userDetailsKey;

  const ProfileView({Key key, this.userDetailsKey}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      model: ProfileViewModel(profileService: Provider.of(context)),
      onModelReady: (ProfileViewModel model) {
        model.getLoggedInUser();
      },
      builder: (context, ProfileViewModel model, child) {
        return Container(
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: 160,
                    color: Colors.blue,
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.grey[100],
                      padding: EdgeInsets.only(top: 86),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Material(
                              type: MaterialType.card,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Sikshya Maharjan',
                                        style: TextStyle(
                                          fontSize: 18,
                                          wordSpacing: 5,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Icon(
                                            Icons.place,
                                            size: 20,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            'location',
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                child: Material(
                  type: MaterialType.circle,
                  color: Colors.white,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: CircularImage(),
                  ),
                ),
                left: MediaQuery.of(context).size.width / 3,
                top: 100,
              )
            ],
          ),
        );
        /*child: model.busy
              ? Center(child: CircularProgressIndicator())
              : UserDetails<ProfileViewModel>(
                  key: widget.userDetailsKey,
                  user: model.user,
                  model: model,
                ),*/
      },
    );
  }
}
