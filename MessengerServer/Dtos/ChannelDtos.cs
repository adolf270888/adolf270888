namespace MessengerServer.Dtos;

public record CreateChannelRequest(string Name);
public record SendMessageRequest(Guid ChannelId, string Text);
public record MessageDto(Guid Id, Guid ChannelId, string Sender, string Text, string? FileUrl, DateTime SentAtUtc);
