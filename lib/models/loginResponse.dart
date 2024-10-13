///LoginResponse
class LoginResponse {
  int Code;
  Data data;
  String Message;

  LoginResponse({
    required this.Code,
    required this.data,
    required this.Message,
  });

  Future<LoginResponse> fromJson(Map<String, dynamic> json) async {
    return LoginResponse(
      Code: json['Code'],
      data: Data.fromJson(json['data']),
      Message: json['Message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Code': Code,
      'data': data.toJson(),
      'Message': Message,
    };
  }
}

class Data {
  Account account;

  Data({
    required this.account,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      account: Account.fromJson(json['account']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account': account.toJson(),
    };
  }
}

class Account {
  int channelId;
  int platformId;
  String token;
  int uid;

  Account({
    required this.channelId,
    required this.platformId,
    required this.token,
    required this.uid,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      channelId: json['channel_id'],
      platformId: json['platform_id'],
      token: json['token'],
      uid: json['uid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'channel_id': channelId,
      'platform_id': platformId,
      'token': token,
      'uid': uid,
    };
  }
}
