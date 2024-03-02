import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static final Preferences _singleton = Preferences._internal();
  SharedPreferences? _prefs;
  factory Preferences() {
    return _singleton;
  }

  Preferences._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const String _email = 'email';
  static const String _username = 'username';
  static const String _profilPicture = 'profile_picture';
  static const String _deviceToken = 'device_token';
  Future<void> setDeviceToken(String devicetoken) async {
    await _prefs!.setString(_deviceToken, devicetoken);
  }

  Future<String?> getDeviceToken() async {
    return _prefs!.getString(_deviceToken);
  }

  Future<void> setEmail(String email) async {
    await _prefs!.setString(_email, email);
  }

  Future<String?> getEmail() async {
    return _prefs!.getString(_email);
  }

  Future<void> setName(String name) async {
    await _prefs!.setString(_username, name);
  }

  Future<String?> getName() async {
    return _prefs!.getString(_username);
  }

  Future<void> setProfilePicture(String picture) async {
    await _prefs!.setString(_profilPicture, picture);
  }

  Future<String?> getProfilePhoto() async {
    return _prefs!.getString(_profilPicture);
  }

  Future<void> clear() async {
    await _prefs!.clear();
  }
}
