class AuthResponse {
  final String token;
  final DateTime expiresAtUtc;

  AuthResponse({required this.token, required this.expiresAtUtc});

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        token: json['token'] as String,
        expiresAtUtc: DateTime.parse(json['expiresAtUtc'] as String),
      );
}

class ChannelModel {
  final String id;
  final String name;

  ChannelModel({required this.id, required this.name});

  factory ChannelModel.fromJson(Map<String, dynamic> json) =>
      ChannelModel(id: json['id'] as String, name: json['name'] as String);
}

class MessageModel {
  final String id;
  final String channelId;
  final String sender;
  final String text;
  final String? fileUrl;
  final DateTime sentAtUtc;

  MessageModel({
    required this.id,
    required this.channelId,
    required this.sender,
    required this.text,
    required this.sentAtUtc,
    this.fileUrl,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id'] as String,
        channelId: json['channelId'] as String,
        sender: json['sender'] as String,
        text: json['text'] as String,
        fileUrl: json['fileUrl'] as String?,
        sentAtUtc: DateTime.parse(json['sentAtUtc'] as String),
      );
}
