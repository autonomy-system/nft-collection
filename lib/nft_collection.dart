library nft_collection;

import 'package:logging/logging.dart';
import 'package:nft_collection/database/nft_collection_database.dart';
import 'package:nft_collection/services/configuration_service.dart';
import 'package:nft_collection/services/tokens_service.dart';
import 'package:nft_collection/widgets/nft_collection_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:nft_collection/widgets/nft_collection_bloc.dart';
export 'package:nft_collection/widgets/nft_collection_bloc_event.dart';
export 'package:nft_collection/widgets/nft_collection_grid_widget.dart';

class NftCollection {
  static Logger logger = Logger("nft_collection");

  static Future<NftCollectionBloc> createBloc(
      {required String indexerUrl,
      String databaseFileName = "nft_collection.db",
      Logger? logger}) async {
    if (logger != null) {
      NftCollection.logger = logger;
    }
    final db = await $FloorNftCollectionDatabase
        .databaseBuilder(databaseFileName)
        .build();
    final prefs = NftCollectionPrefs(await SharedPreferences.getInstance());
    final tokenService = TokensServiceImpl(indexerUrl, db, prefs);
    final bloc = NftCollectionBloc(tokenService, db);
    return bloc;
  }
}
