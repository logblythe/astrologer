import 'package:astrologer/core/constants/end_points.dart';
import 'package:astrologer/core/data_model/user_model.dart';
import 'package:astrologer/core/enum/gender.dart';
import 'package:astrologer/core/validator_mixin.dart';
import 'package:astrologer/core/view_model/base_view_model.dart';
import 'package:astrologer/core/view_model/view/profile_view_model.dart';
import 'package:astrologer/core/view_model/view/signup_viewmodel.dart';
import 'package:astrologer/ui/shared/ui_helpers.dart';
import 'package:astrologer/ui/widgets/gender_selection.dart';
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
  bool _timeAccurate = false;
  String _country = "Select One";
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
      _countryFocusNode,
      _phoneFocusNode;

  bool _countryDropDownValid = true;

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
          _listTile(
            "FULL NAME",
            Icon(Icons.person),
            controller: _nameController,
            validator: isEmptyValidation,
          ),
          UIHelper.verticalSpaceMedium,
          _listTile(
            "EMAIL",
            Icon(Icons.email),
            controller: _emailController,
            validator: validateEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          UIHelper.verticalSpaceMedium,
          _listTile(
            "PASSWORD",
            Icon(Icons.lock),
            suffixIcon: Icon(Icons.remove_red_eye),
            controller: _passwordController,
            validator: isEmptyValidation,
          ),
          UIHelper.verticalSpaceMedium,
          _listTile(
            "CONFIRM PASSWORD",
            Icon(Icons.lock),
            controller: _conPasswordController,
            validator: isEmptyValidation,
          ),
          UIHelper.verticalSpaceMedium,
          _listTile(
            "PHONE",
            Icon(Icons.phone_android),
            controller: _phoneController,
            validator: isEmptyValidation,
            keyboardType: TextInputType.number,
          ),
          UIHelper.verticalSpaceMedium,
          _dateTimeRow(),
          UIHelper.verticalSpaceMedium,
          _listTile(
            "Country",
            Icon(Icons.local_airport),
            controller: _countryController,
            validator: isEmptyValidation,
          ),
          UIHelper.verticalSpaceMedium,
          _locationTextField(),
          Container(
            margin: EdgeInsets.only(top: 32),
            alignment: Alignment.bottomRight,
            child: _registerButton(model, context),
          ),
          Container(
            margin: EdgeInsets.only(top: 120),
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
                      text: 'Sign in',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void updateGender(Gender gender) {
    selectedGender = gender;
  }

  Widget _listTile(String title, Icon prefixIcon,
      {bool obscureText: false,
      Widget suffixIcon,
      TextEditingController controller,
      FormFieldValidator validator,
      TextInputType keyboardType}) {
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
    );
  }

  Widget _dateTimeRow() {
    DateTime currentDate = DateTime.now();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Flexible(
          fit: FlexFit.loose,
          flex: 2,
          child: Container(
            margin: EdgeInsets.all(2),
            child: TextFormField(
              readOnly: true,
              validator: isEmptyValidation,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_timeFocusNode),
              focusNode: _dateFocusNode,
              onTap: () async {
                DateTime selectedDate = await showDatePicker(
                    context: context,
                    initialDate: currentDate,
                    firstDate: DateTime(1980),
                    lastDate: currentDate);
                setState(() {
                  if (selectedDate != null) date = selectedDate;
                  _dateController.text = DateFormat.yMMMd().format(date);
                });
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.calendar_today),
                isDense: true,
                labelStyle:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                labelText: 'Date of birth',
              ),
              maxLines: 1,
              controller: _dateController,
            ),
          ),
        ),
        Flexible(
          fit: FlexFit.loose,
          flex: 1,
          child: Container(
            margin: EdgeInsets.all(2),
            child: TextFormField(
              readOnly: true,
              validator: isEmptyValidation,
              focusNode: _timeFocusNode,
              onTap: () async {
                TimeOfDay selectedTime = await showTimePicker(
                    context: context, initialTime: TimeOfDay.now());
                setState(() {
                  if (selectedTime != null) {
                    time = selectedTime;
                    _timeController.text = DateFormat("hh:mm a").format(
                        DateFormat("HH:mm").parse(time.format(context)));
                  }
                });
              },
              decoration: InputDecoration(
                labelText: 'Time',
                isDense: true,
                labelStyle:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              maxLines: 1,
              controller: _timeController,
            ),
          ),
        ),
      ],
    );
  }

  Widget _accurateTimeSwitch() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SwitchListTile(
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: const Text('Time is accurate'),
        ),
        value: _timeAccurate,
        onChanged: (bool value) {
//          widget.themeStream.addValue(value);
          setState(() {
            _timeAccurate = value;
          });
        },
        secondary: const Icon(Icons.access_time),
      ),
    );
  }

  Widget _countryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(Icons.my_location),
        title: Container(
          width: double.infinity,
          child: DropdownButton<String>(
            hint: Text('Select Country'),
            underline: Container(
              color: _countryDropDownValid
                  ? Theme.of(context).disabledColor
                  : Colors.red,
              height: 1,
              width: double.infinity,
            ),
            isExpanded: true,
            value: _country,
            onChanged: (String newValue) {
              setState(() {
                _country = newValue;
              });
            },
            items: country.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _locationTextField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          flex: 1,
          child: TextFormField(
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_locationFocusNode);
            },
            keyboardType: TextInputType.number,
            validator: isEmptyValidation,
            focusNode: _stateFocusNode,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.location_on),
              labelText: 'State',
              isDense: true,
              labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            maxLines: 1,
            controller: _stateController,
          ),
        ),
        UIHelper.horizontalSpaceSmall,
        Flexible(
          flex: 2,
          child: TextFormField(
            validator: isEmptyValidation,
            focusNode: _locationFocusNode,
            decoration: InputDecoration(
              labelText: 'Location',
              isDense: true,
              labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            maxLines: 1,
            controller: _locationController,
          ),
        ),
      ],
    );
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
              onPressed: _handleButtonPress,
              color: Theme.of(context).primaryColor,
            ),
    );
  }

  void _handleButtonPress() async {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      var dob = DateFormat("yyyy-MM-d")
          .format(DateFormat('MMM d, yyyy').parse(_dateController.text));
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
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(response.errorMessage),
        ));
      }
    }
  }

  Future<bool> updateUser() async {
    if (validateForm()) {
      var result = await (model as ProfileViewModel).updateUser(
        UserModel(
            firstName: _nameController.text.split(" ")[0],
            lastName: _nameController.text.split(" ")[1],
            email: _emailController.text,
            phoneNumber: _phoneController.text,
            gender: selectedGender == Gender.male ? MALE : FEMALE,
            city: _locationController.text,
            state: _stateController.text,
            country: _country,
            dateOfBirth: DateFormat("yyyy-MM-d")
                .format(DateFormat('MMM d, yyyy').parse(_dateController.text)),
            birthTime: DateFormat("HH:mm")
                .format(DateFormat("hh:mm a").parse(_timeController.text)),
            accurateTime: _timeAccurate),
      );
      if (result == null) {
        Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Please try again')),
        );
        return false;
      } else {
        return true;
      }
    }
    return null;
  }

  bool validateForm() {
    bool _isValid = formKey.currentState.validate();
    if (_country == "Select One") {
      setState(() {
        _countryDropDownValid = false;
      });
      _isValid = false;
    } else {
      setState(() {
        _countryDropDownValid = true;
      });
      _isValid = true;
    }
    return _isValid;
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
      _timeAccurate = user.accurateTime;
      _country = user.country;
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
