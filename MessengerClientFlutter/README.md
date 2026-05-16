# MessengerClientFlutter

Flutter-клиент (Web + Windows) для подключения к `MessengerServer`.

## Возможности
- Регистрация и вход.
- Создание канала.
- Realtime сообщения через SignalR.
- Загрузка файлов в канал.
- Базовая структура для добавления WebRTC UI (вызовы через `SendCallSignal`).

## Запуск

```bash
flutter pub get
flutter run -d chrome
flutter run -d windows
```

По умолчанию URL сервера в форме логина: `https://localhost:5001`.

## Что доработать
- Экран списка каналов и вступление по `channelId`.
- Хранение токена в `SharedPreferences`.
- Полноценные WebRTC звонки (камера/микрофон + SDP/ICE).
- Повторы/ретраи и дружелюбная обработка ошибок.
