namespace MessengerServer.Models;

public class Message
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid ChannelId { get; set; }
    public Guid SenderUserId { get; set; }
    public string CipherText { get; set; } = string.Empty;
    public string? FileUrl { get; set; }
    public DateTime SentAtUtc { get; set; } = DateTime.UtcNow;
}
