import 'package:shared_preferences/shared_preferences.dart';

class NftCollectionPrefs {
  static const _keyLastRefreshTokenTime = "last_refresh_token_time";

  final SharedPreferences _prefs;

  NftCollectionPrefs(this._prefs);

  Future<bool> setLatestRefreshTokens(DateTime? time) async {
    if (time != null) {
      return _prefs.setInt(
          _keyLastRefreshTokenTime, time.millisecondsSinceEpoch);
    } else {
      return _prefs.remove(_keyLastRefreshTokenTime);
    }
  }

  Future<DateTime?> getLatestRefreshTokens() async {
    final timestamp = _prefs.getInt(_keyLastRefreshTokenTime);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else {
      return null;
    }
  }
}
