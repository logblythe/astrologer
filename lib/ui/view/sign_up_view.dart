import 'package:astrologer/core/validator_mixin.dart';
import 'package:astrologer/core/view_model/view/signup_viewmodel.dart';
import 'package:astrologer/ui/base_widget.dart';
import 'package:astrologer/ui/shared/theme_stream.dart';
import 'package:astrologer/ui/widgets/user_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpView extends StatefulWidget {
  final ThemeStream themeStream;

  const SignUpView({Key key, this.themeStream}) : super(key: key);

  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> with ValidationMixing {
  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      model: SignUpViewModel(userService: Provider.of(context)),
      builder: (context, SignUpViewModel model, child) {
        return Scaffold(
            body: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          InkResponse(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 16, left: 16),
                                child: Icon(Icons.arrow_back),
                              ),
                              onTap: () => Navigator.pop(context)),
                          Image.asset(
                            "assets/images/ic_sign_up.png",
                            height: 80,
                            width: 80,
                          ),
                        ],
                      ),
                      Padding(padding:EdgeInsets.only(left: 32,right: 32,top: 32),child: UserDetails(model: model)),
                    ],
                  ),
                ),
              ],
            ));
      },
    );
  }
}
