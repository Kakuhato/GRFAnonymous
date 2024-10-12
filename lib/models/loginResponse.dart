///LoginResponse
class LoginResponse {
  int code;
  Data data;
  String message;

  LoginResponse({
    required this.code,
    required this.data,
    required this.message,
  });

  Future<LoginResponse> fromJson(Map<String, dynamic> json) async {
    return LoginResponse(
      code: json['code'],
      data: Data.fromJson(json['data']),
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'data': data.toJson(),
      'message': message,
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
