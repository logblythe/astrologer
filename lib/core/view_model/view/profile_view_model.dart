import 'package:astrologer/core/data_model/image_model.dart';
import 'package:astrologer/core/data_model/user_model.dart';
import 'package:astrologer/core/service/profile_service.dart';
import 'package:astrologer/core/view_model/base_view_model.dart';

class ProfileViewModel extends BaseViewModel {
  final ProfileService _profileService;

//  String _imageUrl;

  ProfileViewModel({ProfileService profileService})
      : this._profileService = profileService;

  UserModel get user => _profileService.user;

//  get imageUrl => _imageUrl;

  getLoggedInUser() async {
    setBusy(true);
    await _profileService.getLoggedInUser();
    setBusy(false);
  }

  Future<int> updateUser(UserModel user) async {
    setBusy(true);
    var result = await _profileService.updateUser(user);
    setBusy(false);
    return result;
  }

  Future<ImageModel> upload(imageFile) async {
    setBusy(true);
    await _profileService.upload(imageFile);
    setBusy(false);
  }

/*getImageUrl() async {
    setBusy(true);
    _imageUrl = await _profileService.imageUrl();
    setBusy(false);
  }*/
}
