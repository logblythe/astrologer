import 'package:astrologer/core/data_model/image_model.dart';
import 'package:astrologer/core/data_model/user_model.dart';
import 'package:astrologer/core/enum/gender.dart';
import 'package:astrologer/core/service/profile_service.dart';
import 'package:astrologer/core/view_model/base_view_model.dart';

class ProfileViewModel extends BaseViewModel {
  final ProfileService _profileService;
  bool accurateTime = false;
  Gender selectedGender;

  handleSwitch(value) => accurateTime = value;

  handleGenderSelection(gender) => selectedGender = gender;

//  String _imageUrl;

  ProfileViewModel({ProfileService profileService})
      : this._profileService = profileService;

  UserModel get user => _profileService.user;

//  get imageUrl => _imageUrl;

  getLoggedInUser() async {
    setBusy(true);
    UserModel user = await _profileService.getLoggedInUser();
    accurateTime = user.accurateTime;
    selectedGender = user.gender == "M" ? Gender.male : Gender.female;
    setBusy(false);
  }

  Future<UserModel> updateUser(UserModel user) async {
    setBusy(true);
    var userModel = await _profileService.updateUser(user);
    setBusy(false);
    return userModel;
  }

  upload(imageFile) async {
    setUploadingImage(true);
    await _profileService.upload(imageFile);
    setUploadingImage(false);
  }

/*getImageUrl() async {
    setBusy(true);
    _imageUrl = await _profileService.imageUrl();
    setBusy(false);
  }*/
}
