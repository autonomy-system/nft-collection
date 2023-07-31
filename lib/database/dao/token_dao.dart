//
//  SPDX-License-Identifier: BSD-2-Clause-Patent
//  Copyright © 2022 Bitmark. All rights reserved.
//  Use of this source code is governed by the BSD-2-Clause Plus Patent License
//  that can be found in the LICENSE file.
//

import 'package:floor/floor.dart';
import 'package:nft_collection/models/token.dart';

@dao
abstract class TokenDao {
  @Query('SELECT id FROM Token')
  Future<List<String>> findAllTokenIDs();

  @Query('SELECT id FROM Token where owner IN (:owners)')
  Future<List<String>> findTokenIDsByOwners(List<String> owners);

  @Query('SELECT * FROM Token WHERE pending = 1')
  Future<List<Token>> findAllPendingTokens();

  @Query('SELECT * FROM Token WHERE id = (:id)')
  Future<List<Token>> findTokensByID(String id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertToken(Token token);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertTokens(List<Token> assets);

  @Insert(onConflict: OnConflictStrategy.ignore)
  Future<void> insertTokensAbort(List<Token> assets);

  @update
  Future<void> updateToken(Token asset);

  @delete
  Future<void> deleteToken(Token asset);

  @Query('DELETE FROM Token WHERE id IN (:ids)')
  Future<void> deleteTokens(List<String> ids);

  @Query('DELETE FROM Token WHERE id = (:id)')
  Future<void> deleteTokenByID(String id);

  @Query('DELETE FROM Token WHERE id NOT IN (:ids)')
  Future<void> deleteTokensNotIn(List<String> ids);

  @Query('DELETE FROM Token WHERE id NOT IN (:ids) AND owner=:owner')
  Future<void> deleteTokensNotInByOwner(List<String> ids, String owner);

  @Query('DELETE FROM Token WHERE owner NOT IN (:owners)')
  Future<void> deleteTokensNotBelongs(List<String> owners);

  @Query('DELETE FROM Token')
  Future<void> removeAll();

  @Query('DELETE FROM Token WHERE pending=0')
  Future<void> removeAllExcludePending();
}

/** MARK: - Important!
 *** Because of limitation of Floor, please override this in auto-generated app_database.g.dart

    @override
    Future<List<String>> findAllTokenIDs() async {
    return _queryAdapter.queryList('SELECT id FROM Token',
    mapper: (Map<String, Object?> row) => row['id'] as String);
    }
 */
