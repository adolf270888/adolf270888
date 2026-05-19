import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/app_state.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _channelCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final List<MessageModel> _messages = [];
  String? _channelId;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final app = AppStateScope.of(context);
    app.hub.onMessage((m) => setState(() => _messages.add(m)));
  }

  Future<void> _createChannel() async {
    final app = AppStateScope.of(context);
    try {
      final channel = await app.api.createChannel(_channelCtrl.text.trim());
      await app.hub.joinChannel(channel.id);
      setState(() => _channelId = channel.id);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _loadMessages() async {
    if (_channelId == null) return;
    final app = AppStateScope.of(context);
    final items = await app.api.getMessages(_channelId!);
    setState(() {
      _messages
        ..clear()
        ..addAll(items);
    });
  }

  Future<void> _send() async {
    if (_channelId == null || _messageCtrl.text.trim().isEmpty) return;
    final app = AppStateScope.of(context);
    await app.hub.sendRealtime(_channelId!, _messageCtrl.text.trim());
    _messageCtrl.clear();
  }

  Future<void> _upload() async {
    if (_channelId == null) return;
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null) return;
    await AppStateScope.of(context).api.uploadFile(_channelId!, result.files.single);
    await _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Messenger: ${app.userName ?? ''}'),
        actions: [IconButton(onPressed: _loadMessages, icon: const Icon(Icons.refresh))],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(child: TextField(controller: _channelCtrl, decoration: const InputDecoration(labelText: 'Channel name'))),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _createChannel, child: const Text('Create/Join')),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _upload, child: const Text('Upload file')),
            ]),
          ),
          if (_channelId != null) Text('ChannelId: $_channelId'),
          if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                return ListTile(
                  title: Text('${m.sender}: ${m.text}'),
                  subtitle: m.fileUrl != null ? Text('file: ${m.fileUrl}') : null,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(child: TextField(controller: _messageCtrl, decoration: const InputDecoration(labelText: 'Message'))),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _send, child: const Text('Send')),
            ]),
          )
        ],
      ),
    );
  }
}
