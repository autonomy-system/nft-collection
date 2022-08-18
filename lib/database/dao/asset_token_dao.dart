//
//  SPDX-License-Identifier: BSD-2-Clause-Patent
//  Copyright © 2022 Bitmark. All rights reserved.
//  Use of this source code is governed by the BSD-2-Clause Plus Patent License
//  that can be found in the LICENSE file.
//

import 'package:floor/floor.dart';
import 'package:nft_collection/models/asset_token.dart';

@dao
abstract class AssetTokenDao {
  @Query(
      'SELECT * FROM AssetToken ORDER BY lastActivityTime DESC, title, assetID')
  Future<List<AssetToken>> findAllAssetTokens();

  @Query(
      'SELECT * FROM AssetToken WHERE ownerAddress NOT IN (:owners) ORDER BY lastActivityTime DESC, title, assetID')
  Future<List<AssetToken>> findAllAssetTokensWhereNot(List<String> owners);

  @Query(
      'SELECT * FROM AssetToken WHERE blockchain = :blockchain')
  Future<List<AssetToken>> findAssetTokensByBlockchain(String blockchain);

  @Query('SELECT * FROM AssetToken WHERE id = :id')
  Future<AssetToken?> findAssetTokenById(String id);

  @Query('SELECT id FROM AssetToken')
  Future<List<String>> findAllAssetTokenIDs();

  @Query('SELECT DISTINCT artistID FROM AssetToken')
  Future<List<String>> findAllAssetArtistIDs();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAsset(AssetToken asset);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAssets(List<AssetToken> assets);

  @update
  Future<void> updateAsset(AssetToken asset);

  @delete
  Future<void> deleteAsset(AssetToken asset);

  @Query('DELETE FROM AssetToken WHERE id NOT IN (:ids)')
  Future<void> deleteAssetsNotIn(List<String> ids);

  @Query('DELETE FROM AssetToken WHERE ownerAddress NOT IN (:owners)')
  Future<void> deleteAssetsNotBelongs(List<String> owners);

  @Query('DELETE FROM AssetToken')
  Future<void> removeAll();
}

/** MARK: - Important!
 *** Because of limitation of Floor, please override this in auto-generated app_database.g.dart

    @override
    Future<List<String>> findAllAssetTokenIDs() async {
    return _queryAdapter.queryList('SELECT id FROM AssetToken',
    mapper: (Map<String, Object?> row) => row['id'] as String);
    }
 */
