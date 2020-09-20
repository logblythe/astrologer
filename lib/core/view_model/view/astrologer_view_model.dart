import 'package:astrologer/core/data_model/astrologer_model.dart';
import 'package:astrologer/core/service/home_service.dart';
import 'package:astrologer/core/service/user_service.dart';
import 'package:astrologer/core/view_model/base_view_model.dart';

class AstrologerViewModel extends BaseViewModel {
  final HomeService _homeService;
  final UserService _userService;

  AstrologerViewModel({HomeService homeService, UserService userService})
      : this._homeService = homeService,
        this._userService = userService;

  List<AstrologerModel> get astrologers => _homeService.astrologers;

  fetchAstrologers() async {
    setBusy(true);
    await _homeService.fetchAstrologers();
    print('astrologer fetched after');
    setBusy(false);
  }
}
