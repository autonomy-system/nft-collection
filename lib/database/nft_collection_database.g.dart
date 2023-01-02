// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nft_collection_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorNftCollectionDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$NftCollectionDatabaseBuilder databaseBuilder(String name) =>
      _$NftCollectionDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$NftCollectionDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$NftCollectionDatabaseBuilder(null);
}

class _$NftCollectionDatabaseBuilder {
  _$NftCollectionDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$NftCollectionDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$NftCollectionDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<NftCollectionDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$NftCollectionDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$NftCollectionDatabase extends NftCollectionDatabase {
  _$NftCollectionDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  AssetTokenDao? _assetDaoInstance;

  ProvenanceDao? _provenanceDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 10,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `AssetToken` (`artistName` TEXT, `artistURL` TEXT, `artistID` TEXT, `assetData` TEXT, `assetID` TEXT, `assetURL` TEXT, `basePrice` REAL, `baseCurrency` TEXT, `blockchain` TEXT NOT NULL, `blockchainUrl` TEXT, `fungible` INTEGER, `contractType` TEXT, `tokenId` TEXT, `contractAddress` TEXT, `desc` TEXT, `edition` INTEGER NOT NULL, `editionName` TEXT, `id` TEXT NOT NULL, `maxEdition` INTEGER, `medium` TEXT, `mimeType` TEXT, `mintedAt` TEXT, `previewURL` TEXT, `source` TEXT, `sourceURL` TEXT, `thumbnailID` TEXT, `thumbnailURL` TEXT, `galleryThumbnailURL` TEXT, `title` TEXT NOT NULL, `ownerAddress` TEXT NOT NULL, `owners` TEXT NOT NULL, `balance` INTEGER, `lastActivityTime` INTEGER NOT NULL, `updateTime` INTEGER, `pending` INTEGER, `initialSaleModel` TEXT, `isFeralfileFrame` INTEGER, `originTokenInfoId` TEXT, `swapped` INTEGER NOT NULL, PRIMARY KEY (`id`, `ownerAddress`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Provenance` (`id` TEXT NOT NULL, `txID` TEXT NOT NULL, `type` TEXT NOT NULL, `blockchain` TEXT NOT NULL, `owner` TEXT NOT NULL, `timestamp` INTEGER NOT NULL, `txURL` TEXT NOT NULL, `tokenID` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE INDEX `index_Provenance_id` ON `Provenance` (`id`)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  AssetTokenDao get assetDao {
    return _assetDaoInstance ??= _$AssetTokenDao(database, changeListener);
  }

  @override
  ProvenanceDao get provenanceDao {
    return _provenanceDaoInstance ??= _$ProvenanceDao(database, changeListener);
  }
}

class _$AssetTokenDao extends AssetTokenDao {
  _$AssetTokenDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _assetTokenInsertionAdapter = InsertionAdapter(
            database,
            'AssetToken',
            (AssetToken item) => <String, Object?>{
                  'artistName': item.artistName,
                  'artistURL': item.artistURL,
                  'artistID': item.artistID,
                  'assetData': item.assetData,
                  'assetID': item.assetID,
                  'assetURL': item.assetURL,
                  'basePrice': item.basePrice,
                  'baseCurrency': item.baseCurrency,
                  'blockchain': item.blockchain,
                  'blockchainUrl': item.blockchainUrl,
                  'fungible':
                      item.fungible == null ? null : (item.fungible! ? 1 : 0),
                  'contractType': item.contractType,
                  'tokenId': item.tokenId,
                  'contractAddress': item.contractAddress,
                  'desc': item.desc,
                  'edition': item.edition,
                  'editionName': item.editionName,
                  'id': item.id,
                  'maxEdition': item.maxEdition,
                  'medium': item.medium,
                  'mimeType': item.mimeType,
                  'mintedAt': item.mintedAt,
                  'previewURL': item.previewURL,
                  'source': item.source,
                  'sourceURL': item.sourceURL,
                  'thumbnailID': item.thumbnailID,
                  'thumbnailURL': item.thumbnailURL,
                  'galleryThumbnailURL': item.galleryThumbnailURL,
                  'title': item.title,
                  'ownerAddress': item.ownerAddress,
                  'owners': _tokenOwnersConverter.encode(item.owners),
                  'balance': item.balance,
                  'lastActivityTime':
                      _dateTimeConverter.encode(item.lastActivityTime),
                  'updateTime':
                      _nullableDateTimeConverter.encode(item.updateTime),
                  'pending':
                      item.pending == null ? null : (item.pending! ? 1 : 0),
                  'initialSaleModel': item.initialSaleModel,
                  'isFeralfileFrame': item.isFeralfileFrame == null
                      ? null
                      : (item.isFeralfileFrame! ? 1 : 0),
                  'originTokenInfoId': item.originTokenInfoId,
                  'swapped': item.swapped ? 1 : 0
                }),
        _assetTokenUpdateAdapter = UpdateAdapter(
            database,
            'AssetToken',
            ['id', 'ownerAddress'],
            (AssetToken item) => <String, Object?>{
                  'artistName': item.artistName,
                  'artistURL': item.artistURL,
                  'artistID': item.artistID,
                  'assetData': item.assetData,
                  'assetID': item.assetID,
                  'assetURL': item.assetURL,
                  'basePrice': item.basePrice,
                  'baseCurrency': item.baseCurrency,
                  'blockchain': item.blockchain,
                  'blockchainUrl': item.blockchainUrl,
                  'fungible':
                      item.fungible == null ? null : (item.fungible! ? 1 : 0),
                  'contractType': item.contractType,
                  'tokenId': item.tokenId,
                  'contractAddress': item.contractAddress,
                  'desc': item.desc,
                  'edition': item.edition,
                  'editionName': item.editionName,
                  'id': item.id,
                  'maxEdition': item.maxEdition,
                  'medium': item.medium,
                  'mimeType': item.mimeType,
                  'mintedAt': item.mintedAt,
                  'previewURL': item.previewURL,
                  'source': item.source,
                  'sourceURL': item.sourceURL,
                  'thumbnailID': item.thumbnailID,
                  'thumbnailURL': item.thumbnailURL,
                  'galleryThumbnailURL': item.galleryThumbnailURL,
                  'title': item.title,
                  'ownerAddress': item.ownerAddress,
                  'owners': _tokenOwnersConverter.encode(item.owners),
                  'balance': item.balance,
                  'lastActivityTime':
                      _dateTimeConverter.encode(item.lastActivityTime),
                  'updateTime':
                      _nullableDateTimeConverter.encode(item.updateTime),
                  'pending':
                      item.pending == null ? null : (item.pending! ? 1 : 0),
                  'initialSaleModel': item.initialSaleModel,
                  'isFeralfileFrame': item.isFeralfileFrame == null
                      ? null
                      : (item.isFeralfileFrame! ? 1 : 0),
                  'originTokenInfoId': item.originTokenInfoId,
                  'swapped': item.swapped ? 1 : 0
                }),
        _assetTokenDeletionAdapter = DeletionAdapter(
            database,
            'AssetToken',
            ['id', 'ownerAddress'],
            (AssetToken item) => <String, Object?>{
                  'artistName': item.artistName,
                  'artistURL': item.artistURL,
                  'artistID': item.artistID,
                  'assetData': item.assetData,
                  'assetID': item.assetID,
                  'assetURL': item.assetURL,
                  'basePrice': item.basePrice,
                  'baseCurrency': item.baseCurrency,
                  'blockchain': item.blockchain,
                  'blockchainUrl': item.blockchainUrl,
                  'fungible':
                      item.fungible == null ? null : (item.fungible! ? 1 : 0),
                  'contractType': item.contractType,
                  'tokenId': item.tokenId,
                  'contractAddress': item.contractAddress,
                  'desc': item.desc,
                  'edition': item.edition,
                  'editionName': item.editionName,
                  'id': item.id,
                  'maxEdition': item.maxEdition,
                  'medium': item.medium,
                  'mimeType': item.mimeType,
                  'mintedAt': item.mintedAt,
                  'previewURL': item.previewURL,
                  'source': item.source,
                  'sourceURL': item.sourceURL,
                  'thumbnailID': item.thumbnailID,
                  'thumbnailURL': item.thumbnailURL,
                  'galleryThumbnailURL': item.galleryThumbnailURL,
                  'title': item.title,
                  'ownerAddress': item.ownerAddress,
                  'owners': _tokenOwnersConverter.encode(item.owners),
                  'balance': item.balance,
                  'lastActivityTime':
                      _dateTimeConverter.encode(item.lastActivityTime),
                  'updateTime':
                      _nullableDateTimeConverter.encode(item.updateTime),
                  'pending':
                      item.pending == null ? null : (item.pending! ? 1 : 0),
                  'initialSaleModel': item.initialSaleModel,
                  'isFeralfileFrame': item.isFeralfileFrame == null
                      ? null
                      : (item.isFeralfileFrame! ? 1 : 0),
                  'originTokenInfoId': item.originTokenInfoId,
                  'swapped': item.swapped ? 1 : 0
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<AssetToken> _assetTokenInsertionAdapter;

  final UpdateAdapter<AssetToken> _assetTokenUpdateAdapter;

  final DeletionAdapter<AssetToken> _assetTokenDeletionAdapter;

  @override
  Future<List<AssetToken>> findAllAssetTokens() async {
    return _queryAdapter.queryList(
        'SELECT * FROM AssetToken ORDER BY lastActivityTime DESC, title, assetID',
        mapper: (Map<String, Object?> row) => AssetToken(
            artistName: row['artistName'] as String?,
            artistURL: row['artistURL'] as String?,
            artistID: row['artistID'] as String?,
            assetData: row['assetData'] as String?,
            assetID: row['assetID'] as String?,
            assetURL: row['assetURL'] as String?,
            basePrice: row['basePrice'] as double?,
            baseCurrency: row['baseCurrency'] as String?,
            blockchain: row['blockchain'] as String,
            blockchainUrl: row['blockchainUrl'] as String?,
            fungible:
                row['fungible'] == null ? null : (row['fungible'] as int) != 0,
            contractType: row['contractType'] as String?,
            tokenId: row['tokenId'] as String?,
            contractAddress: row['contractAddress'] as String?,
            desc: row['desc'] as String?,
            edition: row['edition'] as int,
            editionName: row['editionName'] as String?,
            id: row['id'] as String,
            maxEdition: row['maxEdition'] as int?,
            medium: row['medium'] as String?,
            mimeType: row['mimeType'] as String?,
            mintedAt: row['mintedAt'] as String?,
            previewURL: row['previewURL'] as String?,
            source: row['source'] as String?,
            sourceURL: row['sourceURL'] as String?,
            thumbnailID: row['thumbnailID'] as String?,
            thumbnailURL: row['thumbnailURL'] as String?,
            galleryThumbnailURL: row['galleryThumbnailURL'] as String?,
            title: row['title'] as String,
            initialSaleModel: row['initialSaleModel'] as String?,
            ownerAddress: row['ownerAddress'] as String,
            owners: _tokenOwnersConverter.decode(row['owners'] as String),
            balance: row['balance'] as int?,
            lastActivityTime:
                _dateTimeConverter.decode(row['lastActivityTime'] as int),
            updateTime:
                _nullableDateTimeConverter.decode(row['updateTime'] as int?),
            isFeralfileFrame: row['isFeralfileFrame'] == null
                ? null
                : (row['isFeralfileFrame'] as int) != 0,
            pending:
                row['pending'] == null ? null : (row['pending'] as int) != 0,
            originTokenInfoId: row['originTokenInfoId'] as String?,
            swapped: (row['swapped'] as int) != 0));
  }

  @override
  Future<List<AssetToken>> findAllAssetTokensByOwners(
      List<String> owners) async {
    const offset = 1;
    final _sqliteVariablesForOwners =
        Iterable<String>.generate(owners.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.queryList(
        'SELECT DISTINCT * FROM AssetToken WHERE ownerAddress IN (' +
            _sqliteVariablesForOwners +
            ') ORDER BY lastActivityTime DESC, title, assetID',
        mapper: (Map<String, Object?> row) => AssetToken(
            artistName: row['artistName'] as String?,
            artistURL: row['artistURL'] as String?,
            artistID: row['artistID'] as String?,
            assetData: row['assetData'] as String?,
            assetID: row['assetID'] as String?,
            assetURL: row['assetURL'] as String?,
            basePrice: row['basePrice'] as double?,
            baseCurrency: row['baseCurrency'] as String?,
            blockchain: row['blockchain'] as String,
            blockchainUrl: row['blockchainUrl'] as String?,
            fungible:
                row['fungible'] == null ? null : (row['fungible'] as int) != 0,
            contractType: row['contractType'] as String?,
            tokenId: row['tokenId'] as String?,
            contractAddress: row['contractAddress'] as String?,
            desc: row['desc'] as String?,
            edition: row['edition'] as int,
            editionName: row['editionName'] as String?,
            id: row['id'] as String,
            maxEdition: row['maxEdition'] as int?,
            medium: row['medium'] as String?,
            mimeType: row['mimeType'] as String?,
            mintedAt: row['mintedAt'] as String?,
            previewURL: row['previewURL'] as String?,
            source: row['source'] as String?,
            sourceURL: row['sourceURL'] as String?,
            thumbnailID: row['thumbnailID'] as String?,
            thumbnailURL: row['thumbnailURL'] as String?,
            galleryThumbnailURL: row['galleryThumbnailURL'] as String?,
            title: row['title'] as String,
            initialSaleModel: row['initialSaleModel'] as String?,
            ownerAddress: row['ownerAddress'] as String,
            owners: _tokenOwnersConverter.decode(row['owners'] as String),
            balance: row['balance'] as int?,
            lastActivityTime:
                _dateTimeConverter.decode(row['lastActivityTime'] as int),
            updateTime:
                _nullableDateTimeConverter.decode(row['updateTime'] as int?),
            isFeralfileFrame: row['isFeralfileFrame'] == null
                ? null
                : (row['isFeralfileFrame'] as int) != 0,
            pending:
                row['pending'] == null ? null : (row['pending'] as int) != 0,
            originTokenInfoId: row['originTokenInfoId'] as String?,
            swapped: (row['swapped'] as int) != 0),
        arguments: [...owners]);
  }

  @override
  Future<List<AssetToken>> findAssetTokensByBlockchain(
      String blockchain) async {
    return _queryAdapter.queryList(
        'SELECT * FROM AssetToken WHERE blockchain = ?1',
        mapper: (Map<String, Object?> row) => AssetToken(
            artistName: row['artistName'] as String?,
            artistURL: row['artistURL'] as String?,
            artistID: row['artistID'] as String?,
            assetData: row['assetData'] as String?,
            assetID: row['assetID'] as String?,
            assetURL: row['assetURL'] as String?,
            basePrice: row['basePrice'] as double?,
            baseCurrency: row['baseCurrency'] as String?,
            blockchain: row['blockchain'] as String,
            blockchainUrl: row['blockchainUrl'] as String?,
            fungible:
                row['fungible'] == null ? null : (row['fungible'] as int) != 0,
            contractType: row['contractType'] as String?,
            tokenId: row['tokenId'] as String?,
            contractAddress: row['contractAddress'] as String?,
            desc: row['desc'] as String?,
            edition: row['edition'] as int,
            editionName: row['editionName'] as String?,
            id: row['id'] as String,
            maxEdition: row['maxEdition'] as int?,
            medium: row['medium'] as String?,
            mimeType: row['mimeType'] as String?,
            mintedAt: row['mintedAt'] as String?,
            previewURL: row['previewURL'] as String?,
            source: row['source'] as String?,
            sourceURL: row['sourceURL'] as String?,
            thumbnailID: row['thumbnailID'] as String?,
            thumbnailURL: row['thumbnailURL'] as String?,
            galleryThumbnailURL: row['galleryThumbnailURL'] as String?,
            title: row['title'] as String,
            initialSaleModel: row['initialSaleModel'] as String?,
            ownerAddress: row['ownerAddress'] as String,
            owners: _tokenOwnersConverter.decode(row['owners'] as String),
            balance: row['balance'] as int?,
            lastActivityTime:
                _dateTimeConverter.decode(row['lastActivityTime'] as int),
            updateTime:
                _nullableDateTimeConverter.decode(row['updateTime'] as int?),
            isFeralfileFrame: row['isFeralfileFrame'] == null
                ? null
                : (row['isFeralfileFrame'] as int) != 0,
            pending:
                row['pending'] == null ? null : (row['pending'] as int) != 0,
            originTokenInfoId: row['originTokenInfoId'] as String?,
            swapped: (row['swapped'] as int) != 0),
        arguments: [blockchain]);
  }

  @override
  Future<AssetToken?> findAssetTokenByIdAndOwner(
    String id,
    String owner,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM AssetToken WHERE id = ?1 AND ownerAddress = ?2',
        mapper: (Map<String, Object?> row) => AssetToken(
            artistName: row['artistName'] as String?,
            artistURL: row['artistURL'] as String?,
            artistID: row['artistID'] as String?,
            assetData: row['assetData'] as String?,
            assetID: row['assetID'] as String?,
            assetURL: row['assetURL'] as String?,
            basePrice: row['basePrice'] as double?,
            baseCurrency: row['baseCurrency'] as String?,
            blockchain: row['blockchain'] as String,
            blockchainUrl: row['blockchainUrl'] as String?,
            fungible:
                row['fungible'] == null ? null : (row['fungible'] as int) != 0,
            contractType: row['contractType'] as String?,
            tokenId: row['tokenId'] as String?,
            contractAddress: row['contractAddress'] as String?,
            desc: row['desc'] as String?,
            edition: row['edition'] as int,
            editionName: row['editionName'] as String?,
            id: row['id'] as String,
            maxEdition: row['maxEdition'] as int?,
            medium: row['medium'] as String?,
            mimeType: row['mimeType'] as String?,
            mintedAt: row['mintedAt'] as String?,
            previewURL: row['previewURL'] as String?,
            source: row['source'] as String?,
            sourceURL: row['sourceURL'] as String?,
            thumbnailID: row['thumbnailID'] as String?,
            thumbnailURL: row['thumbnailURL'] as String?,
            galleryThumbnailURL: row['galleryThumbnailURL'] as String?,
            title: row['title'] as String,
            initialSaleModel: row['initialSaleModel'] as String?,
            ownerAddress: row['ownerAddress'] as String,
            owners: _tokenOwnersConverter.decode(row['owners'] as String),
            balance: row['balance'] as int?,
            lastActivityTime:
                _dateTimeConverter.decode(row['lastActivityTime'] as int),
            updateTime:
                _nullableDateTimeConverter.decode(row['updateTime'] as int?),
            isFeralfileFrame: row['isFeralfileFrame'] == null
                ? null
                : (row['isFeralfileFrame'] as int) != 0,
            pending:
                row['pending'] == null ? null : (row['pending'] as int) != 0,
            originTokenInfoId: row['originTokenInfoId'] as String?,
            swapped: (row['swapped'] as int) != 0),
        arguments: [id, owner]);
  }

  @override
  Future<List<AssetToken>> findAllAssetTokensByIds(List<String> ids) async {
    const offset = 1;
    final _sqliteVariablesForIds =
        Iterable<String>.generate(ids.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.queryList(
        'SELECT * FROM AssetToken WHERE id IN (' + _sqliteVariablesForIds + ')',
        mapper: (Map<String, Object?> row) => AssetToken(
            artistName: row['artistName'] as String?,
            artistURL: row['artistURL'] as String?,
            artistID: row['artistID'] as String?,
            assetData: row['assetData'] as String?,
            assetID: row['assetID'] as String?,
            assetURL: row['assetURL'] as String?,
            basePrice: row['basePrice'] as double?,
            baseCurrency: row['baseCurrency'] as String?,
            blockchain: row['blockchain'] as String,
            blockchainUrl: row['blockchainUrl'] as String?,
            fungible:
                row['fungible'] == null ? null : (row['fungible'] as int) != 0,
            contractType: row['contractType'] as String?,
            tokenId: row['tokenId'] as String?,
            contractAddress: row['contractAddress'] as String?,
            desc: row['desc'] as String?,
            edition: row['edition'] as int,
            editionName: row['editionName'] as String?,
            id: row['id'] as String,
            maxEdition: row['maxEdition'] as int?,
            medium: row['medium'] as String?,
            mimeType: row['mimeType'] as String?,
            mintedAt: row['mintedAt'] as String?,
            previewURL: row['previewURL'] as String?,
            source: row['source'] as String?,
            sourceURL: row['sourceURL'] as String?,
            thumbnailID: row['thumbnailID'] as String?,
            thumbnailURL: row['thumbnailURL'] as String?,
            galleryThumbnailURL: row['galleryThumbnailURL'] as String?,
            title: row['title'] as String,
            initialSaleModel: row['initialSaleModel'] as String?,
            ownerAddress: row['ownerAddress'] as String,
            owners: _tokenOwnersConverter.decode(row['owners'] as String),
            balance: row['balance'] as int?,
            lastActivityTime:
                _dateTimeConverter.decode(row['lastActivityTime'] as int),
            updateTime:
                _nullableDateTimeConverter.decode(row['updateTime'] as int?),
            isFeralfileFrame: row['isFeralfileFrame'] == null
                ? null
                : (row['isFeralfileFrame'] as int) != 0,
            pending:
                row['pending'] == null ? null : (row['pending'] as int) != 0,
            originTokenInfoId: row['originTokenInfoId'] as String?,
            swapped: (row['swapped'] as int) != 0),
        arguments: [...ids]);
  }

  @override
  Future<List<String>> findAllAssetTokenIDs() async {
    return _queryAdapter.queryList('SELECT id FROM AssetToken',
        mapper: (Map<String, Object?> row) => row["id"] as String);
  }

  @override
  Future<List<String>> findAllAssetTokenIDsByOwner(String owner) async {
    return await _queryAdapter.queryList(
      'SELECT id FROM AssetToken WHERE ownerAddress=?1',
      arguments: [owner],
      mapper: (Map<String, Object?> row) => row["id"] as String,
    );
  }

  @override
  Future<List<String>> findAllAssetArtistIDs() async {
    return _queryAdapter.queryList('SELECT DISTINCT artistID FROM AssetToken',
        mapper: (Map<String, Object?> row) => row["artistID"] as String);
  }

  @override
  Future<List<AssetToken>> findAllPendingTokens() async {
    return _queryAdapter.queryList('SELECT * FROM AssetToken WHERE pending = 1',
        mapper: (Map<String, Object?> row) => AssetToken(
            artistName: row['artistName'] as String?,
            artistURL: row['artistURL'] as String?,
            artistID: row['artistID'] as String?,
            assetData: row['assetData'] as String?,
            assetID: row['assetID'] as String?,
            assetURL: row['assetURL'] as String?,
            basePrice: row['basePrice'] as double?,
            baseCurrency: row['baseCurrency'] as String?,
            blockchain: row['blockchain'] as String,
            blockchainUrl: row['blockchainUrl'] as String?,
            fungible:
                row['fungible'] == null ? null : (row['fungible'] as int) != 0,
            contractType: row['contractType'] as String?,
            tokenId: row['tokenId'] as String?,
            contractAddress: row['contractAddress'] as String?,
            desc: row['desc'] as String?,
            edition: row['edition'] as int,
            editionName: row['editionName'] as String?,
            id: row['id'] as String,
            maxEdition: row['maxEdition'] as int?,
            medium: row['medium'] as String?,
            mimeType: row['mimeType'] as String?,
            mintedAt: row['mintedAt'] as String?,
            previewURL: row['previewURL'] as String?,
            source: row['source'] as String?,
            sourceURL: row['sourceURL'] as String?,
            thumbnailID: row['thumbnailID'] as String?,
            thumbnailURL: row['thumbnailURL'] as String?,
            galleryThumbnailURL: row['galleryThumbnailURL'] as String?,
            title: row['title'] as String,
            initialSaleModel: row['initialSaleModel'] as String?,
            ownerAddress: row['ownerAddress'] as String,
            owners: _tokenOwnersConverter.decode(row['owners'] as String),
            balance: row['balance'] as int?,
            lastActivityTime:
                _dateTimeConverter.decode(row['lastActivityTime'] as int),
            updateTime:
                _nullableDateTimeConverter.decode(row['updateTime'] as int?),
            isFeralfileFrame: row['isFeralfileFrame'] == null
                ? null
                : (row['isFeralfileFrame'] as int) != 0,
            pending:
                row['pending'] == null ? null : (row['pending'] as int) != 0,
            originTokenInfoId: row['originTokenInfoId'] as String?,
            swapped: (row['swapped'] as int) != 0));
  }

  @override
  Future<void> deleteAssets(List<String> ids) async {
    const offset = 1;
    final _sqliteVariablesForIds =
        Iterable<String>.generate(ids.length, (i) => '?${i + offset}')
            .join(',');
    await _queryAdapter.queryNoReturn(
        'DELETE FROM AssetToken WHERE id IN (' + _sqliteVariablesForIds + ')',
        arguments: [...ids]);
  }

  @override
  Future<void> deleteAssetsNotIn(List<String> ids) async {
    const offset = 1;
    final _sqliteVariablesForIds =
        Iterable<String>.generate(ids.length, (i) => '?${i + offset}')
            .join(',');
    await _queryAdapter.queryNoReturn(
        'DELETE FROM AssetToken WHERE id NOT IN (' +
            _sqliteVariablesForIds +
            ')',
        arguments: [...ids]);
  }

  @override
  Future<void> deleteAssetsNotInByOwner(
    List<String> ids,
    String owner,
  ) async {
    const offset = 2;
    final _sqliteVariablesForIds =
        Iterable<String>.generate(ids.length, (i) => '?${i + offset}')
            .join(',');
    await _queryAdapter.queryNoReturn(
        'DELETE FROM AssetToken WHERE id NOT IN (' +
            _sqliteVariablesForIds +
            ') AND ownerAddress=?1',
        arguments: [owner, ...ids]);
  }

  @override
  Future<void> deleteAssetsNotBelongs(List<String> owners) async {
    const offset = 1;
    final _sqliteVariablesForOwners =
        Iterable<String>.generate(owners.length, (i) => '?${i + offset}')
            .join(',');
    await _queryAdapter.queryNoReturn(
        'DELETE FROM AssetToken WHERE ownerAddress NOT IN (' +
            _sqliteVariablesForOwners +
            ')',
        arguments: [...owners]);
  }

  @override
  Future<void> removeAll() async {
    await _queryAdapter.queryNoReturn('DELETE FROM AssetToken');
  }

  @override
  Future<void> removeAllExcludePending() async {
    await _queryAdapter.queryNoReturn('DELETE FROM AssetToken WHERE pending=0');
  }

  @override
  Future<void> insertAsset(AssetToken asset) async {
    await _assetTokenInsertionAdapter.insert(asset, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertAssets(List<AssetToken> assets) async {
    await _assetTokenInsertionAdapter.insertList(
        assets, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateAsset(AssetToken asset) async {
    await _assetTokenUpdateAdapter.update(asset, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteAsset(AssetToken asset) async {
    await _assetTokenDeletionAdapter.delete(asset);
  }
}

class _$ProvenanceDao extends ProvenanceDao {
  _$ProvenanceDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _provenanceInsertionAdapter = InsertionAdapter(
            database,
            'Provenance',
            (Provenance item) => <String, Object?>{
                  'id': item.id,
                  'txID': item.txID,
                  'type': item.type,
                  'blockchain': item.blockchain,
                  'owner': item.owner,
                  'timestamp': _dateTimeConverter.encode(item.timestamp),
                  'txURL': item.txURL,
                  'tokenID': item.tokenID
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Provenance> _provenanceInsertionAdapter;

  @override
  Future<List<Provenance>> findProvenanceByTokenID(String tokenID) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Provenance WHERE tokenID = ?1',
        mapper: (Map<String, Object?> row) => Provenance(
            id: row['id'] as String,
            type: row['type'] as String,
            blockchain: row['blockchain'] as String,
            txID: row['txID'] as String,
            owner: row['owner'] as String,
            timestamp: _dateTimeConverter.decode(row['timestamp'] as int),
            txURL: row['txURL'] as String,
            tokenID: row['tokenID'] as String),
        arguments: [tokenID]);
  }

  @override
  Future<void> deleteProvenanceNotBelongs(List<String> tokenIDs) async {
    const offset = 1;
    final _sqliteVariablesForTokenIDs =
        Iterable<String>.generate(tokenIDs.length, (i) => '?${i + offset}')
            .join(',');
    await _queryAdapter.queryNoReturn(
        'DELETE FROM Provenance WHERE tokenID NOT IN (' +
            _sqliteVariablesForTokenIDs +
            ')',
        arguments: [...tokenIDs]);
  }

  @override
  Future<void> removeAll() async {
    await _queryAdapter.queryNoReturn('DELETE FROM Provenance');
  }

  @override
  Future<void> insertProvenance(List<Provenance> provenance) async {
    await _provenanceInsertionAdapter.insertList(
        provenance, OnConflictStrategy.replace);
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
final _nullableDateTimeConverter = NullableDateTimeConverter();
final _tokenOwnersConverter = TokenOwnersConverter();
