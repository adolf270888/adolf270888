using System.Security.Claims;
using MessengerServer.Data;
using MessengerServer.Dtos;
using MessengerServer.Models;
using MessengerServer.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace MessengerServer.Hubs;

[Authorize]
public class ChatHub : Hub
{
    private readonly AppDbContext _db;
    private readonly IMessageCipherService _cipher;

    public ChatHub(AppDbContext db, IMessageCipherService cipher)
    {
        _db = db;
        _cipher = cipher;
    }

    public async Task JoinChannel(string channelId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, ChannelGroup(channelId));
    }

    public async Task SendToChannel(string channelId, string text)
    {
        var senderId = Guid.Parse(Context.User!.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var chId = Guid.Parse(channelId);

        var isMember = await _db.ChannelMembers.AnyAsync(x => x.ChannelId == chId && x.UserId == senderId);
        if (!isMember) throw new HubException("Not a channel member.");

        var msg = new Message
        {
            ChannelId = chId,
            SenderUserId = senderId,
            CipherText = _cipher.Encrypt(text)
        };
        _db.Messages.Add(msg);
        await _db.SaveChangesAsync();

        var senderName = Context.User!.Identity!.Name ?? "unknown";
        var dto = new MessageDto(msg.Id, chId, senderName, text, null, msg.SentAtUtc);
        await Clients.Group(ChannelGroup(channelId)).SendAsync("message_received", dto);
    }

    public async Task SendCallSignal(string channelId, string type, string payload)
    {
        await Clients.OthersInGroup(ChannelGroup(channelId))
            .SendAsync("call_signal", new { channelId, type, payload, from = Context.User?.Identity?.Name });
    }

    private static string ChannelGroup(string channelId) => $"channel:{channelId}";
}
