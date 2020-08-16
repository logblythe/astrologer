import 'package:astrologer/core/data_model/user_model.dart';
import 'package:astrologer/core/enum/gender.dart';
import 'package:astrologer/core/validator_mixin.dart';
import 'package:astrologer/core/view_model/view/profile_view_model.dart';
import 'package:astrologer/ui/base_widget.dart';
import 'package:astrologer/ui/shared/ui_helpers.dart';
import 'package:astrologer/ui/widgets/accurate_time_switch.dart';
import 'package:astrologer/ui/widgets/circular_image.dart';
import 'package:astrologer/ui/widgets/date_time_row.dart';
import 'package:astrologer/ui/widgets/gender_selection.dart';
import 'package:astrologer/ui/widgets/state_city_row.dart';
import 'package:astrologer/ui/widgets/text_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileDialog extends StatelessWidget with ValidationMixing {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode locationFocusNode = FocusNode();
  final FocusNode dateFocusNode = FocusNode();
  final FocusNode timeFocusNode = FocusNode();
  final FocusNode stateFocusNode = FocusNode();
  final FocusNode countryFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: BaseWidget<ProfileViewModel>(
        model: ProfileViewModel(profileService: Provider.of(context)),
        onModelReady: (model) async {
          await model.getLoggedInUser();
          await model.getImageUrl();
          initializeValue(model);
        },
        builder: (ctx, model, _) {
          return Form(
            key: formKey,
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      UIHelper.verticalSpaceMedium,
                      Center(
                        child: CircularImage(
                          imageUrl: Provider.of<String>(context),
                          onImageCaptured: model.upload,
                          busy: model.uploadingImage,
                        ),
                      ),
                      UIHelper.verticalSpaceMedium,
                      GenderSelection(
                        updateGender: model.handleGenderSelection,
                        selectedGender: model.selectedGender,
                      ),
                      UIHelper.verticalSpaceMedium,
                      TextInput(
                        title: "FULL NAME",
                        prefixIcon: Icon(Icons.person),
                        controller: nameController,
                        validator: isEmptyValidation,
                      ),
                      UIHelper.verticalSpaceMedium,
                      TextInput(
                        title: "PHONE",
                        prefixIcon: Icon(Icons.phone_android),
                        controller: phoneController,
                        validator: isEmptyValidation,
                        keyboardType: TextInputType.number,
                      ),
                      UIHelper.verticalSpaceMedium,
                      DateTimeRow(
                        dateController: dateController,
                        timeController: timeController,
                        dateFocusNode: dateFocusNode,
                        timeFocusNode: timeFocusNode,
                      ),
                      UIHelper.verticalSpaceSmall,
                      AccurateTimeSwitch(
                        onSwitch: model.handleSwitch,
                        value: model.accurateTime,
                      ),
                      UIHelper.verticalSpaceSmall,
                      TextInput(
                        title: "Country",
                        prefixIcon: Icon(Icons.local_airport),
                        controller: countryController,
                        validator: isEmptyValidation,
                      ),
                      UIHelper.verticalSpaceMedium,
                      StateCityRow(
                        locationController: locationController,
                        stateController: stateController,
                        locationFocusNode: locationFocusNode,
                        stateFocusNode: stateFocusNode,
                      ),
                      UIHelper.verticalSpaceMedium,
                      Align(
                        alignment: Alignment.bottomRight,
                        child: _registerButton(
                          model,
                          ctx,
                          handleUpdateClick,
                        ),
                      ),
                      UIHelper.verticalSpaceMedium,
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _registerButton(
    ProfileViewModel model,
    BuildContext context,
    Function handleUpdateClick,
  ) {
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
              onPressed: () => handleUpdateClick(model, context),
              color: Theme.of(context).primaryColor,
            ),
    );
  }

  handleUpdateClick(ProfileViewModel model, BuildContext context) async {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      UserModel user = UserModel();
      user.firstName = nameController.text.split(" ").elementAt(0);
      user.lastName = nameController.text.split(" ").elementAt(1) ?? "";
      user.phoneNumber = phoneController.text;
      user.city = locationController.text;
      user.state = stateController.text;
      user.country = countryController.text;
      user.dateOfBirth = dateController.text;
      user.birthTime = timeController.text;
      user.accurateTime = model.accurateTime;
      user.gender = model.selectedGender == null
          ? null
          : model.selectedGender == Gender.male ? "M" : "F";
      UserModel response = await model.updateUser(user);
      if (response.errorMessage != null) {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(response.errorMessage),
          ),
        );
      } else {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated successfully'),
          ),
        );
      }
    }
  }

  void initializeValue(ProfileViewModel model) {
    UserModel user = model.user;
    nameController.text = "${user.firstName} ${user.lastName}";
    locationController.text = user.city;
    dateController.text = user.dateOfBirth;
    timeController.text = user.birthTime;
    stateController.text = user.state;
    countryController.text = user.country;
    phoneController.text = user.phoneNumber;
  }
}
