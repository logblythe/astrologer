import 'package:astrologer/core/validator_mixin.dart';
import 'package:astrologer/core/view_model/view/login_viewmodel.dart';
import 'package:astrologer/ui/base_widget.dart';
import 'package:astrologer/ui/shared/route_paths.dart';
import 'package:astrologer/ui/shared/ui_helpers.dart';
import 'package:astrologer/ui/widgets/text_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with ValidationMixing {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _buttonNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return BaseWidget<LoginViewModel>(
      model: LoginViewModel(
        userService: Provider.of(context),
        homeService: Provider.of(context),
        navigationService: Provider.of(context),
      ),
      builder: (context, model, child) => Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.bottomRight,
                child: Image.asset(
                  "assets/images/ic_sign_up.png",
                  height: 80,
                  width: 80,
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Container(
                      padding:
                          const EdgeInsets.only(left: 32.0, right: 32, top: 64),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 32.0,
                            ),
                          ),
                          Text(
                            "Please sign in to continue",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 20.0,
                            ),
                          ),
                          UIHelper.verticalSpaceLarge,
                          TextInput(
                            title: "EMAIL",
                            prefixIcon: Icon(Icons.mail_outline),
                            controller: _usernameController,
                            validator: validateEmail,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          UIHelper.verticalSpaceMedium,
                          TextInput(
                            title: "PASSWORD",
                            prefixIcon: Icon(Icons.lock_outline),
                            suffixIcon: GestureDetector(
                              child: Icon(
                                Icons.remove_red_eye,
                                color: model.obscureText
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).disabledColor,
                              ),
                              onTap: model.toggleObscureText,
                            ),
                            obscureText: model.obscureText,
                            controller: _passwordController,
                            validator: validatePassword,
                          ),
                          SizedBox(height: 32),
                          Align(
                              alignment: Alignment.bottomRight,
                              child: _buildAnimatedLoginButton(model, context)),
                          UIHelper.verticalSpaceMedium,
                          Align(
                              alignment: Alignment.center,
                              child: _buildErrorText(model)),
                          _buildAnimatedSwitcher(model, context)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorText(LoginViewModel model) {
    return model.hasError
        ? Text(model.errorMessage, style: TextStyle(color: Colors.red))
        : Container();
  }

  AnimatedSwitcher _buildAnimatedLoginButton(
      LoginViewModel model, BuildContext context) {
    return AnimatedSwitcher(
      transitionBuilder: (Widget child, Animation<double> animation) =>
          ScaleTransition(child: child, scale: animation),
      duration: Duration(milliseconds: 250),
      child: model.busy
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            )
          : RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32)),
              focusNode: _buttonNode,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'LOGIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                ],
              ),
              onPressed: () => _handleLoginPress(context, model),
              color: Theme.of(context).primaryColor,
            ),
    );
  }

  AnimatedSwitcher _buildAnimatedSwitcher(
      LoginViewModel model, BuildContext context) {
    return AnimatedSwitcher(
      transitionBuilder: (Widget child, Animation<double> animation) =>
          ScaleTransition(child: child, scale: animation),
      duration: Duration(milliseconds: 250),
      child: model.busy
          ? Container()
          : Container(
              margin: EdgeInsets.only(top: 120),
              alignment: Alignment.center,
              child: InkWell(
                child: RichText(
                  text: TextSpan(
                    text: "Don\'t have an account? ",
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(color: Theme.of(context).disabledColor),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'Sign up',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor)),
                    ],
                  ),
                ),
                onTap: model.navigateToSignUp,
              ),
            ),
    );
  }

  _handleLoginPress(BuildContext context, LoginViewModel model) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      var loginResponse =
          await model.login(_usernameController.text, _passwordController.text);
      if (loginResponse.token != null) {
        Navigator.pushReplacementNamed(
          context,
          RoutePaths.home,
        );
      }
    }
  }
}
