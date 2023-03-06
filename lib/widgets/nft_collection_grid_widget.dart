//
//  SPDX-License-Identifier: BSD-2-Clause-Patent
//  Copyright © 2022 Bitmark. All rights reserved.
//  Use of this source code is governed by the BSD-2-Clause Plus Patent License
//  that can be found in the LICENSE file.
//

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nft_collection/models/asset_token.dart';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

import 'nft_collection_bloc_event.dart';

typedef OnTapCallBack = void Function(AssetToken);

typedef LoadingIndicatorBuilder = Widget Function(BuildContext context);

typedef EmptyGalleryViewBuilder = Widget Function(BuildContext context);

typedef CustomGalleryViewBuilder = Widget Function(
    BuildContext context, List<AssetToken> tokens);

typedef ItemViewBuilder = Widget Function(
    BuildContext context, AssetToken asset);

class NftCollectionGrid extends StatelessWidget {
  final NftLoadingState state;
  final List<AssetToken> tokens;
  final int? columnCount;
  final double itemSpacing;
  final LoadingIndicatorBuilder loadingIndicatorBuilder;
  final EmptyGalleryViewBuilder? emptyGalleryViewBuilder;
  final CustomGalleryViewBuilder? customGalleryViewBuilder;
  final ItemViewBuilder itemViewBuilder;
  final OnTapCallBack? onTap;

  const NftCollectionGrid(
      {Key? key,
      required this.state,
      required this.tokens,
      this.columnCount,
      this.itemSpacing = 3.0,
      this.loadingIndicatorBuilder = _buildLoadingIndicator,
      this.emptyGalleryViewBuilder,
      this.customGalleryViewBuilder,
      this.itemViewBuilder = buildDefaultItemView,
      this.onTap})
      : super(key: key);

  int _columnCount(BuildContext context) {
    if (columnCount != null) {
      return columnCount!;
    } else {
      final screenSize = MediaQuery.of(context).size;
      if (screenSize.width > screenSize.height) {
        return 5;
      } else {
        return 3;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (tokens.isEmpty) {
      if ([NftLoadingState.notRequested, NftLoadingState.loading]
          .contains(state)) {
        return loadingIndicatorBuilder(context);
      } else {
        if (emptyGalleryViewBuilder != null) {
          return emptyGalleryViewBuilder!(context);
        }
      }
    }
    return customGalleryViewBuilder?.call(context, tokens) ??
        GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _columnCount(context),
            crossAxisSpacing: itemSpacing,
            mainAxisSpacing: itemSpacing,
          ),
          itemBuilder: (context, index) {
            final asset = tokens[index];
            return GestureDetector(
              onTap: () {
                onTap?.call(asset);
              },
              child: itemViewBuilder(context, asset),
            );
          },
          itemCount: tokens.length,
        );
  }
}

Widget _buildLoadingIndicator(BuildContext context) {
  return const Center(
    child: SizedBox(
      width: 27,
      height: 27,
      child: CircularProgressIndicator(
        backgroundColor: Colors.black54,
        color: Colors.black,
        strokeWidth: 2,
      ),
    ),
  );
}

Widget buildDefaultItemView(BuildContext context, AssetToken token) {
  final ext = p.extension(token.thumbnailURL!);
  const cachedImageSize = 1024;

  return Hero(
    tag: token.id,
    child: ext == ".svg"
        ? SvgPicture.network(token.galleryThumbnailURL!,
            placeholderBuilder: (context) =>
                Container(color: const Color.fromRGBO(227, 227, 227, 1)))
        : CachedNetworkImage(
            imageUrl: token.galleryThumbnailURL!,
            fit: BoxFit.cover,
            memCacheHeight: cachedImageSize,
            memCacheWidth: cachedImageSize,
            maxWidthDiskCache: cachedImageSize,
            maxHeightDiskCache: cachedImageSize,
            placeholder: (context, index) =>
                Container(color: const Color.fromRGBO(227, 227, 227, 1)),
            placeholderFadeInDuration: const Duration(milliseconds: 300),
            errorWidget: (context, url, error) => Container(
                color: const Color.fromRGBO(227, 227, 227, 1),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/image_error.svg',
                    width: 75,
                    height: 75,
                  ),
                )),
          ),
  );
}
