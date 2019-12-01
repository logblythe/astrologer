import 'package:astrologer/core/constants/what_to_ask.dart';
import 'package:astrologer/core/data_model/idea_model.dart';
import 'package:astrologer/core/service/home_service.dart';
import 'package:astrologer/core/view_model/base_view_model.dart';
import 'package:flutter/cupertino.dart';

class IdeaViewModel extends BaseViewModel {
  HomeService _homeService;

  IdeaViewModel({@required HomeService homeService})
      : _homeService = homeService;

  List<IdeaModel> get ideas => ideaModelList;

  addMessageToSink(String message) {
    _homeService.addMsgToSink(message, true);
  }

  @override
  void dispose() {
    super.dispose();
    _homeService.dispose();
  }

}
