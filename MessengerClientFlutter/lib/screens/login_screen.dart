import 'package:flutter/material.dart';

import '/services/app_state.dart';
import 'chat_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _serverCtrl = TextEditingController(text: 'https://localhost:50291');
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final app = AppStateScope.of(context);
    try {
      final auth = _isLogin
          ? await app?.api.login(_userCtrl.text.trim(), _passCtrl.text, _serverCtrl.text.trim())
          : await app?.api.register(_userCtrl.text.trim(), _passCtrl.text, _serverCtrl.text.trim());

      await app?.setSession(authToken: auth!.token, user: _userCtrl.text.trim(), serverUrl: _serverCtrl.text.trim());

      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ChatScreen()));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(_isLogin ? 'Вход' : 'Регистрация', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                TextField(controller: _serverCtrl, decoration: const InputDecoration(labelText: 'Server URL')),
                TextField(controller: _userCtrl, decoration: const InputDecoration(labelText: 'Username')),
                TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
                const SizedBox(height: 12),
                if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                ElevatedButton(onPressed: _loading ? null : _submit, child: Text(_isLogin ? 'Login' : 'Register')),
                TextButton(
                  onPressed: _loading ? null : () => setState(() => _isLogin = !_isLogin),
                  child: Text(_isLogin ? 'Создать аккаунт' : 'Уже есть аккаунт'),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
