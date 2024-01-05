//
//  SPDX-License-Identifier: BSD-2-Clause-Patent
//  Copyright © 2022 Bitmark. All rights reserved.
//  Use of this source code is governed by the BSD-2-Clause Plus Patent License
//  that can be found in the LICENSE file.
//

import 'package:dio/dio.dart';
import 'package:nft_collection/models/asset_token.dart';
import 'package:retrofit/retrofit.dart';

part 'indexer_api.g.dart';

@RestApi(baseUrl: "")
abstract class IndexerApi {
  factory IndexerApi(Dio dio, {String baseUrl}) = _IndexerApi;

  @POST("/v2/nft/query")
  Future<List<AssetToken>> getNFTTokens(
    @Query("offset") int offset,
  );

  @POST("/v2/nft/index")
  Future requestIndex(@Body() Map<String, dynamic> payload);

  @POST("/nft/index_one")
  Future requestIndexOne(@Body() Map<String, dynamic> payload);

  @GET("/nft/owned")
  Future<List<String>> getNftIDsByOwner(
    @Query("owner") String owner,
  );

  @POST("/v1/nft/pending")
  Future postNftPendingToken(
    @Body() Map<String, dynamic> payload,
  );
}
