import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/app_state.dart';

void main() {
  runApp(const MessengerApp());
}

class MessengerApp extends StatelessWidget {
  const MessengerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Messenger Client',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: AppStateScope(
        notifier: AppState(),
        child: const LoginScreen(),
      ),
    );
  }
}
