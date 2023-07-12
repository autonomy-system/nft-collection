import 'package:floor_annotation/floor_annotation.dart';

@entity
class AddressCollection {
  @primaryKey
  final String address;
  final DateTime lastRefreshedTime;
  final bool isHidden;

  AddressCollection({
    required this.address,
    required this.lastRefreshedTime,
    this.isHidden = false
  });

  // to json
  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'lastRefreshedTime': lastRefreshedTime.millisecondsSinceEpoch,
      'isHidden': isHidden
    };
  }
}
