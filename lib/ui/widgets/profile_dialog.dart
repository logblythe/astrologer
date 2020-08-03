import 'package:astrologer/core/data_model/user_model.dart';
import 'package:astrologer/core/validator_mixin.dart';
import 'package:astrologer/core/view_model/view/profile_view_model.dart';
import 'package:astrologer/ui/base_widget.dart';
import 'package:astrologer/ui/shared/route_paths.dart';
import 'package:astrologer/ui/shared/ui_helpers.dart';
import 'package:astrologer/ui/widgets/circular_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileDialog extends StatelessWidget with ValidationMixing {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BaseWidget<ProfileViewModel>(
        model: ProfileViewModel(profileService: Provider.of(context)),
        onModelReady: (model) async {
          await model.getLoggedInUser();
        },
        builder: (context, model, _) {
          final UserModel user = model.user;
          return Scaffold(
            appBar: AppBar(
              title: Text('Profile'),
            ),
            body: profileBody(context, model, user),
          );
        });
  }

  Widget _listTile(String title, Icon prefixIcon,
      {bool obscureText: false,
      Widget suffixIcon,
      TextEditingController controller,
      FormFieldValidator validator,
      TextInputType keyboardType,
      String initialValue}) {
    return TextFormField(
      validator: validator,
      decoration: InputDecoration(
          isDense: true,
          labelText: title,
          labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          prefixIcon: prefixIcon,
          suffix: suffixIcon),
      obscureText: obscureText,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      controller: controller,
      keyboardType: keyboardType,
      initialValue: initialValue,
    );
  }

  Widget profileBody(
      BuildContext context, ProfileViewModel model, UserModel user) {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            UIHelper.verticalSpaceMedium,
            Center(
              child: CircularImage(
                  imageUrl: Provider.of<String>(context),
                  onImageCaptured: (imageFile) {
                    model.upload(imageFile);
                  }),
            ),
            UIHelper.verticalSpaceSmall,
            _listTile("FULL NAME", Icon(Icons.person_outline),
                validator: isEmptyValidation,
                initialValue: model.user.firstName + model.user.lastName),
            UIHelper.verticalSpaceMedium,
            _listTile("EMAIL", Icon(Icons.mail_outline),
                validator: validateEmail, initialValue: model.user.email),
            UIHelper.verticalSpaceMedium,
            _listTile("COUNTRY", Icon(Icons.my_location),
                validator: isEmptyValidation, initialValue: model.user.country),
            UIHelper.verticalSpaceMedium,
            _listTile("CITY", Icon(Icons.location_city),
                validator: isEmptyValidation, initialValue: model.user.city),
            UIHelper.verticalSpaceMedium,
            _listTile("PHONE", Icon(Icons.phone_android),
                validator: isEmptyValidation, initialValue: model.user.phoneNumber),
            UIHelper.verticalSpaceMedium,
            Align(
              alignment: Alignment.bottomRight,
              child: _registerButton(model, context),
            )
          ],
        ),
      ),
    );
  }

  Widget _registerButton(ProfileViewModel model, BuildContext context) {
    return AnimatedSwitcher(
      transitionBuilder: (Widget child, Animation<double> animation) =>
          ScaleTransition(child: child, scale: animation),
      duration: Duration(milliseconds: 250),
      child: model.busy
          ? CircularProgressIndicator()
          : RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32)),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'UPDATE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  )
                ],
              ),
              onPressed: () async {
                if (formKey.currentState.validate()) {
                  formKey.currentState.save();
                  /* var response = await model.register(
              _nameController.text.split(" ")[0],
              _nameController.text
                  .split(" ")
                  .length > 1
                  ? _nameController.text.split(" ")[1]
                  : '',
              _emailController.text,
              _passwordController.text,
               selectedGender,
                      DateFormat("yyyy-MM-d").format(DateFormat('MMM d, yyyy')
                          .parse(_dateController.text)),
                      DateFormat("HH:mm").format(
                          DateFormat("hh:mm a").parse(_timeController.text)),
                      _timeAccurate,
                      _country,
                      _locationController.text,

                      _phoneController.text,
                      _stateController.text,
                      fcmToken
            );*/
                  /* if (response.errorMessage != null) {
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text(response.errorMessage),
              ));
            }*/
                }
              },
              color: Theme.of(context).primaryColor,
            ),
    );
  }
}

class NoUserDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Image.asset(
              "assets/images/ic_question.png",
              height: 160,
            ),
          ),
          UIHelper.verticalSpaceMedium,
          Text(
            'LOG IN & CONTINUE ?',
            style: Theme.of(context).textTheme.bodyText1,
          ),
          UIHelper.verticalSpaceSmall,
          Text(
            "Looks like you haven\'t logged into our system. Would you like to log in and continue",
            style: Theme.of(context).textTheme.bodyText1.copyWith(
                color: Theme.of(context).disabledColor,
                fontWeight: FontWeight.w400),
          ),
          UIHelper.verticalSpaceSmall,
          Align(
            alignment: Alignment.bottomRight,
            child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32)),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                color: Theme.of(context).primaryColor,
                child: Text(
                  'Ok! Let me login',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.left,
                ),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, RoutePaths.login,
                      ModalRoute.withName(RoutePaths.home));
                }),
          )
        ],
      ),
    );
  }
}
