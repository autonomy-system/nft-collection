import 'package:shared_preferences/shared_preferences.dart';

class NftCollectionPrefs {
  static const _keyLastRefreshTokenTime = "last_refresh_at";
  static const _keyPendingAddresses = "pending_addresses";

  final SharedPreferences _prefs;

  NftCollectionPrefs(this._prefs);

  Future<bool> setLatestRefreshTokens(DateTime? time) async {
    if (time != null) {
      return _prefs.setInt(
          _keyLastRefreshTokenTime, time.millisecondsSinceEpoch ~/ 1000);
    } else {
      return _prefs.remove(_keyLastRefreshTokenTime);
    }
  }

  DateTime? getLatestRefreshTokens() {
    final timestamp = _prefs.getInt(_keyLastRefreshTokenTime);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    } else {
      return null;
    }
  }

  Future<bool> setPendingAddresses(List<String>? addresses) async {
    if (addresses != null) {
      addresses = addresses.toSet().toList();
      return _prefs.setStringList(_keyPendingAddresses, addresses);
    } else {
      return _prefs.remove(_keyPendingAddresses);
    }
  }

  List<String>? getPendingAddresses() {
    return _prefs.getStringList(_keyPendingAddresses);
  }

  Future<bool> removePendingAddresses(List<String> list) async {
    List<String> addresses = _prefs.getStringList(_keyPendingAddresses) ?? [];
    addresses = addresses.toSet().difference(list.toSet()).toList();
    return setPendingAddresses(addresses);
  }

  Future<bool> addPendingAddresses(List<String> list) async {
    final addresses = _prefs.getStringList(_keyPendingAddresses) ?? [];
    addresses.addAll(list);
    return setPendingAddresses(addresses);
  }
}
