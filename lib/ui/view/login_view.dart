import 'package:astrologer/core/data_model/login_response.dart';
import 'package:astrologer/core/data_model/response.dart';
import 'package:astrologer/core/validator_mixin.dart';
import 'package:astrologer/core/view_model/view/login_viewmodel.dart';
import 'package:astrologer/ui/base_widget.dart';
import 'package:astrologer/ui/shared/route_paths.dart';
import 'package:astrologer/ui/shared/ui_helpers.dart';
import 'package:astrologer/ui/widgets/animated_button.dart';
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
  String _otp;

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
                          Builder(
                            builder: (con) {
                              return _buildAnimatedSwitcher(model, con);
                            },
                          )
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
        ? Card(
            color: Colors.grey[100].withOpacity(1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                model.errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            ),
          )
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
                borderRadius: BorderRadius.circular(32),
              ),
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
              onPressed: () => _handleLogin(context, model),
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
              margin: EdgeInsets.only(top: 60),
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  InkWell(
                    child: Text('Forgot password?',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor)),
                    onTap: () => _handleForgotPassword(context, model),
                  ),
                  UIHelper.verticalSpaceMedium,
                  InkWell(
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
                ],
              ),
            ),
    );
  }

  _handleLogin(BuildContext context, LoginViewModel model) async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      LoginResponse loginResponse =
          await model.login(_usernameController.text, _passwordController.text);
      if (loginResponse.token != null) {
        Navigator.pushReplacementNamed(
          context,
          RoutePaths.home,
        );
      }
    }
  }

  void _handleForgotPassword(BuildContext ctx, LoginViewModel model) {
    TextEditingController _controller = TextEditingController();
    showBottomSheet(
      context: (ctx),
      builder: (ctx) {
        return BaseWidget<LoginViewModel>(
          model: LoginViewModel(
            userService: Provider.of(ctx),
            homeService: Provider.of(ctx),
            navigationService: Provider.of(ctx),
          ),
          builder: (context, model, child) {
            return Container(
              padding: const EdgeInsets.all(32),
              height: 400,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 10, color: Colors.grey[300], spreadRadius: 5)
                ],
              ),
              child: Column(
                children: <Widget>[
                  Text(
                    "Reset Password",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                    ),
                  ),
                  UIHelper.verticalSpaceLarge,
                  TextInput(
                    title: "Email",
                    keyboardType: TextInputType.emailAddress,
                    controller: _controller,
                    prefixIcon: const Icon(Icons.mail_outline),
                  ),
                  model.errorMessage != null
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                           model.errorMessage?? "Something went wrong. Please try again",
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                        )
                      : Container(),
                  UIHelper.verticalSpaceLarge,
                  AnimatedButton(
                    label: "Reset",
                    busy: model.busy,
                    onPress: () async {
                      if (_controller.text != "") {
                        Response response = await model.requestOTP(_controller.text);
                        if (response.status=="OK") {
                          Navigator.of(context).pop();
                          _handleValidateOTP(ctx, model);
                        }
                      }
                    },
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handleValidateOTP(BuildContext ctx, LoginViewModel model) {
    TextEditingController _controller = TextEditingController();
    showBottomSheet(
      context: (ctx),
      builder: (ctx) {
        return BaseWidget<LoginViewModel>(
          model: LoginViewModel(
            userService: Provider.of(ctx),
            homeService: Provider.of(ctx),
            navigationService: Provider.of(ctx),
          ),
          builder: (context, model, child) {
            return Container(
              padding: const EdgeInsets.all(32),
              height: 400,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 10, color: Colors.grey[300], spreadRadius: 5)
                ],
              ),
              child: Column(
                children: <Widget>[
                  Text(
                    "Validate OTP",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                    ),
                  ),
                  UIHelper.horizontalSpaceSmall,
                  Text(
                    "Please check your email and enter the OTP.",
                  ),
                  UIHelper.verticalSpaceLarge,
                  TextInput(
                    title: "OTP",
                    controller: _controller,
                    obscureText: true,
                    prefixIcon: const Icon(Icons.offline_bolt),
                  ),
                  model.errorMessage != null
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(model.errorMessage??
                            "Something went wrong. Please try again",
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                        )
                      : Container(),
                  UIHelper.verticalSpaceLarge,
                  AnimatedButton(
                    label: "Validate",
                    busy: model.busy,
                    onPress: () async {
                      if (_controller.text != "") {
                        _otp=_controller.text;
                        Response response = await model.validateOTP(_controller.text);
                        if (response?.status=="OK") {
                          Navigator.of(context).pop();
                          _handleSavePassword(ctx, model);
                        }
                      }
                    },
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handleSavePassword(BuildContext ctx, LoginViewModel model) {
    TextEditingController _controller = TextEditingController();
    showBottomSheet(
      context: (ctx),
      builder: (ctx) {
        return BaseWidget<LoginViewModel>(
          model: LoginViewModel(
            userService: Provider.of(ctx),
            homeService: Provider.of(ctx),
            navigationService: Provider.of(ctx),
          ),
          builder: (context, model, child) {
            return Container(
              padding: const EdgeInsets.all(32),
              height: 400,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 10,
                        color: Colors.grey[300],
                        spreadRadius: 5)
                  ]),
              child: Column(
                children: <Widget>[
                  Text(
                    "Save Password",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                    ),
                  ),
                  UIHelper.verticalSpaceLarge,
                  TextInput(
                    title: "New password",
                    controller: _controller,
                    obscureText: true,
                    prefixIcon: const Icon(Icons.verified_user),
                  ),
                  model.errorMessage != null
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            model.errorMessage??"Something went wrong. Please try again",
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                        )
                      : Container(),
                  UIHelper.verticalSpaceLarge,
                  AnimatedButton(
                    label: "Save",
                    busy: model.busy,
                    onPress: () {
                      if (_controller.text != "")
                        model.savePassword(_otp,_controller.text);
                    },
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
