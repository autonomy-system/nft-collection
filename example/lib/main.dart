import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nft_collection/models/address_index.dart';
import 'package:nft_collection/nft_collection.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await NftCollection.initNftCollection(
        indexerUrl: "https://indexer.test.autonomy.io");
    final nftBloc = NftCollectionBloc(
      NftCollection.tokenService,
      NftCollection.database,
      NftCollection.prefs,
      NftCollection.addressService,
      pendingTokenExpire: const Duration(hours: 1),
    );
    runApp(BlocProvider.value(value: nftBloc, child: const MyApp()));
  }, (error, stack) {
    debugPrint("Unhandled exception: $error");
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFT Collection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'NFT Collection'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late NftCollectionBloc nftBloc;
  final _scrollController = ScrollController();

  @override
  void initState() {
    _scrollController.addListener(_scrollListenerToLoadMore);

    nftBloc = context.read<NftCollectionBloc>();

    nftBloc.add(RefreshNftCollectionByOwners());

    nftBloc.add(GetTokensByOwnerEvent(pageKey: PageKey.init()));

    super.initState();
  }

  _scrollListenerToLoadMore() {
    final nextKey = nftBloc.state.nextKey;
    if (nextKey == null) return;

    if (_scrollController.position.pixels + 100 >=
        _scrollController.position.maxScrollExtent) {
      nftBloc.add(GetTokensByOwnerEvent(pageKey: nextKey));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: BlocBuilder<NftCollectionBloc, NftCollectionBlocState>(
        builder: (context, state) {
          final tokens = state.tokens;
          return GridView.builder(
            controller: _scrollController,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 3,
              mainAxisSpacing: 3,
            ),
            itemBuilder: (context, index) {
              final asset = tokens[index];
              return GestureDetector(
                onTap: () {
                  // onTap?.call(asset);
                },
                child: buildDefaultItemView(context, asset),
              );
            },
            itemCount: tokens.length,
          );
        },
      ),
    );
  }
}
