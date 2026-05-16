# MessengerServer (ASP.NET Core)

Готовый стартовый backend для мессенджера с:
- регистрацией/логином (JWT),
- каналами для общения,
- шифрованием текста сообщений на сервере,
- отправкой файлов,
- realtime-чатом и сигналингом для видеозвонков (WebRTC) через SignalR.

## Основные компоненты

- `POST /api/auth/register` — регистрация.
- `POST /api/auth/login` — вход, выдаёт JWT.
- `POST /api/channels` — создание канала.
- `POST /api/channels/{channelId}/join` — вступление в канал.
- `POST /api/channels/message` — отправка текстового сообщения.
- `GET /api/channels/{channelId}/messages` — чтение сообщений (дешифрование).
- `POST /api/channels/{channelId}/files` — загрузка файлов.
- `SignalR hub /hubs/chat`
  - `JoinChannel(channelId)`
  - `SendToChannel(channelId, text)`
  - `SendCallSignal(channelId, type, payload)` для SDP/ICE обмена в WebRTC.

## Безопасность

- Пароли хэшируются через `PasswordHasher`.
- Сообщения шифруются через `IDataProtection` (`MessageCipherService`).
- Аутентификация и авторизация через JWT Bearer.

## Что добавить в production

1. PostgreSQL + миграции EF Core вместо InMemory.
2. Вынос ключей JWT и DataProtection в секреты/Vault.
3. Проверка MIME/антивирус для файлов.
4. Ограничение частоты запросов (rate limiting).
5. Хранение файлов в S3/Blob.
6. Сквозное шифрование на клиенте (E2EE), если требуется именно end-to-end.

## Запуск

```bash
dotnet restore
dotnet run --project MessengerServer
```

Swagger: `https://localhost:<port>/swagger`.
