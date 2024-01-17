import 'package:nft_collection/models/identity.dart';

class QueryIdentityResponse {
  Identity identity;
  QueryIdentityResponse({
    required this.identity,
  });

  factory QueryIdentityResponse.fromJson(Map<String, dynamic> map) {
    return QueryIdentityResponse(
      identity: map['identity'] != null
          ? Identity.fromJson(map['identity'])
          : Identity('', '', ''),
    );
  }
}

class QueryIdentityRequest {
  final String account;

  QueryIdentityRequest({
    required this.account,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'account': account,
    };
  }
}
