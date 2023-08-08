class AlbumModel {
  final String id;
  final String? name;
  final int total;
  final String? thumbnailURL;
  AlbumModel({
    required this.id,
    this.name,
    this.total = 0,
    this.thumbnailURL,
  });
}
