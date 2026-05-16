namespace MessengerServer.Models;

public class ChannelMember
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid ChannelId { get; set; }
    public Guid UserId { get; set; }
}
