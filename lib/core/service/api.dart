import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:astrologer/core/data_model/image_model.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';

import 'package:astrologer/core/constants/end_points.dart';
import 'package:astrologer/core/data_model/astrologer_model.dart';
import 'package:astrologer/core/enum/gender.dart';
import 'package:astrologer/core/data_model/login_response.dart';
import 'package:astrologer/core/data_model/user_model.dart';
import 'package:astrologer/core/utils/shared_pref_helper.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  var client = http.Client();
  String token;

  Future<String> get getToken async {
    var sharedPref = await SharedPreferences.getInstance();
    return sharedPref.getString(KEY_TOKEN);
  }

  Future<UserModel> registerUser(
      Gender gender,
      String name,
      String lname,
      String email,
      String password,
      String phone,
      String location,
      String state,
      String country,
      String dob,
      String time,
      bool timeAccurate) async {
    try {
      var response = await client.post(
        register,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "firstName": name,
          "lastName": lname,
          "email": email,
          "password": password,
          "phoneNumber": phone,
          "gender": (gender == Gender.male) ? MALE : FEMALE,
          "city": location,
          "state": state,
          "country": country,
          "dateOfBirth": dob,
          "birthTime": time,
          "accurateTime": timeAccurate,
        }),
      );
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

  Future<LoginResponse> performLogin(
      String email, String password, String fcmToken) async {
    print(login);
    try {
      var response = await client.post(
        login,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
          {'email': email, 'password': password, 'deviceToken': fcmToken},
        ),
      );
      print('LOGIN RESPONSE ${response.statusCode}${response.body}');
      return LoginResponse().fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      return LoginResponse.withError(e.message);
    }
  }

  Future<Map<String, dynamic>> askQuestion(
      int userId, String question, double questionPrice,
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
      print('the response exception $e}');
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
      print('the response exception $e}');
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
          'response fetch question price ${response.statusCode} \n ${response.body}');
      return jsonDecode(response.body);
    } catch (e) {
      print('the response exception $e}');
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
    print(response.statusCode);

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
}
