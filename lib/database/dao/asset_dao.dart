//
//  SPDX-License-Identifier: BSD-2-Clause-Patent
//  Copyright © 2022 Bitmark. All rights reserved.
//  Use of this source code is governed by the BSD-2-Clause Plus Patent License
//  that can be found in the LICENSE file.
//

import 'package:floor/floor.dart';
import 'package:nft_collection/models/asset.dart';

@dao
abstract class AssetDao {
  @Query('SELECT * FROM Asset')
  Future<List<Asset>> findAllAssets();

  @Query('SELECT * FROM Asset WHERE assetID IN (:ids)')
  Future<List<Asset>> findAllAssetsByIds(List<String> ids);

  @Query('SELECT assetID FROM Asset')
  Future<List<String>> findAllAssetIDs();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAsset(Asset token);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAssets(List<Asset> assets);

  @update
  Future<void> updateAsset(Asset asset);

  @delete
  Future<void> deleteAsset(Asset asset);

  @Query('DELETE FROM Asset WHERE assetID IN (:ids)')
  Future<void> deleteAssets(List<String> ids);

  @Query('DELETE FROM Asset WHERE assetID = (:id)')
  Future<void> deleteAssetByID(String id);

  @Query('DELETE FROM Asset WHERE assetID NOT IN (:ids)')
  Future<void> deleteAssetsNotIn(List<String> ids);

  @Query('DELETE FROM Asset')
  Future<void> removeAll();
}
