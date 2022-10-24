//
//  SPDX-License-Identifier: BSD-2-Clause-Patent
//  Copyright © 2022 Bitmark. All rights reserved.
//  Use of this source code is governed by the BSD-2-Clause Plus Patent License
//  that can be found in the LICENSE file.
//

import 'package:floor/floor.dart';
import 'package:nft_collection/models/asset_token.dart';
import 'package:nft_collection/models/provenance.dart';
import 'package:nft_collection/models/token_owner.dart';

@dao
abstract class AssetTokenDao {
  @Query(
      'SELECT * FROM AssetToken ORDER BY lastActivityTime DESC, title, assetID')
  Future<List<AssetToken>> findAllAssetTokens();

  @Query('SELECT DISTINCT t.*, o.updateTime AS updateTime FROM AssetToken t INNER JOIN TokenOwner o'
      ' ON t.id = o.indexerId'
      ' WHERE o.owner IN (:owners)'
      ' ORDER BY lastActivityTime DESC, title, assetID')
  Future<List<AssetToken>> findAllAssetTokensByOwners(List<String> owners);

  @Query(
      'SELECT * FROM AssetToken WHERE blockchain = :blockchain')
  Future<List<AssetToken>> findAssetTokensByBlockchain(String blockchain);

  @Query('SELECT * FROM AssetToken WHERE id = :id')
  Future<AssetToken?> findAssetTokenById(String id);

  @Query('SELECT * FROM AssetToken WHERE id IN (:ids)')
  Future<List<AssetToken>> findAllAssetTokensByIds(List<String> ids);

  @Query('SELECT id FROM AssetToken')
  Future<List<String>> findAllAssetTokenIDs();

  @Query('SELECT t.id FROM AssetToken t INNER JOIN TokenOwner o'
      ' ON t.id=o.indexerId WHERE o.owner=:owner')
  Future<List<String>> findAllAssetTokenIDsByOwner(String owner);

  @Query('SELECT DISTINCT artistID FROM AssetToken')
  Future<List<String>> findAllAssetArtistIDs();

  @Query('SELECT * FROM AssetToken WHERE pending = 1')
  Future<List<AssetToken>> findAllPendingTokens();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAsset(AssetToken asset);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAssets(List<AssetToken> assets);

  @update
  Future<void> updateAsset(AssetToken asset);

  @delete
  Future<void> deleteAsset(AssetToken asset);

  @Query('DELETE FROM AssetToken WHERE id IN (:ids)')
  Future<void> deleteAssets(List<String> ids);

  @Query('DELETE FROM AssetToken WHERE id NOT IN (:ids)')
  Future<void> deleteAssetsNotIn(List<String> ids);

  @Query('DELETE FROM AssetToken'
      ' WHERE id NOT IN'
      ' (SELECT DISTINCT t.id FROM AssetToken t INNER JOIN TokenOwner o'
      ' ON t.id=o.indexerId WHERE o.owner IN (:owners))')
  Future<void> deleteAssetsNotBelongs(List<String> owners);

  @Query('DELETE FROM AssetToken')
  Future<void> removeAll();

  @Query('DELETE FROM AssetToken WHERE pending=0')
  Future<void> removeAllExcludePending();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertTokenOwners(List<TokenOwner> owners);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertProvenance(List<Provenance> provenance);

  @transaction
  Future insertAssetTokens(
    List<AssetToken> assets,
    List<TokenOwner> owners,
    List<Provenance> provenances,
  ) async {
    await insertAssets(assets);
    await insertTokenOwners(owners);
    await insertProvenance(provenances);
  }
}

/** MARK: - Important!
 *** Because of limitation of Floor, please override this in auto-generated app_database.g.dart

    @override
    Future<List<String>> findAllAssetTokenIDs() async {
    return _queryAdapter.queryList('SELECT id FROM AssetToken',
    mapper: (Map<String, Object?> row) => row['id'] as String);
    }
 */
