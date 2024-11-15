import 'package:nft_collection/models/user_collection.dart';

class QueryListCollectionResponse {
  QueryListCollectionResponse({
    required this.collections,
  });

  final List<UserCollection> collections;

  factory QueryListCollectionResponse.fromJson(Map<String, dynamic> json) =>
      QueryListCollectionResponse(
        collections: List<UserCollection>.from(
            json['collections'].map((x) => UserCollection.fromJson(x))),
      );
}
