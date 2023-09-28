class AlbumModel {
  String id;
  String? name;
  int total;
  String? thumbnailURL;
  AlbumModel({
    required this.id,
    this.name,
    this.total = 0,
    this.thumbnailURL,
  });
}
