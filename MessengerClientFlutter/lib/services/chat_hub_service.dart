import 'package:signalr_netcore/signalr_client.dart';

import '../models/models.dart';

typedef MessageCallback = void Function(MessageModel message);
typedef SignalCallback = void Function(Map<String, dynamic> signal);

class ChatHubService {
  HubConnection? _connection;

  Future<void> connect({required String serverUrl, required String token}) async {
    _connection = HubConnectionBuilder()
        .withUrl(
          '$serverUrl/hubs/chat?access_token=$token',
          options: HttpConnectionOptions(
            transport: HttpTransportType.WebSockets,
            logging: (level, message) {},
          ),
        )
        .withAutomaticReconnect()
        .build();

    await _connection!.start();
  }

  void onMessage(MessageCallback callback) {
    _connection?.on('message_received', (arguments) {
      if (arguments == null || arguments.isEmpty) return;
      final map = Map<String, dynamic>.from(arguments.first as Map);
      callback(MessageModel.fromJson(map));
    });
  }

  void onSignal(SignalCallback callback) {
    _connection?.on('call_signal', (arguments) {
      if (arguments == null || arguments.isEmpty) return;
      callback(Map<String, dynamic>.from(arguments.first as Map));
    });
  }

  Future<void> joinChannel(String channelId) async {
    await _connection?.invoke('JoinChannel', args: [channelId]);
  }

  Future<void> sendRealtime(String channelId, String text) async {
    await _connection?.invoke('SendToChannel', args: [channelId, text]);
  }

  Future<void> sendCallSignal(String channelId, String type, String payload) async {
    await _connection?.invoke('SendCallSignal', args: [channelId, type, payload]);
  }

  Future<void> disconnect() async {
    await _connection?.stop();
    await _connection?.dispose();
    _connection = null;
  }
}
