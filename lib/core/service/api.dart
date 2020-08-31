import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:astrologer/core/constants/end_points.dart';
import 'package:astrologer/core/data_model/astrologer_model.dart';
import 'package:astrologer/core/data_model/image_model.dart';
import 'package:astrologer/core/data_model/login_response.dart';
import 'package:astrologer/core/data_model/response.dart';
import 'package:astrologer/core/data_model/user_model.dart';
import 'package:astrologer/core/utils/shared_pref_helper.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  var client = http.Client();
  String token;

  Future<String> get getToken async {
    var sharedPref = await SharedPreferences.getInstance();
    return sharedPref.getString(KEY_TOKEN);
  }

  Future<UserModel> registerUser(UserModel user) async {
    try {
      print('Registration response ${jsonEncode(user.toMapForDb())}');
      var response = await client.post(register,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(user.toMapForDb()));
      print('Registration response $response');
      print('Registration response ${jsonDecode(response.body)}');
      switch (response.statusCode) {
        case 200:
          print('case 200');
          return UserModel.fromJson(jsonDecode(response.body));
        case 409:
          print('case 409');
          return UserModel.fromError(jsonDecode(response.body));
        default:
          return UserModel.error(
              error: "Something went wrong. Please try again");
      }
    } catch (e) {
      print('we are here');
      return UserModel.error(error: e.toString());
    }
  }

  Future<UserModel> updateProfile(UserModel user) async {
    /*  _alice = Alice(
        showNotification: true,
        showInspectorOnShake: true,
        darkTheme: false,
        navigatorKey: navigatorKey);*/
    try {
      var token = await getToken;
      var response = await client.post(UPDATE,
          headers: {
            "Content-Type": "application/json",
            HttpHeaders.authorizationHeader: "Bearer $token"
          },
          body: jsonEncode(user.toMapForDb()));
//      _alice.onHttpResponse(response, body: jsonEncode(user.toMapForDb()));
      print('Update profile response $response');
      print('Update profile response ${jsonDecode(response.body)}');
      switch (response.statusCode) {
        case 200:
          print('case 200');
          return UserModel.fromJson(jsonDecode(response.body));
        case 403:
          print('case 403');
          var result = UserModel.fromError(jsonDecode(response.body));
          return result;
        case 409:
          print('case 409');
          return UserModel.fromError(jsonDecode(response.body));
        default:
          return UserModel.error(
              error: "Something went wrong. Please try again");
      }
    } catch (e) {
      print('error during update profile ${e.toString()}');
      return UserModel.error(error: e.toString());
    }
  }

  Future<LoginResponse> performLogin(String email, String password,
      String fcmToken) async {
    print(login);
    try {
      var response = await client.post(
        login,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
          {
            'email': email,
            'password': password,
            'deviceToken': fcmToken,
          },
        ),
      );
      print('LOGIN RESPONSE ${response.statusCode}${response.body}');
      return LoginResponse.fromJsonMap(jsonDecode(response.body));
    } on SocketException catch (e) {
      return LoginResponse.withError(e.message);
    }
  }

  Future<Map<String, dynamic>> askQuestion(int userId, String question,
      double questionPrice,
      {int prevQuestionId}) async {
    try {
      var token = await getToken;
      var response = await client.post(
        askQuestionUrl,
        headers: {
          "Content-Type": "application/json",
          HttpHeaders.authorizationHeader: "Bearer $token"
        },
        body: jsonEncode(
          {
            'engQuestion': question,
            'userId': userId,
            'prevQuestionId': prevQuestionId,
            'questionPrice': questionPrice,
          },
        ),
      );
      print('the ask question response ${response.statusCode}${response.body}');
      return jsonDecode(response.body);
    } catch (e) {
      print('ASK QUESTION the response exception $e}');
      return null;
    }
  }

  fetchAstrologers() async {
    try {
      var token = await getToken;
      var response = await client.get(
        fetchAstrologersUrl,
        headers: {
          "Content-Type": "application/json",
          HttpHeaders.authorizationHeader: "Bearer $token"
        },
      );
      print('response fetchAstrologers ${response.statusCode}${response.body}');
      List<dynamic> astrologers = jsonDecode(response.body);
      return astrologers.map((json) => AstrologerModel.fromJson(json)).toList();
    } catch (e) {
      print('FETCH ASTROLOGER the response exception $e}');
//      return AstrologerModel.withError(e.toString());
      return null;
    }
  }

  Future<Map<String, dynamic>> fetchQuestionPrice() async {
    try {
      var token = await getToken;
      var response = await client.get(
        fetchQuestionPriceUrl,
        headers: {
          "Content-Type": "application/json",
          HttpHeaders.authorizationHeader: "Bearer $token"
        },
      );
      print(
          'response fetch question price ${response.statusCode} \n ${response
              .body}');
      return jsonDecode(response.body);
    } catch (e) {
      print('FETCHQUESTION PRICE the response exception $e}');
      return null;
    }
  }

  Future<ImageModel> upload(File imageFile) async {
    var token = await getToken;
    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Bearer $token"
    };

    // open a bytestream
    var stream =
    new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    // get file length
    var length = await imageFile.length();

    // string to uri
    var uri = Uri.parse(uploadProfile);

    // multipart that takes file
    var multipartFile = new http.MultipartFile('image', stream, length,
        filename: basename(imageFile.path));

    // create multipart request
    var request = new http.MultipartRequest("POST", uri);
    request.headers.addAll(headers);

    // add file to multipart
    request.files.add(multipartFile);

    // send
    var response = await request.send();
    var contents = new StringBuffer();
    var completer = new Completer<ImageModel>();
    // listen for response
    response.stream.transform(utf8.decoder).listen(
          (value) {
        contents.write(value);
      },
      onDone: () {
        var jsonData = json.decode(contents.toString());
        completer.complete(ImageModel.fromJson(jsonData));
      },
    );
    return completer.future;
  }

  requestOTP(String email) async {
    try {
      var response = await client.post(
        '$baseUrl/reset-password?email=$email',
        headers: {
          "Content-Type": "application/json",
        },
      );
      return Response.fromJson(jsonDecode(response.body));
    } catch (e) {
      print('FETCH otp the response exception $e}');
//      return AstrologerModel.withError(e.toString());
      return null;
    }
  }

  validateOtp(String otp) async {
    try {
      var response = await client.post(
          '$baseUrl/validate-otp',
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "token": otp
          })
      );
      return Response.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception(['Something went wrong']);
    }
  }

  savePassword(String otp, String password) async {
    try {
      var response = await client.post(
          '$baseUrl/save-password',
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "token": otp,
            "newPassword": password
          })
      );
      return Response.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception(['Something went wrong']);
    }
  }

  changePassword(Map<String, String> map) async {
    var token = await getToken;
    try {
      var response = await client.post(
          '$baseUrl/change-password',
          headers: {
            "Content-Type": "application/json",
            HttpHeaders.authorizationHeader: "Bearer $token"
          },
          body: jsonEncode(map)
      );
      return Response.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw Exception(['Something went wrong']);
    }
  }

}
