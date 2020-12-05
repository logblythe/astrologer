import 'package:astrologer/core/data_model/user_model.dart';
import 'package:astrologer/core/enum/gender.dart';
import 'package:astrologer/core/service/profile_service.dart';
import 'package:astrologer/core/service/user_service.dart';
import 'package:astrologer/core/view_model/base_view_model.dart';

class ProfileViewModel extends BaseViewModel {
  final ProfileService _profileService;
  final UserService _userService;
  bool accurateTime = false;
  Gender selectedGender;

  handleSwitch(value) => accurateTime = value;

  handleGenderSelection(gender) => selectedGender = gender;

  String _imageUrl;

  ProfileViewModel({ProfileService profileService, UserService userService})
      : this._profileService = profileService,
        this._userService = userService;

  UserModel get user => _profileService.user;

  get imageUrl => _imageUrl;

  getLoggedInUser() async {
    setBusy(true);
    UserModel user = await _profileService.getLoggedInUser();
    accurateTime = user?.accurateTime;
    selectedGender = user?.gender == "M" ? Gender.male : Gender.female;
    setBusy(false);
  }

  Future<UserModel> updateUser(UserModel user) async {
    setBusy(true);
    var userModel = await _profileService.updateUser(user);
    _userService.user = user;
    setBusy(false);
    return userModel;
  }

  upload(imageFile) async {
    setUploadingImage(true);
    await _profileService.upload(imageFile);
    setUploadingImage(false);
  }

  getImageUrl() async {
    _imageUrl = await _profileService.getImageUrl();
  }
}
