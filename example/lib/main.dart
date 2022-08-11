import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nft_collection/nft_collection.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    final bloc = await NftCollection.createBloc(
        indexerUrl: "https://indexer.test.autonomy.io");
    runApp(BlocProvider.value(value: bloc, child: const MyApp()));
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
  @override
  void initState() {
    final addresses = [
      "tz1d2mQ6FcKkGu6vqxN8cmYQs632YAci7NRV",
      "tz1SidNQb9XcwP7L3MzCZD9JHmWw2ebDzgyX",
      "tz1hJKhae5FrEDqYVfuAkMXTBYegy9g8jBk6",
      "tz1UeTFNPbcNJ5ukPytc84is8VZg3cxY3A9H"
    ];
    context
        .read<NftCollectionBloc>()
        .add(RefreshTokenEvent(addresses: addresses));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                context.read<NftCollectionBloc>().add(PurgeCache());
              },
              icon: const Icon(Icons.refresh)),
        ],
      ),
      body: BlocBuilder<NftCollectionBloc, NftCollectionBlocState>(
        builder: (context, state) {
          return NftCollectionGrid(
            state: state.state,
            tokens: state.tokens,
            onTap: (token) {
              debugPrint(
                  "Tapped on token: ${token.title} -- ${token.previewURL}");
            },
          );
        },
      ),
    );
  }
}
