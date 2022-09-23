//
//  SPDX-License-Identifier: BSD-2-Clause-Patent
//  Copyright © 2022 Bitmark. All rights reserved.
//  Use of this source code is governed by the BSD-2-Clause Plus Patent License
//  that can be found in the LICENSE file.
//

import 'package:json_annotation/json_annotation.dart';

part 'tzkt_operation.g.dart';

@JsonSerializable()
class TZKTTokenTransfer {
  int id;
  int level;
  DateTime timestamp;
  String? amount;
  TZKTToken? token;
  TZKTActor? from;
  TZKTActor? to;
  int? transactionId;
  int? originationId;
  int? migrationId;
  String? status;

  TZKTTokenTransfer({
    required this.id,
    required this.level,
    required this.timestamp,
    this.amount,
    this.token,
    this.from,
    this.to,
    this.transactionId,
    this.originationId,
    this.migrationId,
    this.status,
  });

  factory TZKTTokenTransfer.fromJson(Map<String, dynamic> json) =>
      _$TZKTTokenTransferFromJson(json);

  Map<String, dynamic> toJson() => _$TZKTTokenTransferToJson(this);
}

@JsonSerializable()
class TZKTToken {
  int id;
  TZKTActor? contract;
  String? tokenId;
  String? standard;
  Map<String, dynamic>? metadata;

  TZKTToken({
    required this.id,
    this.contract,
    this.tokenId,
    this.standard,
    this.metadata,
  });

  factory TZKTToken.fromJson(Map<String, dynamic> json) =>
      _$TZKTTokenFromJson(json);

  Map<String, dynamic> toJson() => _$TZKTTokenToJson(this);
}

@JsonSerializable()
class TZKTActor {
  String address;
  String? alias;

  TZKTActor({required this.address, this.alias});

  factory TZKTActor.fromJson(Map<String, dynamic> json) =>
      _$TZKTActorFromJson(json);

  Map<String, dynamic> toJson() => _$TZKTActorToJson(this);
}
