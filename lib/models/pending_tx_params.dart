//
//  SPDX-License-Identifier: BSD-2-Clause-Patent
//  Copyright © 2022 Bitmark. All rights reserved.
//  Use of this source code is governed by the BSD-2-Clause Plus Patent License
//  that can be found in the LICENSE file.
//

class PendingTxParams {
  final String indexID;
  final String blockchain;
  final String id;
  final String contractAddress;
  final String ownerAccount;
  final String pendingTx;

  PendingTxParams(this.indexID, this.blockchain, this.id, this.contractAddress,
      this.ownerAccount, this.pendingTx);

  Map<String, dynamic> toJson() => {
        'indexID': indexID,
        'blockchain': blockchain,
        'id': id,
        'contractAddress': contractAddress,
        'ownerAccount': ownerAccount,
        'pendingTx': pendingTx,
      };
}
