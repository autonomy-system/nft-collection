import 'package:floor/floor.dart';
import 'package:nft_collection/models/token_owner.dart';

@dao
abstract class TokenOwnerDao {
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertTokenOwners(List<TokenOwner> owners);
}