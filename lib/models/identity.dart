//
//  SPDX-License-Identifier: BSD-2-Clause-Patent
//  Copyright © 2022 Bitmark. All rights reserved.
//  Use of this source code is governed by the BSD-2-Clause Plus Patent License
//  that can be found in the LICENSE file.
//

import 'package:floor/floor.dart';

@entity
class Identity {
  @primaryKey
  String accountNumber;
  String blockchain;
  String name;
  DateTime queriedAt = DateTime.now();

  Identity(this.accountNumber, this.blockchain, this.name);

  Identity.fromJson(Map<String, dynamic> json)
      : accountNumber = json['accountNumber'],
        blockchain = json['blockchain'],
        name = json['name'];
}
