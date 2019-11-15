import 'package:astrologer/core/validator_mixin.dart';
import 'package:astrologer/core/view_model/view/login_viewmodel.dart';
import 'package:astrologer/ui/base_widget.dart';
import 'package:astrologer/ui/shared/route_paths.dart';
import 'package:astrologer/ui/shared/ui_helpers.dart';
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
  final _usernameNode = FocusNode();
  final _passwordNode = FocusNode();
  final _buttonNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return BaseWidget<LoginViewModel>(
      model: LoginViewModel(userService: Provider.of(context)),
      builder: (context, model, child) => Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildTitleText(context),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _buildUsername(context),
                            UIHelper.verticalSpaceSmall,
                            _buildPassword(model, context)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildErrorText(model),
                _buildAnimatedLoginButton(model, context),
                _buildAnimatedSwitcher(model, context)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPassword(LoginViewModel model, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: TextFormField(
          focusNode: _passwordNode,
          controller: _passwordController,
          obscureText: model.obscureText,
          validator: validatePassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (value) {
            _passwordNode.unfocus();
            FocusScope.of(context).requestFocus(_buttonNode);
          },
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.remove_red_eye,
                  color: model.obscureText ? Colors.grey : Colors.blueAccent),
              onPressed: () {
                model.toggleObscureText();
              },
            ),
          ),
          keyboardType: TextInputType.emailAddress),
    );
  }

  Widget _buildUsername(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: TextFormField(
          focusNode: _usernameNode,
          controller: _usernameController,
          textInputAction: TextInputAction.next,
          validator: validateEmail,
          onFieldSubmitted: (value) {
            _usernameNode.unfocus();
            FocusScope.of(context).requestFocus(_passwordNode);
          },
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'example@example.com',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          keyboardType: TextInputType.emailAddress),
    );
  }

  Widget _buildTitleText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        "Ahem Brahmasmi",
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 32.0,
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
          ? CircularProgressIndicator()
          : Container(
              margin: EdgeInsets.all(16.0),
              width: MediaQuery.of(context).size.width,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32)),
                focusNode: _buttonNode,
                padding: EdgeInsets.all(22.0),
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    var loginResponse = await model.login(
                        _usernameController.text, _passwordController.text);
                    if (loginResponse.error == null) {
                      Navigator.pushReplacementNamed(
                        context,
                        RoutePaths.home,
                      );
                    }
                  }
                },
                color: Theme.of(context).primaryColor,
              ),
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
          : InkWell(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Create an account',
                  style: Theme.of(context).textTheme.subhead,
                ),
              ),
              onTap: () => Navigator.pushNamed(context, RoutePaths.signup),
            ),
    );
  }
}
