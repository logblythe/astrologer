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
          body: Builder(
            builder: (context) => SafeArea(
              child: Container(
                alignment: Alignment.center,
                child: SingleChildScrollView(
                    padding: EdgeInsets.all(8.0),
                    child: UserDetails(model: model)),
              ),
            ),
          ),
        );
      },
    );
  }
}
