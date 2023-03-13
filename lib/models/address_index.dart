// ignore_for_file: public_member_api_docs, sort_constructors_first
class AddressIndex {
  String address;
  DateTime createdAt;
  AddressIndex({
    required this.address,
    required this.createdAt,
  });

  @override
  bool operator ==(covariant AddressIndex other) {
    if (identical(this, other)) return true;

    return other.address == address && other.createdAt == createdAt;
  }

  @override
  int get hashCode => address.hashCode ^ createdAt.hashCode;

  @override
  String toString() => 'AddressIndex(address: $address, createdAt: $createdAt)';
}
