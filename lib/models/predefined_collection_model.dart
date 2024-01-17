class PredefinedCollectionModel {
  String id;
  String? name;
  int total;
  String? thumbnailURL;
  PredefinedCollectionModel({
    required this.id,
    this.name,
    this.total = 0,
    this.thumbnailURL,
  });
}
