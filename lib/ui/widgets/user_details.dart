import 'package:astrologer/core/data_model/user_model.dart';
import 'package:astrologer/core/enum/gender.dart';
import 'package:astrologer/core/validator_mixin.dart';
import 'package:astrologer/core/view_model/base_view_model.dart';
import 'package:astrologer/core/view_model/view/signup_viewmodel.dart';
import 'package:astrologer/ui/shared/ui_helpers.dart';
import 'package:astrologer/ui/widgets/date_time_row.dart';
import 'package:astrologer/ui/widgets/state_city_row.dart';
import 'package:astrologer/ui/widgets/text_input.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserDetails<T extends BaseViewModel> extends StatefulWidget {
  final T model;
  final UserModel user;

  const UserDetails({
    Key key,
    this.model,
    this.user,
  }) : super(key: key);

  @override
  UserDetailsState<T> createState() => UserDetailsState<T>();
}

class UserDetailsState<T extends BaseViewModel> extends State<UserDetails>
    with ValidationMixing {
  final FirebaseMessaging _fcm = FirebaseMessaging();

  SignUpViewModel model;
  GlobalKey<FormState> formKey = GlobalKey();
  UserModel user;
  String fcmToken;
  Gender selectedGender = Gender.male;
  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();
  TextEditingController _nameController,
      _locationController,
      _dateController,
      _timeController,
      _emailController,
      _conPasswordController,
      _passwordController,
      _stateController,
      _countryController,
      _phoneController;

  FocusNode _nameFocusNode,
      _locationFocusNode,
      _dateFocusNode,
      _timeFocusNode,
      _emailFocusNode,
      _passwordFocusNode,
      _stateFocusNode,
      _phoneFocusNode;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Create Account",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 32.0,
            ),
          ),
          UIHelper.verticalSpaceMedium,
          TextInput(
            title: "FULL NAME",
            prefixIcon: Icon(Icons.person),
            controller: _nameController,
            validator: isEmptyValidation,
          ),
          UIHelper.verticalSpaceMedium,
          TextInput(
            title: "EMAIL",
            prefixIcon: Icon(Icons.email),
            controller: _emailController,
            validator: validateEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          UIHelper.verticalSpaceMedium,
          TextInput(
            title: "PASSWORD",
            prefixIcon: Icon(Icons.lock),
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
            validator: isEmptyValidation,
          ),
          UIHelper.verticalSpaceMedium,
          TextInput(
            title: "CONFIRM PASSWORD",
            prefixIcon: Icon(Icons.lock),
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
            controller: _conPasswordController,
            validator: isEmptyValidation,
          ),
          UIHelper.verticalSpaceMedium,
          TextInput(
            title: "PHONE",
            prefixIcon: Icon(Icons.phone_android),
            controller: _phoneController,
            validator: isEmptyValidation,
            keyboardType: TextInputType.number,
          ),
          UIHelper.verticalSpaceMedium,
          DateTimeRow(
            dateController: _dateController,
            timeController: _timeController,
            dateFocusNode: _dateFocusNode,
            timeFocusNode: _timeFocusNode,
          ),
          UIHelper.verticalSpaceMedium,
          TextInput(
            title: "Country",
            prefixIcon: Icon(Icons.local_airport),
            controller: _countryController,
            validator: isEmptyValidation,
          ),
          UIHelper.verticalSpaceMedium,
          StateCityRow(
            locationController: _locationController,
            stateController: _stateController,
            locationFocusNode: _locationFocusNode,
            stateFocusNode: _stateFocusNode,
          ),
          Container(
            margin: EdgeInsets.only(top: 32),
            alignment: Alignment.bottomRight,
            child: _registerButton(model, context),
          ),
          InkWell(
            child: Container(
              margin: EdgeInsets.only(top: 24, bottom: 24),
              alignment: Alignment.center,
              child: RichText(
                text: TextSpan(
                  text: 'Already have a account?',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(color: Theme.of(context).disabledColor),
                  children: <TextSpan>[
                    TextSpan(
                        text: ' Sign in',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor)),
                  ],
                ),
              ),
            ),
            onTap: ()=>Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  void updateGender(Gender gender) {
    selectedGender = gender;
  }

  Widget _registerButton(SignUpViewModel model, BuildContext context) {
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
                    'SIGN UP',
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
              onPressed: () => _handleButtonPress(context),
              color: Theme.of(context).primaryColor,
            ),
    );
  }

  void _handleButtonPress(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      var dob = _dateController.text;
      user = UserModel();
      user.firstName = _nameController.text.split(" ").elementAt(0);
      user.lastName = _nameController.text.split(" ").elementAt(1) ?? "";
      user.email = _emailController.text;
      user.password = _passwordController.text;
      user.phoneNumber = _phoneController.text;
      user.city = _locationController.text;
      user.state = _stateController.text;
      user.country = _countryController.text;
      user.dateOfBirth = dob;
      user.birthTime = _timeController.text;
      user.accurateTime = true;
      var response = await model.register(user: user);
      if (response.errorMessage != null) {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(response.errorMessage),
          ),
        );
      }else{
        showSuccessDialog(context);
      }
    }
  }

  showSuccessDialog(_context){
    showDialog(
      context: _context,
      builder: (context) {
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
                'Account created',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              UIHelper.verticalSpaceSmall,
              Text(
                "Please Check your email and verify your email. After email verification you can proceed to login.",
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
                      'Ok',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.left,
                    ),
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _getToken();
    model = widget.model;
    user = widget.user;
    _nameController = TextEditingController();
    _locationController = TextEditingController();
    _timeController = TextEditingController();
    _dateController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _conPasswordController = TextEditingController();
    _phoneController = TextEditingController();
    _stateController = TextEditingController();
    _countryController = TextEditingController();
    _nameFocusNode = FocusNode();
    _locationFocusNode = FocusNode();
    _dateFocusNode = FocusNode();
    _timeFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _phoneFocusNode = FocusNode();
    _stateFocusNode = FocusNode();
    if (!(model is SignUpViewModel)) {
      _nameController.text = '${user.firstName} ${user.lastName}';
      _locationController.text = user.city;
      _timeController.text = DateFormat("hh:mm a")
          .format(DateFormat("HH:mm").parse(user.birthTime));
      _dateController.text = user.dateOfBirth;
      /* _dateController.text = DateFormat.yMMMd()
          .format(DateFormat("yyyy-MM-d").parse(user.dateOfBirth));*/
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber;
      _stateController.text = user.state;
      selectedGender = user.gender == MALE ? Gender.male : Gender.female;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _locationController.dispose();
    _timeController.dispose();
    _dateController.dispose();
    _emailController.dispose();
    _conPasswordController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _nameFocusNode.dispose();
    _locationFocusNode.dispose();
    _dateFocusNode.dispose();
    _timeFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _phoneFocusNode.dispose();
    _stateController.dispose();
    _stateFocusNode.dispose();
  }

  void _getToken() async {
    fcmToken = await _fcm.getToken();
  }
}
