import 'package:astrologer/core/constants/end_points.dart';
import 'package:astrologer/core/enum/gender.dart';
import 'package:astrologer/core/data_model/user_model.dart';
import 'package:astrologer/core/validator_mixin.dart';
import 'package:astrologer/core/view_model/base_view_model.dart';
import 'package:astrologer/core/view_model/view/profile_view_model.dart';
import 'package:astrologer/core/view_model/view/signup_viewmodel.dart';
import 'package:astrologer/ui/shared/ui_helpers.dart';
import 'package:astrologer/ui/widgets/circular_image.dart';
import 'package:astrologer/ui/widgets/gender_selection.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:astrologer/ui/shared/route_paths.dart';

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

  T model;
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
      _passwordController,
      _stateController,
      _phoneController;
  FocusNode _nameFocusNode,
      _locationFocusNode,
      _dateFocusNode,
      _timeFocusNode,
      _emailFocusNode,
      _passwordFocusNode,
      _stateFocusNode,
      _phoneFocusNode;

  bool _countryDropDownValid = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          )),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(8.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              model is SignUpViewModel
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        "Ahem Brahmasmi",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 32.0,
                        ),
                      ),
                    )
                  : Center(
                      child: CircularImage(),
                    ),
              _nameRow(),
              model is SignUpViewModel ? _phoneTextField() : SizedBox.shrink(),
              model is SignUpViewModel ? _emailTextField() : SizedBox.shrink(),
              model is SignUpViewModel
                  ? _passwordTextField(model as SignUpViewModel)
                  : Container(),
              _dateTimeRow(),
              _accurateTimeSwitch(),
              _countryDropdown(),
              _locationTextField(),
              model is SignUpViewModel
                  ? _registerButton(model as SignUpViewModel, context)
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  void updateGender(Gender gender) {
    selectedGender = gender;
  }

  Widget _nameRow() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: GenderSelection(
            updateGender: updateGender,
            selectedGender: selectedGender,
          ),
        ),
        ListTile(
          leading: Icon(Icons.perm_identity),
          title: Container(
            margin: EdgeInsets.all(2),
            child: TextFormField(
              validator: isEmptyValidation,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_phoneFocusNode),
              focusNode: _nameFocusNode,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Joy Honey',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              maxLines: 1,
              controller: _nameController,
            ),
          ),
        ),
        /*  ListTile(
          leading: Icon(Icons.perm_identity),
          title: Row(children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.all(2),
                child: TextFormField(
                  validator: isEmptyValidation,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_lnameFocusNode),
                  focusNode: _nameFocusNode,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    hintText: 'Joy',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  maxLines: 1,
                  controller: _nameController,
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.all(2),
                child: TextFormField(
                  validator: isEmptyValidation,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_phoneFocusNode),
                  focusNode: _lnameFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    hintText: 'Honey',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  maxLines: 1,
                  controller: _lnameController,
                ),
              ),
            ),
          ]),
        ),*/
      ],
    );
  }

  Widget _phoneTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(Icons.smartphone),
        title: TextFormField(
          maxLength: 10,
          validator: isEmptyValidation,
          onFieldSubmitted: (_) =>
              FocusScope.of(context).requestFocus(_emailFocusNode),
          focusNode: _phoneFocusNode,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Phone',
            hintText: 'Phone',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
          maxLines: 1,
          controller: _phoneController,
        ),
      ),
    );
  }

  Widget _emailTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(Icons.mail_outline),
        title: TextFormField(
          validator: validateEmail,
          onFieldSubmitted: (_) =>
              FocusScope.of(context).requestFocus(_passwordFocusNode),
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'example@example.com',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
          maxLines: 1,
          controller: _emailController,
        ),
      ),
    );
  }

  Widget _passwordTextField(SignUpViewModel model) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(Icons.lock_outline),
        title: TextFormField(
          validator: isEmptyValidation,
          onFieldSubmitted: (_) =>
              FocusScope.of(context).requestFocus(_dateFocusNode),
          focusNode: _passwordFocusNode,
          obscureText: model.obscureText,
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.remove_red_eye,
                color: !model.obscureText
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).disabledColor,
              ),
              onPressed: () => model.toggleObscureText(),
            ),
          ),
          maxLines: 1,
          controller: _passwordController,
        ),
      ),
    );
  }

  Widget _dateTimeRow() {
    DateTime currentDate = DateTime.now();
    return ListTile(
      leading: Icon(Icons.calendar_today),
      title: Row(
        children: <Widget>[
          Flexible(
            fit: FlexFit.loose,
            flex: 2,
            child: Container(
              margin: EdgeInsets.all(2),
              child: TextFormField(
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
                  labelText: 'Date of birth',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                maxLines: 1,
                controller: _timeController,
              ),
            ),
          ),
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(Icons.my_location),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 1,
              child: TextFormField(
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_locationFocusNode);
                },
                keyboardType: TextInputType.number,
                maxLength: 1,
                validator: isEmptyValidation,
                focusNode: _stateFocusNode,
                decoration: InputDecoration(
                  labelText: 'State',
                  hintText: '0',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
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
                  hintText: 'Kathmandu',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                maxLines: 1,
                controller: _locationController,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _registerButton(SignUpViewModel model, BuildContext context) {
    return AnimatedSwitcher(
      transitionBuilder: (Widget child, Animation<double> animation) =>
          ScaleTransition(child: child, scale: animation),
      duration: Duration(milliseconds: 250),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: model.busy
            ? CircularProgressIndicator()
            : Container(
                width: MediaQuery.of(context).size.width / 1.5,
                margin: EdgeInsets.all(16.0),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32)),
                  padding: EdgeInsets.all(22.0),
                  child: Text(
                    'Register',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                  onPressed: () async {
                    if (validateForm()) {
                      formKey.currentState.save();
                      var response = await model.register(
                          selectedGender,
                          _nameController.text.split(" ")[0],
                          _nameController.text.split(" ").length > 1
                              ? _nameController.text.split(" ")[1]
                              : '',
                          DateFormat("yyyy-MM-d").format(
                              DateFormat('MMM d, yyyy')
                                  .parse(_dateController.text)),
                          DateFormat("HH:mm").format(DateFormat("hh:mm a")
                              .parse(_timeController.text)),
                          _timeAccurate,
                          _country,
                          _locationController.text,
                          _emailController.text,
                          _passwordController.text,
                          _phoneController.text,
                          _stateController.text,
                          fcmToken);
                      if (response.errorMessage == null) {
                        Navigator.pushReplacementNamed(
                            context, RoutePaths.home);
                      } else {
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text(response.errorMessage),
                        ));
                      }
                    }
                  },
                  color: Theme.of(context).primaryColor,
                ),
              ),
      ),
    );
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
    _phoneController = TextEditingController();
    _stateController = TextEditingController();
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
      _dateController.text = DateFormat.yMMMd()
          .format(DateFormat("yyyy-MM-d").parse(user.dateOfBirth));
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
