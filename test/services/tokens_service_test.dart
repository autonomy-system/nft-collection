import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nft_collection/data/api/indexer_api.dart';
import 'package:nft_collection/data/api/tzkt_api.dart';
import 'package:nft_collection/database/dao/asset_token_dao.dart';
import 'package:nft_collection/database/dao/provenance_dao.dart';
import 'package:nft_collection/database/dao/token_owner_dao.dart';
import 'package:nft_collection/database/nft_collection_database.dart';
import 'package:nft_collection/models/asset.dart';
import 'package:nft_collection/models/asset_token.dart';
import 'package:nft_collection/models/provenance.dart';
import 'package:nft_collection/models/token_owner.dart';
import 'package:nft_collection/services/configuration_service.dart';
import 'package:nft_collection/services/tokens_service.dart';

import 'tokens_service_test.mocks.dart';

@GenerateMocks([
  SendPort,
  NftCollectionDatabase,
  NftCollectionPrefs,
  IndexerApi,
  AssetTokenDao,
  TokenOwnerDao,
  ProvenanceDao,
  TZKTApi
])
main() async {
  late TokensServiceImpl tokenService;
  late SendPort sendPort;
  late NftCollectionDatabase database;
  late MockNftCollectionPrefs collectionPrefs;
  late MockIndexerApi indexerApi;
  late MockAssetTokenDao assetTokenDao;
  late TZKTApi tzktApi;
  late MockTokenOwnerDao tokenOwnerDao;
  late MockProvenanceDao provenanceDao;
  const txAddress = ["tz1hotTARbXBb71aPRWqp2QT5BgfYGacDoev"];
  DateTime now = DateTime.now();
  const size = 1;
  TokenOwner tokenOwner = TokenOwner("id", txAddress[0], size, now);
  Provenance provenance = Provenance(
      type: "type",
      blockchain: "blockchain",
      txID: "txID",
      owner: "owner",
      timestamp: now,
      txURL: "txURL",
      tokenID: "tokenID");
  Asset asset = Asset(
      id: "id",
      edition: 11,
      blockchain: "blockchain",
      fungible: true,
      mintedAt: now,
      contractType: "contractType",
      tokenId: "tokenId",
      contractAddress: "contractAddress",
      blockchainURL: "blockchainURL",
      owner: "owner",
      owners: {txAddress[0]: 1},
      thumbnailID: '',
      lastActivityTime: now,
      projectMetadata: ProjectMetadata(
        origin: ProjectMetadataData(
            artistName: "artistName",
            artistUrl: "artistUrl",
            assetId: "assetId",
            title: "title",
            description: "description",
            medium: 'medium',
            mimeType: 'mimeType',
            maxEdition: 1,
            baseCurrency: "baseCurrency",
            basePrice: 2,
            source: "source",
            sourceUrl: "sourceUrl",
            previewUrl: "previewUrl",
            thumbnailUrl: "thumbnailUrl",
            galleryThumbnailUrl: "galleryThumbnailUrl",
            assetData: "assetData",
            assetUrl: "assetUrl",
            artistId: "artistId",
            originalFileUrl: "originalFileUrl",
            initialSaleModel: 'initialSaleModel'),
        latest: ProjectMetadataData(
            artistName: "artistName",
            artistUrl: "artistUrl",
            assetId: "assetId",
            title: "title",
            description: "description",
            medium: 'medium',
            mimeType: 'mimeType',
            maxEdition: 1,
            baseCurrency: "baseCurrency",
            basePrice: 2,
            source: "source",
            sourceUrl: "sourceUrl",
            previewUrl: "previewUrl",
            thumbnailUrl: "thumbnailUrl",
            galleryThumbnailUrl: "galleryThumbnailUrl",
            assetData: "assetData",
            assetUrl: "assetUrl",
            artistId: "artistId",
            originalFileUrl: "originalFileUrl",
            initialSaleModel: 'initialSaleModel'),
      ),
      provenance: [provenance]);
  AssetToken assetToken = AssetToken.fromAsset(asset);
  group('tokens service test', () {
    setup() async {
      collectionPrefs = MockNftCollectionPrefs();
      indexerApi = MockIndexerApi();
      tzktApi = MockTZKTApi();
      sendPort = MockSendPort();
      assetTokenDao = MockAssetTokenDao();
      tokenOwnerDao = MockTokenOwnerDao();
      provenanceDao = MockProvenanceDao();
      database = MockNftCollectionDatabase();
      when(database.assetDao).thenReturn(assetTokenDao);
      when(database.tokenOwnerDao).thenReturn(tokenOwnerDao);
      when(database.provenanceDao).thenReturn(provenanceDao);
      tokenService = TokensServiceImpl(
          "https://nft-indexer.bitmark.com/", database, collectionPrefs);
      tokenService.setMocktestService(tzktApi, indexerApi);
    }

    test('fetch latest assets', () async {
      await setup();

      when(indexerApi.getNftTokensByOwner(txAddress[0], 0, size))
          .thenAnswer((_) async => [asset]);

      final tokens = await tokenService.fetchLatestAssets(txAddress, size);

      var tokenOwnerParam = verify(tokenOwnerDao.insertTokenOwners(captureAny))
          .captured
          .first as List<TokenOwner>;
      expect(tokenOwnerParam.first.indexerId, tokenOwner.indexerId);
      expect(tokenOwnerParam.first.owner, tokenOwner.owner);
      expect(tokenOwnerParam.first.quantity, tokenOwner.quantity);
      expect(tokenOwnerParam.first.updateTime, tokenOwner.updateTime);
      verify(assetTokenDao.insertAssets([assetToken])).called(1);
      verify(provenanceDao.insertProvenance([provenance])).called(1);

      expect(tokens[0], asset);
    });

    test('Set custom tokens', () async {
      await setup();

      await tokenService.setCustomTokens([assetToken]);

      var tokenOwnerParam = verify(tokenOwnerDao.insertTokenOwners(captureAny))
          .captured
          .first as List<TokenOwner>;
      expect(tokenOwnerParam.first.indexerId, tokenOwner.indexerId);
      expect(tokenOwnerParam.first.owner, tokenOwner.owner);
      expect(tokenOwnerParam.first.quantity, tokenOwner.quantity);
      expect(tokenOwnerParam.first.updateTime, tokenOwner.updateTime);

      verify(assetTokenDao.insertAssets([assetToken])).called(1);
    });

    test('Fetch manual tokens', () async {
      await setup();

      when(indexerApi.getNftTokens({
        "ids": ["id"]
      })).thenAnswer((_) async => [asset]);

      await tokenService.fetchManualTokens(["id"]);

      var tokenOwnerParam = verify(tokenOwnerDao.insertTokenOwners(captureAny))
          .captured
          .first as List<TokenOwner>;
      expect(tokenOwnerParam.first.indexerId, tokenOwner.indexerId);
      expect(tokenOwnerParam.first.owner, tokenOwner.owner);
      expect(tokenOwnerParam.first.quantity, tokenOwner.quantity);
      expect(tokenOwnerParam.first.updateTime, tokenOwner.updateTime);
      verify(assetTokenDao.insertAssets([assetToken])).called(1);
      verify(provenanceDao.insertProvenance([provenance])).called(1);
    });

    test('Purge cached gallery', () async {
      await setup();
      when(collectionPrefs.setLatestRefreshTokens(any)).thenAnswer((_) async => true);
      when(assetTokenDao.removeAllExcludePending()).thenAnswer((_) async => {Future<void>});
      await tokenService.purgeCachedGallery();
      verify(collectionPrefs.setLatestRefreshTokens(any)).called(1);
      //verify(assetTokenDao.removeAllExcludePending()).called(1);

    });

    test('Fetch tokens for address', () async {
      await setup();
      when(indexerApi.getNftTokensByOwner(any, any, any))
          .thenAnswer((_) async { print("12"); return [asset]; });
      await tokenService.fetchTokensForAddresses(txAddress);
      //verify(indexerApi.getNftTokensByOwner(any, any, any)).called(1);

    });


  });
}
