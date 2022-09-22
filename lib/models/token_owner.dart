import 'package:floor_annotation/floor_annotation.dart';
import 'package:nft_collection/models/asset_token.dart';

@Entity(primaryKeys: [
  "indexerId",
  "owner"
], foreignKeys: [
  ForeignKey(
    childColumns: ['indexerId'],
    parentColumns: ['id'],
    entity: AssetToken,
    onDelete: ForeignKeyAction.cascade,
  )
])
class TokenOwner {
  final String indexerId;
  final String owner;
  final int quantity;
  final DateTime? updateTime;

  TokenOwner(
    this.indexerId,
    this.owner,
    this.quantity,
    this.updateTime,
  );
}
