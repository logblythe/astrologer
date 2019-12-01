import 'package:astrologer/core/view_model/view/profile_view_model.dart';
import 'package:astrologer/ui/base_widget.dart';
import 'package:astrologer/ui/shared/theme_stream.dart';
import 'package:astrologer/ui/widgets/user_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatefulWidget {
  final ThemeStream themeStream;
  final GlobalKey<UserDetailsState> userDetailsKey;

  const ProfileView({Key key, this.themeStream, this.userDetailsKey})
      : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      model: ProfileViewModel(profileService: Provider.of(context)),
      onModelReady: (ProfileViewModel model) async {
        await model.getLoggedInUser();
      },
      builder: (context, ProfileViewModel model, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: model.busy
              ? Center(child: CircularProgressIndicator())
              : UserDetails<ProfileViewModel>(
                  key: widget.userDetailsKey,
                  user: model.user,
                  model: model,
                ),
        );
      },
    );
  }
}
