import 'package:astrologer/core/data_model/user_model.dart';
import 'package:astrologer/core/service/profile_service.dart';
import 'package:astrologer/core/view_model/base_view_model.dart';

class ProfileViewModel extends BaseViewModel {
  final ProfileService _profileService;

  ProfileViewModel({ProfileService profileService})
      : this._profileService = profileService;

  UserModel get user => _profileService.user;

  getLoggedInUser() async {
    print('we are here');
    setBusy(true);
    UserModel user = await _profileService.getLoggedInUser();
    print('user details ${user.toString()}');
    setBusy(false);
  }

  Future<int> updateUser(UserModel user) async {
    setBusy(true);
    var result = await _profileService.updateUser(user);
    setBusy(false);
    return result;
  }
}
