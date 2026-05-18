import 'package:flutter/widgets.dart';

import 'api_service.dart';
import 'chat_hub_service.dart';

class AppState extends ChangeNotifier {
  final ApiService api = ApiService();
  final ChatHubService hub = ChatHubService();

  String? token;
  String? userName;
  String baseUrl = 'https://localhost:50291/';

  Future<void> setSession({required String authToken, required String user, required String serverUrl}) async {
    token = authToken;
    userName = user;
    baseUrl = serverUrl;
    api.configure(baseUrl: serverUrl, token: authToken);
    await hub.connect(serverUrl: serverUrl, token: authToken);
    notifyListeners();
  }

  void logout() {
    hub.disconnect();
    token = null;
    userName = null;
    notifyListeners();
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({required super.child, super.key, required AppState state});
  
  AppState? get state => null;

  static AppState? of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    if (scope == null) {
    print('Warning: AppStateScope not found. Using fallback state.');
    return null; // Или возвращайте дефолтное состояние
  }
  return scope.state;
  }
}
