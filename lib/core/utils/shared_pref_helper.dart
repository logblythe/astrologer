import 'package:shared_preferences/shared_preferences.dart';

const String KEY_USER_ID = "key_user_id";
const String KEY_TOKEN = "key_token";
const String KEY_FREE_QUES_COUNT = "key_free_question_count";

class SharedPrefHelper {
  SharedPreferences _sharedPreferences;

  Future<SharedPreferences> get sharedPreferences async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }
    return _sharedPreferences;
  }

  setString(String key, String value) async {
    var sharedPref = await sharedPreferences;
    sharedPref.setString(key, value);
  }

  setInt(String key, int value) async {
    var sharedPref = await sharedPreferences;
    sharedPref.setInt(key, value);
  }

  getInteger(String key) async {
    var sharedPref = await sharedPreferences;
    return sharedPref.getInt(key);
  }
}
